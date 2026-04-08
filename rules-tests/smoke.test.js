const fs = require('fs');
const path = require('path');
const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { doc, getDoc, setDoc, updateDoc } = require('firebase/firestore');

jest.setTimeout(90000);

const householdPath = 'households/resident-a';
const consentPath = `${householdPath}/consents/consent-1`;

function authDb(env, uid, claims) {
  return env.authenticatedContext(uid, claims).firestore();
}

async function seedDatabase(env) {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    const householdRef = doc(db, householdPath);
    await setDoc(householdRef, {
      ownerUid: 'resident-a',
      villageId: 'village-a',
      name: 'Household A',
      householdSize: 4,
      schemaVersion: 1,
      createdAt: new Date('2024-01-01T00:00:00.000Z'),
      updatedAt: new Date('2024-01-01T00:00:00.000Z'),
    });

    await setDoc(doc(db, `${householdPath}/sensitive/medical`), {
      notes: 'Sensitive medical record',
      schemaVersion: 1,
    });

    await setDoc(doc(db, `${householdPath}/sensitive/children`), {
      notes: 'Sensitive children record',
      schemaVersion: 1,
    });

    await setDoc(doc(db, consentPath), {
      type: 'medical_share',
      grantedByUid: 'resident-a',
      createdAt: new Date('2024-01-01T00:00:00.000Z'),
      revokedAt: null,
      schemaVersion: 1,
    });

    await setDoc(doc(db, 'services/service-a'), {
      villageId: 'village-a',
      title: 'Community Clinic',
      schemaVersion: 1,
      createdAt: new Date('2024-01-01T00:00:00.000Z'),
      updatedAt: new Date('2024-01-01T00:00:00.000Z'),
    });
  });
}

describe('firestore rules smoke', () => {
  let env;

  beforeAll(async () => {
    env = await initializeTestEnvironment({
      projectId: 'hayati-rules-smoke',
      firestore: {
        host: '127.0.0.1',
        port: 8080,
        rules: fs.readFileSync(path.resolve(__dirname, '../firestore.rules'), 'utf8'),
      },
    });
    await seedDatabase(env);
  });

  afterAll(async () => {
    if (env) {
      await env.cleanup();
    }
  });

  it('denies unauthenticated village writes and allows super admin village creates', async () => {
    const unauth = env.unauthenticatedContext();
    await assertFails(
      setDoc(doc(unauth.firestore(), 'villages/abusir'), {
        name: 'أبوصير',
      }),
    );

    const superAdmin = authDb(env, 'super-admin-uid', {
      role: 'super_admin',
      villageIds: [],
    });
    await assertSucceeds(
      setDoc(doc(superAdmin, 'villages/abusir'), {
        name: 'أبوصير',
        nameEn: 'Abusir',
        governorate: 'الجيزة',
        phaseConfig: {},
        featureKillSwitch: false,
        stats: {},
        createdBy: 'super-admin-uid',
        createdAt: new Date(),
        updatedAt: new Date(),
        schemaVersion: 1,
        isActive: true,
      }),
    );
  });

  it('allows household owners and same-village staff while denying cross-village access', async () => {
    const ownerDb = authDb(env, 'resident-a', {
      role: 'resident',
      villageIds: ['village-a'],
    });
    const workerDb = authDb(env, 'worker-a', {
      role: 'field_worker',
      villageIds: ['village-a'],
    });
    const remoteWorkerDb = authDb(env, 'worker-b', {
      role: 'field_worker',
      villageIds: ['village-b'],
    });

    await assertSucceeds(getDoc(doc(ownerDb, householdPath)));
    await assertSucceeds(getDoc(doc(workerDb, householdPath)));
    await assertFails(getDoc(doc(remoteWorkerDb, householdPath)));
    await assertSucceeds(
      updateDoc(doc(ownerDb, householdPath), {
        name: 'Household A Updated',
      }),
    );
    await assertFails(
      updateDoc(doc(workerDb, householdPath), {
        name: 'Should fail',
      }),
    );
  });

  it('enforces step-up access for sensitive household subcollections', async () => {
    const noStepUpHealthDb = authDb(env, 'health-a', {
      role: 'health_worker',
      villageIds: ['village-a'],
    });
    const stepUpHealthDb = authDb(env, 'health-b', {
      role: 'health_worker',
      villageIds: ['village-a'],
      stepUpExpiresAt: 9_999_999_999,
    });
    const stepUpCollectorDb = authDb(env, 'collector-a', {
      role: 'data_collector',
      villageIds: ['village-a'],
      stepUpExpiresAt: 9_999_999_999,
    });

    await assertFails(getDoc(doc(noStepUpHealthDb, `${householdPath}/sensitive/medical`)));
    await assertSucceeds(getDoc(doc(stepUpHealthDb, `${householdPath}/sensitive/medical`)));
    await assertSucceeds(getDoc(doc(stepUpCollectorDb, `${householdPath}/sensitive/children`)));
  });

  it('keeps consent records append-only for residents and staff', async () => {
    const ownerDb = authDb(env, 'resident-a', {
      role: 'resident',
      villageIds: ['village-a'],
    });

    await assertSucceeds(
      updateDoc(doc(ownerDb, consentPath), {
        revokedAt: new Date('2024-02-01T00:00:00.000Z'),
      }),
    );

    await assertFails(
      updateDoc(doc(ownerDb, consentPath), {
        type: 'changed_type',
      }),
    );
  });

  it('denies client writes to audit log and participations', async () => {
    const residentDb = authDb(env, 'resident-a', {
      role: 'resident',
      villageIds: ['village-a'],
    });

    await assertFails(
      setDoc(doc(residentDb, 'audit_log/entry-1'), {
        actorUid: 'resident-a',
        villageId: 'village-a',
      }),
    );
    await assertFails(
      setDoc(doc(residentDb, 'participations/participation-1'), {
        villageId: 'village-a',
        householdId: 'resident-a',
        residentUid: 'resident-a',
      }),
    );
  });
});
