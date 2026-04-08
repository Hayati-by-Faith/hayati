const { setUserClaimsHandler } = require('./setUserClaims');
const { signQrTokenHandler } = require('./signQrToken');
const { verifyQrTokenHandler } = require('./verifyQrToken');
const { confirmAttendanceHandler } = require('./confirmAttendance');
const { auditLogWriterHandler } = require('./auditLogWriter');
const { signQrPayload } = require('./runtime');

function makeHttpsError(code) {
  return expect.objectContaining({ code });
}

function makeAdminMock({ serviceVillageId = 'village-a' } = {}) {
  const setCustomUserClaims = jest.fn().mockResolvedValue(undefined);
  const batch = {
    set: jest.fn(),
    commit: jest.fn().mockResolvedValue(undefined),
  };
  const participationDoc = { id: 'participation-1' };
  const auditDoc = { id: 'audit-1', set: jest.fn().mockResolvedValue(undefined) };
  const serviceDoc = {
    exists: true,
    data: jest.fn(() => ({ villageId: serviceVillageId })),
    get: jest.fn(async () => serviceDoc),
  };
  const participationCollection = { doc: jest.fn(() => participationDoc) };
  const auditCollection = { doc: jest.fn(() => auditDoc) };
  const servicesCollection = { doc: jest.fn(() => serviceDoc) };
  const firestoreInstance = {
    batch: jest.fn(() => batch),
    collection: jest.fn((name) => {
      if (name === 'services') {
        return servicesCollection;
      }
      if (name === 'participations') {
        return participationCollection;
      }
      return auditCollection;
    }),
  };
  const firestore = Object.assign(jest.fn(() => firestoreInstance), {
    FieldValue: {
      serverTimestamp: jest.fn(() => 'serverTimestamp'),
    },
  });
  return {
    auth: jest.fn(() => ({ setCustomUserClaims })),
    firestore,
    _claims: setCustomUserClaims,
    _batch: batch,
    _firestore: firestoreInstance,
    _participationDoc: participationDoc,
    _auditDoc: auditDoc,
    _serviceDoc: serviceDoc,
  };
}

