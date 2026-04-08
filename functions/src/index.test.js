const { setUserClaimsHandler } = require('./setUserClaims');
const { signQrTokenHandler } = require('./signQrToken');
const { verifyQrTokenHandler } = require('./verifyQrToken');
const { confirmAttendanceHandler } = require('./confirmAttendance');
const { auditLogWriterHandler } = require('./auditLogWriter');
const { signQrPayload } = require('./runtime');

function makeHttpsError(code) {
  return expect.objectContaining({ code });
}

function makeAdminMock() {
  const setCustomUserClaims = jest.fn().mockResolvedValue(undefined);
  const batch = {
    set: jest.fn(),
    commit: jest.fn().mockResolvedValue(undefined),
  };
  const participationDoc = { id: 'participation-1' };
  const auditDoc = { id: 'audit-1', set: jest.fn().mockResolvedValue(undefined) };
  const participationCollection = { doc: jest.fn(() => participationDoc) };
  const auditCollection = { doc: jest.fn(() => auditDoc) };
  const firestore = {
    batch: jest.fn(() => batch),
    collection: jest.fn((name) => {
      if (name === 'participations') {
        return participationCollection;
      }
      return auditCollection;
    }),
  };
  return {
    auth: jest.fn(() => ({ setCustomUserClaims })),
    firestore: jest.fn(() => firestore),
    _claims: setCustomUserClaims,
    _batch: batch,
    _firestore: firestore,
    _participationDoc: participationDoc,
    _auditDoc: auditDoc,
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

  test('sign and verify qr tokens round trip', async () => {
    const clock = () => 1_700_000_000_000;
    const signed = await signQrTokenHandler(
      {
        auth: { uid: 'resident-1', token: { role: 'resident' } },
        data: {
          villageId: 'village-a',
          householdId: 'household-1',
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
          expectedHouseholdId: 'household-1',
        },
      },
      { qrSecret: 'test-secret' },
    );

    expect(signed.ok).toBe(true);
    expect(signed.payload).toMatchObject({
      villageId: 'village-a',
      householdId: 'household-1',
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
        householdId: 'household-1',
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

  test('confirmAttendanceHandler writes participation and audit log', async () => {
    const admin = makeAdminMock();
    const token = signQrPayload(
      {
        version: 1,
        villageId: 'village-a',
        householdId: 'household-1',
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
    expect(result.participation).toMatchObject({
      villageId: 'village-a',
      householdId: 'household-1',
      residentUid: 'resident-1',
      serviceId: 'service-1',
      confirmedByUid: 'worker-1',
      confirmedByRole: 'field_worker',
      status: 'confirmed',
      schemaVersion: 1,
    });
    expect(result.participation.qrTokenHash).toHaveLength(64);
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
    expect(result.entry).toMatchObject({
      actorUid: 'admin-1',
      role: 'admin',
      villageId: 'village-a',
      action: 'manual_review',
      targetId: 'household-1',
      details: { note: 'checked' },
    });
  });
});
