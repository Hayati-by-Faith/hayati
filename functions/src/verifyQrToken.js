const { HttpsError } = require('firebase-functions/v2/https');
const {
  createCallable,
  getQrSecret,
  requireAuth,
  verifyQrTokenString,
} = require('./runtime');

async function verifyQrTokenHandler(request, deps = {}) {
  requireAuth(request);

  const data = request.data || {};
  const token = data.token;
  if (typeof token !== 'string' || !token.trim()) {
    throw new HttpsError('invalid-argument', 'token is required.');
  }

  const payload = verifyQrTokenString(token, getQrSecret(deps));

  if (typeof data.expectedVillageId === 'string' && data.expectedVillageId !== payload.villageId) {
    throw new HttpsError('permission-denied', 'Village does not match the QR token.');
  }
  if (typeof data.expectedHouseholdId === 'string' && data.expectedHouseholdId !== payload.householdId) {
    throw new HttpsError('permission-denied', 'Household does not match the QR token.');
  }

  return {
    ok: true,
    valid: true,
    payload,
  };
}

const verifyQrToken = createCallable((request) => verifyQrTokenHandler(request));

module.exports = {
  verifyQrToken,
  verifyQrTokenHandler,
};