describe('functions handlers', () => {
  test('setUserClaimsHandler writes super_admin claims', async () => {
    const admin = makeAdminMock();
    const result = await setUserClaimsHandler(
      {
        auth: { uid: 'super-1', token: { role: 'super_admin' } },
        data: {
          targetUid: 'resident-1',
          role: 'resident',
          villageIds: [' village-a '],
          permissions: ['read_posts'],
          stepUpExpiresAt: 123,
        },
      },
      { admin },
    );

    expect(result).toEqual({
      ok: true,
      targetUid: 'resident-1',
      claims: {
        role: 'resident',
        villageIds: ['village-a'],
        permissions: ['read_posts'],
        stepUpExpiresAt: 123,
      },
    });
    expect(admin._claims).toHaveBeenCalledWith('resident-1', {
      role: 'resident',
      villageIds: ['village-a'],
      permissions: ['read_posts'],
      stepUpExpiresAt: 123,
    });
  });

  test('setUserClaimsHandler rejects missing villageIds for non-super_admin roles', async () => {
    await expect(
      setUserClaimsHandler(
        {
          auth: { uid: 'super-1', token: { role: 'super_admin' } },
          data: {
            targetUid: 'resident-1',
            role: 'resident',
            villageIds: [],
          },
        },
        {},
      ),
    ).rejects.toEqual(makeHttpsError('invalid-argument'));
  });

  test('setUserClaimsHandler rejects non-super_admin callers', async () => {
    await expect(
      setUserClaimsHandler(
        {
          auth: { uid: 'worker-1', token: { role: 'field_worker' } },
          data: {
            targetUid: 'resident-1',
            role: 'resident',
            villageIds: ['village-a'],
          },
        },
        {},
      ),
    ).rejects.toEqual(makeHttpsError('permission-denied'));
  });

  test('signQrTokenHandler rejects unauthenticated requests', async () => {
    await expect(
      signQrTokenHandler(
        {
          data: {
            villageId: 'village-a',
            householdId: 'resident-1',
          },
        },
        { qrSecret: 'test-secret' },
      ),
    ).rejects.toEqual(makeHttpsError('unauthenticated'));
  });

  test('signQrTokenHandler rejects subjectUid mismatch', async () => {
    await expect(
      signQrTokenHandler(
        {
          auth: { uid: 'resident-1', token: { role: 'resident' } },
          data: {
            villageId: 'village-a',
            householdId: 'resident-1',
            subjectUid: 'resident-2',
          },
        },
        { qrSecret: 'test-secret' },
      ),
    ).rejects.toEqual(makeHttpsError('invalid-argument'));
  });

  test('sign and verify qr tokens round trip', async () => {
    const clock = () => 1_700_000_000_000;
    const signed = await signQrTokenHandler(
      {
        auth: { uid: 'resident-1', token: { role: 'resident' } },
        data: {
          villageId: 'village-a',
          householdId: 'resident-1',
          subjectUid: 'resident-1',
          ttlSeconds: 60 * 60 * 24 * 365 * 50,
        },
      },
      { clock, qrSecret: 'test-secret', nonce: 'fixed-nonce' },
    );

    const verified = await verifyQrTokenHandler(
      {
        auth: { uid: 'worker-1', token: { role: 'field_worker' } },
        data: {
          token: signed.token,
          expectedVillageId: 'village-a',
          expectedHouseholdId: 'resident-1',
        },
      },
      { qrSecret: 'test-secret' },
    );

    expect(signed.ok).toBe(true);
    expect(signed.payload).toMatchObject({
      villageId: 'village-a',
      householdId: 'resident-1',
      subjectUid: 'resident-1',
      issuerUid: 'resident-1',
      nonce: 'fixed-nonce',
    });
    expect(verified.ok).toBe(true);
    expect(verified.valid).toBe(true);
    expect(verified.payload).toMatchObject(signed.payload);
  });

  test('verifyQrTokenHandler rejects mismatched household', async () => {
    const token = signQrPayload(
      {
        version: 1,
        villageId: 'village-a',
        householdId: 'resident-1',
        subjectUid: 'resident-1',
        issuedAt: 1000,
        expiresAt: 2000,
        issuerUid: 'resident-1',
        nonce: 'n',
      },
      'test-secret',
    );

    await expect(
      verifyQrTokenHandler(
        {
          auth: { uid: 'worker-1', token: { role: 'field_worker' } },
          data: {
            token,
            expectedHouseholdId: 'household-2',
          },
        },
        { qrSecret: 'test-secret', clock: () => 1_500_000_000_000 },
      ),
    ).rejects.toEqual(makeHttpsError('permission-denied'));
  });

  test('verifyQrTokenHandler rejects expired token', async () => {
    const token = signQrPayload(
      {
        version: 1,
        villageId: 'village-a',
        householdId: 'resident-1',
        subjectUid: 'resident-1',
        issuedAt: 1000,
        expiresAt: 1001,
        issuerUid: 'resident-1',
        nonce: 'n',
      },
      'test-secret',
    );

    await expect(
      verifyQrTokenHandler(
        {
          auth: { uid: 'worker-1', token: { role: 'field_worker' } },
          data: {
            token,
          },
        },
        { qrSecret: 'test-secret' },
      ),
    ).rejects.toEqual(makeHttpsError('permission-denied'));
  });

  test('confirmAttendanceHandler writes participation and audit log', async () => {
    const admin = makeAdminMock();
    const token = signQrPayload(
      {
        version: 1,
        villageId: 'village-a',
        householdId: 'resident-1',
        subjectUid: 'resident-1',
        issuedAt: 1000,
        expiresAt: 9999999999,
        issuerUid: 'resident-1',
        nonce: 'n',
      },
      'test-secret',
    );
    const result = await confirmAttendanceHandler(
      {
        auth: { uid: 'worker-1', token: { role: 'field_worker' } },
        data: {
          serviceId: 'service-1',
          token,
        },
      },
      { admin, qrSecret: 'test-secret', clock: () => 1_700_000_000_000 },
    );

    expect(result.ok).toBe(true);
    expect(admin._batch.set).toHaveBeenCalledTimes(2);
    expect(admin._batch.commit).toHaveBeenCalledTimes(1);
    expect(admin._serviceDoc.data).toHaveBeenCalledTimes(1);
    expect(result.participation).toMatchObject({
      villageId: 'village-a',
      householdId: 'resident-1',
      residentUid: 'resident-1',
      serviceId: 'service-1',
      confirmedByUid: 'worker-1',
      confirmedByRole: 'field_worker',
      status: 'confirmed',
      schemaVersion: 1,
    });
    expect(result.participation.qrTokenHash).toHaveLength(64);
    expect(result.participation.confirmedAt).toBe('2023-11-14T22:13:20.000Z');
    expect(result.auditEntry).toMatchObject({
      actorUid: 'worker-1',
      role: 'field_worker',
      villageId: 'village-a',
      action: 'confirm_attendance',
      targetId: 'service-1',
    });
  });

  test('auditLogWriterHandler writes audit entries for admin roles', async () => {
    const admin = makeAdminMock();
    const result = await auditLogWriterHandler(
      {
        auth: { uid: 'admin-1', token: { role: 'admin' } },
        data: {
          villageId: 'village-a',
          action: 'manual_review',
          targetId: 'household-1',
          details: { note: 'checked' },
        },
      },
      { admin, clock: () => 1_700_000_000_000 },
    );

    expect(result.ok).toBe(true);
    expect(admin._firestore.collection).toHaveBeenCalledWith('audit_log');
    expect(admin._auditDoc.set).toHaveBeenCalledTimes(1);
    expect(admin._auditDoc.set).toHaveBeenCalledWith(
      expect.objectContaining({
        createdAt: 'serverTimestamp',
      }),
    );
    expect(result.entry).toMatchObject({
      actorUid: 'admin-1',
      role: 'admin',
      villageId: 'village-a',
      action: 'manual_review',
      targetId: 'household-1',
      details: { note: 'checked' },
    });
  });

  test('auditLogWriterHandler rejects field worker role', async () => {
    await expect(
      auditLogWriterHandler(
        {
          auth: { uid: 'worker-1', token: { role: 'field_worker' } },
          data: {
            villageId: 'village-a',
            action: 'manual_review',
          },
        },
        {},
      ),
    ).rejects.toEqual(makeHttpsError('permission-denied'));
  });

  test('confirmAttendanceHandler rejects service village mismatch', async () => {
    const admin = makeAdminMock({ serviceVillageId: 'village-b' });
    const token = signQrPayload(
      {
        version: 1,
        villageId: 'village-a',
        householdId: 'resident-1',
        subjectUid: 'resident-1',
        issuedAt: 1000,
        expiresAt: 9999999999,
        issuerUid: 'resident-1',
        nonce: 'n',
      },
      'test-secret',
    );

    await expect(
      confirmAttendanceHandler(
        {
          auth: { uid: 'worker-1', token: { role: 'field_worker' } },
          data: {
            serviceId: 'service-1',
            token,
          },
        },
        { admin, qrSecret: 'test-secret', clock: () => 1_700_000_000_000 },
      ),
    ).rejects.toEqual(makeHttpsError('permission-denied'));
  });
});
