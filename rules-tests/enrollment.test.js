const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  serverTimestamp,
  GeoPoint,
} = require('firebase/firestore');

jest.setTimeout(90000);

function authDb(env, uid, claims) {
  return env.authenticatedContext(uid, claims).firestore();
}

function baseHouseholdPayload({ ownerUid, villageId, extra = {} }) {
  return {
    ownerUid,
    villageId,
    name: 'Household',
    householdSize: 4,
    schemaVersion: 1,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    ...extra,
  };
}

async function seedHousehold(env, householdId, villageId) {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, `households/${householdId}`), {
      ownerUid: householdId,
      villageId,
      name: 'Seed',
      householdSize: 4,
      schemaVersion: 1,
      createdAt: new Date('2024-01-01T00:00:00.000Z'),
      updatedAt: new Date('2024-01-01T00:00:00.000Z'),
    });
  });
}

describe('firestore rules - enrollment', () => {
  let env;

  beforeAll(async () => {
    env = await initializeTestEnvironment({
      projectId: 'hayati-rules-enrollment',
      firestore: {
        host: '127.0.0.1',
        port: 8080,
        rules: fs.readFileSync(
          path.resolve(__dirname, '../firestore.rules'),
          'utf8',
        ),
      },
    });
  });

  afterEach(async () => {
    await env.clearFirestore();
  });

  afterAll(async () => {
    if (env) {
      await env.cleanup();
    }
  });

  describe('household create', () => {
    it('allows household create by owner without gps', async () => {
      const residentDb = authDb(env, 'resident-x', {
        role: 'resident',
        villageIds: ['village-x'],
      });
      await assertSucceeds(
        setDoc(
          doc(residentDb, 'households/resident-x'),
          baseHouseholdPayload({
            ownerUid: 'resident-x',
            villageId: 'village-x',
          }),
        ),
      );
    });

    it('allows household create with gps set to null', async () => {
      const residentDb = authDb(env, 'resident-x', {
        role: 'resident',
        villageIds: ['village-x'],
      });
      await assertSucceeds(
        setDoc(
          doc(residentDb, 'households/resident-x'),
          baseHouseholdPayload({
            ownerUid: 'resident-x',
            villageId: 'village-x',
            extra: { gps: null, geohash: null },
          }),
        ),
      );
    });

    it('allows household create with valid gps and geohash', async () => {
      const residentDb = authDb(env, 'resident-y', {
        role: 'resident',
        villageIds: ['village-y'],
      });
      await assertSucceeds(
        setDoc(
          doc(residentDb, 'households/resident-y'),
          baseHouseholdPayload({
            ownerUid: 'resident-y',
            villageId: 'village-y',
            extra: {
              gps: new GeoPoint(29.9792, 31.1342),
              geohash: 'stq4s3x1p',
            },
          }),
        ),
      );
    });

    it('denies household create with gps but no geohash', async () => {
      const residentDb = authDb(env, 'resident-z', {
        role: 'resident',
        villageIds: ['village-z'],
      });
      await assertFails(
        setDoc(
          doc(residentDb, 'households/resident-z'),
          baseHouseholdPayload({
            ownerUid: 'resident-z',
            villageId: 'village-z',
            extra: { gps: new GeoPoint(29.9792, 31.1342) },
          }),
        ),
      );
    });

    it('denies household create with gps but empty geohash', async () => {
      const residentDb = authDb(env, 'resident-z', {
        role: 'resident',
        villageIds: ['village-z'],
      });
      await assertFails(
        setDoc(
          doc(residentDb, 'households/resident-z'),
          baseHouseholdPayload({
            ownerUid: 'resident-z',
            villageId: 'village-z',
            extra: { gps: new GeoPoint(29.9792, 31.1342), geohash: '' },
          }),
        ),
      );
    });

    it('denies household create when householdId != uid', async () => {
      const residentDb = authDb(env, 'resident-x', {
        role: 'resident',
        villageIds: ['village-x'],
      });
      await assertFails(
        setDoc(
          doc(residentDb, 'households/other-user'),
          baseHouseholdPayload({
            ownerUid: 'resident-x',
            villageId: 'village-x',
          }),
        ),
      );
    });

    it('denies household create when role field is present', async () => {
      const residentDb = authDb(env, 'resident-x', {
        role: 'resident',
        villageIds: ['village-x'],
      });
      await assertFails(
        setDoc(
          doc(residentDb, 'households/resident-x'),
          baseHouseholdPayload({
            ownerUid: 'resident-x',
            villageId: 'village-x',
            extra: { role: 'super_admin' },
          }),
        ),
      );
    });

    it('denies household create when qrTokenId field is present', async () => {
      const residentDb = authDb(env, 'resident-x', {
        role: 'resident',
        villageIds: ['village-x'],
      });
      await assertFails(
        setDoc(
          doc(residentDb, 'households/resident-x'),
          baseHouseholdPayload({
            ownerUid: 'resident-x',
            villageId: 'village-x',
            extra: { qrTokenId: 'forged-nonce' },
          }),
        ),
      );
    });
  });

  describe('consent create', () => {
    const consentPayload = (uid) => ({
      scope: 'privacy_v1',
      version: 1,
      grantedByUid: uid,
      onBehalfOfUid: uid,
      grantedAt: serverTimestamp(),
      revokedAt: null,
      evidence: { method: 'otp' },
      schemaVersion: 1,
    });

    it('allows consent create by household owner', async () => {
      const residentDb = authDb(env, 'resident-x', {
        role: 'resident',
        villageIds: ['village-x'],
      });
      await assertSucceeds(
        setDoc(
          doc(residentDb, 'households/resident-x/consents/c1'),
          consentPayload('resident-x'),
        ),
      );
    });

    it('allows consent create by data_collector in same village', async () => {
      await seedHousehold(env, 'resident-x', 'village-x');
      const collectorDb = authDb(env, 'collector-a', {
        role: 'data_collector',
        villageIds: ['village-x'],
      });
      await assertSucceeds(
        setDoc(
          doc(collectorDb, 'households/resident-x/consents/c1'),
          consentPayload('collector-a'),
        ),
      );
    });

    it('denies consent create by data_collector in different village', async () => {
      await seedHousehold(env, 'resident-x', 'village-x');
      const collectorDb = authDb(env, 'collector-b', {
        role: 'data_collector',
        villageIds: ['village-y'],
      });
      await assertFails(
        setDoc(
          doc(collectorDb, 'households/resident-x/consents/c1'),
          consentPayload('collector-b'),
        ),
      );
    });

    it('denies consent create by unauthenticated', async () => {
      const anonDb = env.unauthenticatedContext().firestore();
      await assertFails(
        setDoc(
          doc(anonDb, 'households/resident-x/consents/c1'),
          consentPayload('unknown'),
        ),
      );
    });
  });

  describe('consent read', () => {
    beforeEach(async () => {
      await seedHousehold(env, 'resident-x', 'village-x');
      await env.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();
        await setDoc(doc(db, 'households/resident-x/consents/c1'), {
          scope: 'privacy_v1',
          version: 1,
          grantedByUid: 'resident-x',
          onBehalfOfUid: 'resident-x',
          grantedAt: new Date('2024-01-01T00:00:00.000Z'),
          revokedAt: null,
          evidence: { method: 'otp' },
          schemaVersion: 1,
        });
      });
    });

    it('allows consent read by household owner', async () => {
      const ownerDb = authDb(env, 'resident-x', {
        role: 'resident',
        villageIds: ['village-x'],
      });
      await assertSucceeds(
        getDoc(doc(ownerDb, 'households/resident-x/consents/c1')),
      );
    });

    it('allows consent read by village admin', async () => {
      const adminDb = authDb(env, 'admin-a', {
        role: 'admin',
        villageIds: ['village-x'],
      });
      await assertSucceeds(
        getDoc(doc(adminDb, 'households/resident-x/consents/c1')),
      );
    });

    it('denies consent read by cross-village admin', async () => {
      const adminDb = authDb(env, 'admin-b', {
        role: 'admin',
        villageIds: ['village-y'],
      });
      await assertFails(
        getDoc(doc(adminDb, 'households/resident-x/consents/c1')),
      );
    });
  });

  describe('consent update / delete', () => {
    beforeEach(async () => {
      await seedHousehold(env, 'resident-x', 'village-x');
      await env.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();
        await setDoc(doc(db, 'households/resident-x/consents/c1'), {
          scope: 'privacy_v1',
          version: 1,
          grantedByUid: 'resident-x',
          onBehalfOfUid: 'resident-x',
          grantedAt: new Date('2024-01-01T00:00:00.000Z'),
          revokedAt: null,
          evidence: { method: 'otp' },
          schemaVersion: 1,
        });
      });
    });

    it('allows owner to revoke consent (revokedAt only)', async () => {
      const ownerDb = authDb(env, 'resident-x', {
        role: 'resident',
        villageIds: ['village-x'],
      });
      await assertSucceeds(
        updateDoc(doc(ownerDb, 'households/resident-x/consents/c1'), {
          revokedAt: serverTimestamp(),
        }),
      );
    });

    it('denies owner changing scope', async () => {
      const ownerDb = authDb(env, 'resident-x', {
        role: 'resident',
        villageIds: ['village-x'],
      });
      await assertFails(
        updateDoc(doc(ownerDb, 'households/resident-x/consents/c1'), {
          scope: 'privacy_v2',
        }),
      );
    });

    it('denies consent delete by owner', async () => {
      const ownerDb = authDb(env, 'resident-x', {
        role: 'resident',
        villageIds: ['village-x'],
      });
      await assertFails(
        deleteDoc(doc(ownerDb, 'households/resident-x/consents/c1')),
      );
    });
  });
});
