const { HttpsError } = require('firebase-functions/v2/https');
const {
  ALLOWED_ROLES,
  createCallable,
  getAdmin,
  normalizeVillageIds,
  requireAuth,
  requireRole,
} = require('./runtime');

async function setUserClaimsHandler(request, deps = {}) {
  requireAuth(request);
  requireRole(request, ['super_admin']);

  const data = request.data || {};
  const targetUid = data.targetUid;
  const role = data.role;
  const rawVillageIds = data.villageIds;
  const permissions = Array.isArray(data.permissions) ? data.permissions.filter((item) => typeof item === 'string') : [];
  const stepUpExpiresAt = data.stepUpExpiresAt ?? null;

  if (typeof targetUid !== 'string' || !targetUid.trim()) {
    throw new HttpsError('invalid-argument', 'targetUid is required.');
  }
  if (!ALLOWED_ROLES.includes(role)) {
    throw new HttpsError('invalid-argument', 'role is invalid.');
  }
  if (role === 'super_admin') {
    if (rawVillageIds !== undefined && Array.isArray(rawVillageIds) && rawVillageIds.length > 0) {
      throw new HttpsError('invalid-argument', 'super_admin claims must not include villageIds.');
    }
  } else if (!Array.isArray(rawVillageIds) || rawVillageIds.length === 0) {
    throw new HttpsError('invalid-argument', 'villageIds are required for non-super_admin roles.');
  }
  if (stepUpExpiresAt !== null && typeof stepUpExpiresAt !== 'number') {
    throw new HttpsError('invalid-argument', 'stepUpExpiresAt must be a number or null.');
  }

  const admin = deps.admin || getAdmin();
  const claims = {
    role,
    villageIds: role === 'super_admin' ? [] : normalizeVillageIds(rawVillageIds),
    permissions,
    stepUpExpiresAt,
  };

  await admin.auth().setCustomUserClaims(targetUid, claims);

  return {
    ok: true,
    targetUid,
    claims,
  };
}

const setUserClaims = createCallable((request) => setUserClaimsHandler(request));

module.exports = {
  setUserClaims,
  setUserClaimsHandler,
};
