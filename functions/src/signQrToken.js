const crypto = require('crypto');
const { HttpsError } = require('firebase-functions/v2/https');
const {
  QR_TOKEN_VERSION,
  createCallable,
  getQrSecret,
  nowSeconds,
  qrHmacSecret,
  requireAuth,
  signQrPayload,
} = require('./runtime');

async function signQrTokenHandler(request, deps = {}) {
  requireAuth(request);

  const data = request.data || {};
  const villageId = typeof data.villageId === 'string' ? data.villageId.trim() : data.villageId;
  const householdId = typeof data.householdId === 'string' ? data.householdId.trim() : data.householdId;
  const subjectUid = typeof data.subjectUid === 'string' ? data.subjectUid.trim() : request.auth.uid;
  const ttlSeconds = typeof data.ttlSeconds === 'number' ? data.ttlSeconds : 3600 * 24 * 365 * 10;

  if (typeof villageId !== 'string' || !villageId.trim()) {
    throw new HttpsError('invalid-argument', 'villageId is required.');
  }
  if (typeof householdId !== 'string' || !householdId.trim()) {
    throw new HttpsError('invalid-argument', 'householdId is required.');
  }
  if (typeof subjectUid !== 'string' || !subjectUid.trim()) {
    throw new HttpsError('invalid-argument', 'subjectUid is required.');
  }
  if (subjectUid !== householdId) {
    throw new HttpsError('invalid-argument', 'subjectUid must match householdId in Phase 1.');
  }
  if (ttlSeconds <= 0) {
    throw new HttpsError('invalid-argument', 'ttlSeconds must be positive.');
  }

  const nonce = typeof deps.nonce === 'string' && deps.nonce.trim() ? deps.nonce.trim() : crypto.randomBytes(16).toString('hex');

  const issuedAt = nowSeconds(deps.clock);
  const payload = {
    version: QR_TOKEN_VERSION,
    villageId,
    householdId,
    subjectUid,
    issuedAt,
    expiresAt: issuedAt + ttlSeconds,
    issuerUid: request.auth.uid,
    nonce,
  };
  const secret = getQrSecret(deps);
  const token = signQrPayload(payload, secret);

  return {
    ok: true,
    token,
    payload,
  };
}

const signQrToken = createCallable((request) => signQrTokenHandler(request), [qrHmacSecret]);

module.exports = {
  signQrToken,
  signQrTokenHandler,
};
