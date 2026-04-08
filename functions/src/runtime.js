const crypto = require('crypto');
const admin = require('firebase-admin');
const { HttpsError, onCall } = require('firebase-functions/v2/https');

const REGION = 'europe-west1';
const QR_TOKEN_VERSION = 1;
const DEFAULT_QR_SECRET = process.env.QR_HMAC_SECRET || 'hayati-development-secret';
const ALLOWED_ROLES = [
  'resident',
  'field_worker',
  'health_worker',
  'data_collector',
  'service_provider',
  'admin',
  'super_admin',
];

function getAdmin() {
  if (!admin.apps.length) {
    admin.initializeApp();
  }
  return admin;
}

function createCallable(handler) {
  return onCall({ region: REGION }, handler);
}

function requireAuth(request) {
  const uid = request?.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Authentication is required.');
  }
  return uid;
}

function requireRole(request, roles) {
  const role = request?.auth?.token?.role;
  if (!roles.includes(role)) {
    throw new HttpsError('permission-denied', `Role must be one of: ${roles.join(', ')}`);
  }
  return role;
}

function normalizeVillageIds(villageIds) {
  if (!Array.isArray(villageIds)) {
    throw new HttpsError('invalid-argument', 'villageIds must be an array.');
  }
  const normalized = villageIds
    .filter((value) => typeof value === 'string')
    .map((value) => value.trim())
    .filter(Boolean);
  if (!normalized.length) {
    throw new HttpsError('invalid-argument', 'villageIds cannot be empty.');
  }
  return normalized;
}

function getQrSecret(deps = {}) {
  return deps.qrSecret || DEFAULT_QR_SECRET;
}

function nowSeconds(clock = () => Date.now()) {
  return Math.floor(clock() / 1000);
}

function base64UrlEncode(value) {
  return Buffer.from(value, 'utf8').toString('base64url');
}

function base64UrlDecode(value) {
  return Buffer.from(value, 'base64url').toString('utf8');
}

function signQrPayload(payload, secret) {
  const payloadJson = JSON.stringify(payload);
  const encodedPayload = base64UrlEncode(payloadJson);
  const signature = crypto
    .createHmac('sha256', secret)
    .update(encodedPayload)
    .digest('base64url');
  return `${encodedPayload}.${signature}`;
}

function hashValue(value) {
  return crypto.createHash('sha256').update(String(value)).digest('hex');
}

function verifyQrTokenString(token, secret) {
  if (typeof token !== 'string' || !token.includes('.')) {
    throw new HttpsError('invalid-argument', 'QR token format is invalid.');
  }

  const [encodedPayload, providedSignature] = token.split('.');
  const expectedSignature = crypto
    .createHmac('sha256', secret)
    .update(encodedPayload)
    .digest('base64url');

  if (providedSignature !== expectedSignature) {
    throw new HttpsError('permission-denied', 'QR token signature is invalid.');
  }

  let payload;
  try {
    payload = JSON.parse(base64UrlDecode(encodedPayload));
  } catch {
    throw new HttpsError('invalid-argument', 'QR token payload is malformed.');
  }
  if (payload.version !== QR_TOKEN_VERSION) {
    throw new HttpsError('permission-denied', 'QR token version is unsupported.');
  }
  if (typeof payload.villageId !== 'string' || typeof payload.householdId !== 'string') {
    throw new HttpsError('invalid-argument', 'QR token payload is malformed.');
  }
  if (typeof payload.expiresAt !== 'number' || typeof payload.issuedAt !== 'number') {
    throw new HttpsError('invalid-argument', 'QR token timestamps are malformed.');
  }
  if (payload.expiresAt <= nowSeconds()) {
    throw new HttpsError('permission-denied', 'QR token has expired.');
  }

  return payload;
}

function createAuditEntry({
  actorUid,
  role,
  villageId,
  action,
  targetId,
  details = {},
  createdAt = new Date().toISOString(),
}) {
  return {
    actorUid,
    role,
    villageId,
    action,
    targetId: targetId || null,
    details,
    createdAt,
    schemaVersion: 1,
  };
}

module.exports = {
  ALLOWED_ROLES,
  REGION,
  QR_TOKEN_VERSION,
  createAuditEntry,
  createCallable,
  getAdmin,
  getQrSecret,
  normalizeVillageIds,
  requireAuth,
  requireRole,
  signQrPayload,
  hashValue,
  verifyQrTokenString,
  nowSeconds,
};
