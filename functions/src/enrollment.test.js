const { createHouseholdHandler } = require('./enrollment');

function makeHttpsError(code) {
  return expect.objectContaining({ code });
}

function makeAdminMock({
  rateLimitCount = 0,
  householdExists = false,
  existingOwnerUid = null,
  existingVillageId = 'village-a',
} = {}) {
  const setCustomUserClaims = jest.fn().mockResolvedValue(undefined);

  const batch = {
    set: jest.fn(),
    commit: jest.fn().mockResolvedValue(undefined),
  };

  const rateLimitSet = jest.fn();
  const rateLimitSnapshot = {
    exists: rateLimitCount > 0,
    data: jest.fn(() => ({ count: rateLimitCount })),
  };
  const rateLimitTransaction = {
    get: jest.fn(async () => rateLimitSnapshot),
    set: rateLimitSet,
  };

  const householdSnapshot = {
    exists: householdExists,
    data: jest.fn(() =>
      householdExists
        ? { ownerUid: existingOwnerUid, villageId: existingVillageId }
        : null,
    ),
  };
  const householdRef = {
    id: 'household-uid',
    get: jest.fn(async () => householdSnapshot),
  };
  const householdsCollection = { doc: jest.fn(() => householdRef) };

  const auditRefs = [];
  const auditCollection = {
    doc: jest.fn(() => {
      const r = { id: `audit-${auditRefs.length + 1}` };
      auditRefs.push(r);
      return r;
    }),
  };

  const firestoreInstance = {
    batch: jest.fn(() => batch),
    runTransaction: jest.fn(async (cb) => cb(rateLimitTransaction)),
    collection: jest.fn((name) => {
      if (name === 'households') return householdsCollection;
      if (name === 'audit_log') return auditCollection;
      return { doc: jest.fn(() => ({ set: jest.fn() })) };
    }),
  };

  function GeoPointCtor(latitude, longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
  }

  const firestore = Object.assign(jest.fn(() => firestoreInstance), {
    FieldValue: {
      serverTimestamp: jest.fn(() => 'serverTimestamp'),
    },
    GeoPoint: GeoPointCtor,
  });

  return {
    auth: jest.fn(() => ({ setCustomUserClaims })),
    firestore,
    _claims: setCustomUserClaims,
    _batch: batch,
    _firestore: firestoreInstance,
    _householdRef: householdRef,
    _auditRefs: auditRefs,
    _rateLimitTransaction: rateLimitTransaction,
    _rateLimitSet: rateLimitSet,
  };
}

const validRequestData = {
  villageId: 'village-a',
  name: 'عائلة تجريبية',
  address: 'قرية أبوصير، الجيزة',
  householdSize: 4,
  comment: 'no notes',
};

const deps = { qrSecret: 'test-secret', clock: () => 1_700_000_000_000, nonce: 'fixed-nonce' };

