const { HttpsError } = require('firebase-functions/v2/https');
const {
  QR_TOKEN_VERSION,
  createCallable,
  getQrSecret,
  nowSeconds,
  requireAuth,
  signQrPayload,
} = require('./runtime');

async function signQrTokenHandler(request, deps = {}) {
  requireAuth(request);

  const data = request.data || {};
  const villageId = typeof data.villageId === 'string' ? data.villageId.trim() : data.villageId;
  const householdId = typeof data.householdId === 'string' ? data.householdId.trim() : data.householdId;
  const ttlSeconds = typeof data.ttlSeconds === 'number' ? data.ttlSeconds : 3600 * 24 * 365 * 10;

  if (typeof villageId !== 'string' || !villageId.trim()) {
    throw new HttpsError('invalid-argument', 'villageId is required.');
  }
  if (typeof householdId !== 'string' || !householdId.trim()) {
    throw new HttpsError('invalid-argument', 'householdId is required.');
  }
  if (ttlSeconds <= 0) {
    throw new HttpsError('invalid-argument', 'ttlSeconds must be positive.');
  }

  const issuedAt = nowSeconds(deps.clock);
  const payload = {
    version: QR_TOKEN_VERSION,
    villageId,
    householdId,
    issuedAt,
    expiresAt: issuedAt + ttlSeconds,
    issuerUid: request.auth.uid,
    nonce: deps.nonce || 'dev-nonce',
  };
  const secret = getQrSecret(deps);
  const token = signQrPayload(payload, secret);

  return {
    ok: true,
    token,
    payload,
  };
}

const signQrToken = createCallable((request) => signQrTokenHandler(request));

module.exports = {
  signQrToken,
  signQrTokenHandler,
};
