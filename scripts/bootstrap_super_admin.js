const admin = require('firebase-admin');

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i += 1) {
    const current = argv[i];
    if (!current.startsWith('--')) {
      continue;
    }
    const next = argv[i + 1];
    if (next && !next.startsWith('--')) {
      args[current.slice(2)] = next;
      i += 1;
    } else {
      args[current.slice(2)] = 'true';
    }
  }
  return args;
}

async function findExistingSuperAdmin(auth) {
  let pageToken;
  do {
    const result = await auth.listUsers(1000, pageToken);
    const existing = result.users.find((user) => user.customClaims?.role === 'super_admin');
    if (existing) {
      return existing;
    }
    pageToken = result.pageToken;
  } while (pageToken);
  return null;
}

async function main() {
  const args = parseArgs(process.argv);
  const uid = args.uid;
  const email = args.email;
  const force = args.force === 'true';

  if (!uid && !email) {
    throw new Error('Usage: node scripts/bootstrap_super_admin.js --uid <firebase-uid> [--force]');
  }

  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
  }

  const auth = admin.auth();
  const targetUser = uid ? await auth.getUser(uid) : await auth.getUserByEmail(email);
  const existing = await findExistingSuperAdmin(auth);

  if (existing && existing.uid !== targetUser.uid && !force) {
    throw new Error(
      `A super_admin already exists (${existing.uid}). Re-run with --force only if you intentionally want to replace it.`,
    );
  }

  await auth.setCustomUserClaims(targetUser.uid, {
    role: 'super_admin',
    villageIds: [],
    permissions: [],
    stepUpExpiresAt: null,
  });

  // eslint-disable-next-line no-console
  console.log(`Bootstrapped super_admin claims for ${targetUser.uid}`);
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error.message);
  process.exitCode = 1;
});