describe('createHouseholdHandler', () => {
  test('rejects unauthenticated', async () => {
    await expect(
      createHouseholdHandler({ data: validRequestData }, deps),
    ).rejects.toEqual(makeHttpsError('unauthenticated'));
  });

  test('accepts valid enrollment without gps', async () => {
    const admin = makeAdminMock();
    const result = await createHouseholdHandler(
      {
        auth: { uid: 'resident-1', token: {} },
        data: { ...validRequestData },
      },
      { ...deps, admin },
    );

    expect(result.ok).toBe(true);
    expect(result.idempotent).toBe(false);
    expect(result.householdId).toBe('resident-1');
    expect(result.qrToken).toEqual(expect.any(String));
    expect(result.qrToken).toContain('.');
    expect(admin._batch.set).toHaveBeenCalledTimes(4);
    expect(admin._batch.commit).toHaveBeenCalledTimes(1);
    expect(admin._claims).toHaveBeenCalledWith('resident-1', {
      role: 'resident',
      villageIds: ['village-a'],
    });
    const householdCall = admin._batch.set.mock.calls[0];
    const householdPayload = householdCall[1];
    expect(householdPayload).toMatchObject({
      ownerUid: 'resident-1',
      villageId: 'village-a',
      name: 'عائلة تجريبية',
      householdSize: 4,
      schemaVersion: 1,
      gps: null,
      geohash: null,
      qrTokenId: 'fixed-nonce',
    });
  });

  test('accepts valid enrollment with gps', async () => {
    const admin = makeAdminMock();
    const result = await createHouseholdHandler(
      {
        auth: { uid: 'resident-1', token: {} },
        data: {
          ...validRequestData,
          gps: { latitude: 29.9792, longitude: 31.1342 },
          geohash: 'stq4s3x1p',
        },
      },
      { ...deps, admin },
    );

    expect(result.ok).toBe(true);
    const householdCall = admin._batch.set.mock.calls[0];
    const householdPayload = householdCall[1];
    expect(householdPayload.gps).toMatchObject({
      latitude: 29.9792,
      longitude: 31.1342,
    });
    expect(householdPayload.geohash).toBe('stq4s3x1p');

    const householdAudit = admin._batch.set.mock.calls[1][1];
    expect(householdAudit).toMatchObject({
      action: 'household.create',
      details: { gpsProvided: true },
    });
  });

  test('audit entry marks gpsProvided false when gps missing', async () => {
    const admin = makeAdminMock();
    await createHouseholdHandler(
      {
        auth: { uid: 'resident-1', token: {} },
        data: { ...validRequestData },
      },
      { ...deps, admin },
    );
    const householdAudit = admin._batch.set.mock.calls[1][1];
    expect(householdAudit).toMatchObject({
      action: 'household.create',
      details: { gpsProvided: false },
    });
  });

  test('rejects gps without geohash', async () => {
    const admin = makeAdminMock();
    await expect(
      createHouseholdHandler(
        {
          auth: { uid: 'resident-1', token: {} },
          data: {
            ...validRequestData,
            gps: { latitude: 29.9, longitude: 31.1 },
          },
        },
        { ...deps, admin },
      ),
    ).rejects.toEqual(makeHttpsError('invalid-argument'));
  });

  test('rejects gps with empty geohash', async () => {
    const admin = makeAdminMock();
    await expect(
      createHouseholdHandler(
        {
          auth: { uid: 'resident-1', token: {} },
          data: {
            ...validRequestData,
            gps: { latitude: 29.9, longitude: 31.1 },
            geohash: '   ',
          },
        },
        { ...deps, admin },
      ),
    ).rejects.toEqual(makeHttpsError('invalid-argument'));
  });

  test('rejects missing name', async () => {
    const admin = makeAdminMock();
    await expect(
      createHouseholdHandler(
        {
          auth: { uid: 'resident-1', token: {} },
          data: { ...validRequestData, name: '' },
        },
        { ...deps, admin },
      ),
    ).rejects.toEqual(makeHttpsError('invalid-argument'));
  });

  test('rejects invalid householdSize', async () => {
    const admin = makeAdminMock();
    await expect(
      createHouseholdHandler(
        {
          auth: { uid: 'resident-1', token: {} },
          data: { ...validRequestData, householdSize: 0 },
        },
        { ...deps, admin },
      ),
    ).rejects.toEqual(makeHttpsError('invalid-argument'));

    await expect(
      createHouseholdHandler(
        {
          auth: { uid: 'resident-1', token: {} },
          data: { ...validRequestData, householdSize: 999 },
        },
        { ...deps, admin: makeAdminMock() },
      ),
    ).rejects.toEqual(makeHttpsError('invalid-argument'));
  });

  test('rejects missing villageId', async () => {
    const admin = makeAdminMock();
    await expect(
      createHouseholdHandler(
        {
          auth: { uid: 'resident-1', token: {} },
          data: { ...validRequestData, villageId: '' },
        },
        { ...deps, admin },
      ),
    ).rejects.toEqual(makeHttpsError('invalid-argument'));
  });

  test('rejects when rate limit exceeded', async () => {
    const admin = makeAdminMock({ rateLimitCount: 5 });
    await expect(
      createHouseholdHandler(
        {
          auth: { uid: 'resident-1', token: {} },
          data: validRequestData,
        },
        { ...deps, admin },
      ),
    ).rejects.toEqual(makeHttpsError('resource-exhausted'));
  });

  test('idempotent return for existing household owned by same uid', async () => {
    const admin = makeAdminMock({
      householdExists: true,
      existingOwnerUid: 'resident-1',
      existingVillageId: 'village-a',
    });
    const result = await createHouseholdHandler(
      {
        auth: { uid: 'resident-1', token: {} },
        data: validRequestData,
      },
      { ...deps, admin },
    );
    expect(result).toMatchObject({
      ok: true,
      idempotent: true,
      householdId: 'resident-1',
    });
    expect(result.qrToken).toEqual(expect.any(String));
    expect(admin._batch.set).not.toHaveBeenCalled();
    expect(admin._claims).not.toHaveBeenCalled();
  });

  test('rejects when existing household owned by another user', async () => {
    const admin = makeAdminMock({
      householdExists: true,
      existingOwnerUid: 'other-user',
    });
    await expect(
      createHouseholdHandler(
        {
          auth: { uid: 'resident-1', token: {} },
          data: validRequestData,
        },
        { ...deps, admin },
      ),
    ).rejects.toEqual(makeHttpsError('already-exists'));
  });
});
