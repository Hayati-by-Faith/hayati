const fs = require('fs');
const path = require('path');
const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { doc, setDoc } = require('firebase/firestore');

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

    const superAdmin = env.authenticatedContext('super-admin-uid', {
      role: 'super_admin',
      villageIds: [],
    });
    await assertSucceeds(
      setDoc(doc(superAdmin.firestore(), 'villages/abusir'), {
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
});
