const crypto = require('crypto');
const { HttpsError } = require('firebase-functions/v2/https');
const {
  QR_TOKEN_VERSION,
  createAuditEntry,
  createCallable,
  getAdmin,
  getQrSecret,
  nowSeconds,
  qrHmacSecret,
  requireAuth,
  signQrPayload,
} = require('./runtime');

const ENROLL_LIMIT = 5;
const ENROLL_WINDOW_SECONDS = 60 * 60;
const QR_DEFAULT_TTL_SECONDS = 60 * 60 * 24 * 365 * 10;
const NAME_MAX = 200;
const ADDRESS_MAX = 500;
const COMMENT_MAX = 1000;
const HOUSEHOLD_SIZE_MAX = 50;

async function enforceEnrollRateLimit(admin, uid, nowSecondsValue) {
  const firestore = admin.firestore();
  const bucket = Math.floor(nowSecondsValue / ENROLL_WINDOW_SECONDS);
  const limitId = `enroll_${uid}_${bucket}`;
  const ref = firestore.collection('rate_limits').doc(limitId);

  await firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const data = snapshot.exists ? snapshot.data() || {} : {};
    const currentCount = typeof data.count === 'number' ? data.count : 0;

    if (currentCount >= ENROLL_LIMIT) {
      throw new HttpsError(
        'resource-exhausted',
        'Enrollment rate limit exceeded.',
      );
    }

    transaction.set(
      ref,
      {
        uid,
        type: 'enroll',
        windowBucket: bucket,
        count: currentCount + 1,
        updatedAt: new Date(nowSecondsValue * 1000),
      },
      { merge: true },
    );
  });
}

function normalizeGpsInput(rawGps, rawGeohash) {
  const gpsAbsent = rawGps === undefined || rawGps === null;
  const geohashAbsent = rawGeohash === undefined || rawGeohash === null;

  if (gpsAbsent && geohashAbsent) {
    return { gps: null, geohash: null };
  }

  if (gpsAbsent !== geohashAbsent) {
    throw new HttpsError(
      'invalid-argument',
      'gps and geohash must both be provided or both omitted.',
    );
  }

  if (
    typeof rawGps !== 'object' ||
    typeof rawGps.latitude !== 'number' ||
    typeof rawGps.longitude !== 'number' ||
    Number.isNaN(rawGps.latitude) ||
    Number.isNaN(rawGps.longitude)
  ) {
    throw new HttpsError(
      'invalid-argument',
      'gps must have numeric latitude and longitude.',
    );
  }
  if (rawGps.latitude < -90 || rawGps.latitude > 90) {
    throw new HttpsError(
      'invalid-argument',
      'gps.latitude must be between -90 and 90.',
    );
  }
  if (rawGps.longitude < -180 || rawGps.longitude > 180) {
    throw new HttpsError(
      'invalid-argument',
      'gps.longitude must be between -180 and 180.',
    );
  }

  if (typeof rawGeohash !== 'string' || !rawGeohash.trim()) {
    throw new HttpsError(
      'invalid-argument',
      'geohash must be a non-empty string when gps is provided.',
    );
  }

  return {
    gps: { latitude: rawGps.latitude, longitude: rawGps.longitude },
    geohash: rawGeohash.trim(),
  };
}

function buildQrToken({ uid, villageId, issuedAt, ttlSeconds, nonce, secret }) {
  const payload = {
    version: QR_TOKEN_VERSION,
    villageId,
    householdId: uid,
    subjectUid: uid,
    issuedAt,
    expiresAt: issuedAt + ttlSeconds,
    issuerUid: uid,
    nonce,
  };
  return { token: signQrPayload(payload, secret), payload };
}

async function createHouseholdHandler(request, deps = {}) {
  const uid = requireAuth(request);
  const data = request.data || {};

  const villageId =
    typeof data.villageId === 'string' ? data.villageId.trim() : '';
  const name = typeof data.name === 'string' ? data.name.trim() : '';
  const address = typeof data.address === 'string' ? data.address.trim() : '';
  const comment = typeof data.comment === 'string' ? data.comment.trim() : '';
  const householdSize =
    typeof data.householdSize === 'number' && Number.isFinite(data.householdSize)
      ? Math.trunc(data.householdSize)
      : NaN;

  if (!villageId) {
    throw new HttpsError('invalid-argument', 'villageId is required.');
  }
  if (!name || name.length >= NAME_MAX) {
    throw new HttpsError(
      'invalid-argument',
      `name is required and must be shorter than ${NAME_MAX} characters.`,
    );
  }
  if (!address || address.length >= ADDRESS_MAX) {
    throw new HttpsError(
      'invalid-argument',
      `address is required and must be shorter than ${ADDRESS_MAX} characters.`,
    );
  }
  if (comment.length >= COMMENT_MAX) {
    throw new HttpsError(
      'invalid-argument',
      `comment must be shorter than ${COMMENT_MAX} characters.`,
    );
  }
  if (
    !Number.isFinite(householdSize) ||
    householdSize <= 0 ||
    householdSize >= HOUSEHOLD_SIZE_MAX
  ) {
    throw new HttpsError(
      'invalid-argument',
      `householdSize must be a positive integer under ${HOUSEHOLD_SIZE_MAX}.`,
    );
  }

  const { gps, geohash } = normalizeGpsInput(data.gps, data.geohash);

  const admin = deps.admin || getAdmin();
  const firestore = admin.firestore();
  const issuedAt = nowSeconds(deps.clock);
  const ttlSeconds =
    typeof deps.qrTtlSeconds === 'number'
      ? deps.qrTtlSeconds
      : QR_DEFAULT_TTL_SECONDS;

  await enforceEnrollRateLimit(admin, uid, issuedAt);

  const householdRef = firestore.collection('households').doc(uid);
  const existingSnap = await householdRef.get();

  const nonce =
    typeof deps.nonce === 'string' && deps.nonce.trim()
      ? deps.nonce.trim()
      : crypto.randomBytes(16).toString('hex');
  const secret = getQrSecret(deps);

  if (existingSnap.exists) {
    const existing = existingSnap.data() || {};
    if (existing.ownerUid !== uid) {
      throw new HttpsError(
        'already-exists',
        'A household for this user already exists and is owned by another user.',
      );
    }
    const { token } = buildQrToken({
      uid,
      villageId: existing.villageId || villageId,
      issuedAt,
      ttlSeconds,
      nonce,
      secret,
    });
    return {
      ok: true,
      householdId: uid,
      qrToken: token,
      idempotent: true,
    };
  }

  const { token: qrToken } = buildQrToken({
    uid,
    villageId,
    issuedAt,
    ttlSeconds,
    nonce,
    secret,
  });

  const createdAt = new Date(issuedAt * 1000).toISOString();
  const serverTimestamp = admin.firestore.FieldValue.serverTimestamp();
  const household = {
    ownerUid: uid,
    villageId,
    name,
    address,
    householdSize,
    comment: comment || null,
    gps: gps ? new admin.firestore.GeoPoint(gps.latitude, gps.longitude) : null,
    geohash: geohash || null,
    qrTokenId: nonce,
    schemaVersion: 1,
    createdAt: serverTimestamp,
    updatedAt: serverTimestamp,
  };

  const auditEntries = [
    {
      ref: firestore.collection('audit_log').doc(),
      data: createAuditEntry({
        actorUid: uid,
        role: 'function:enrollment',
        villageId,
        action: 'household.create',
        targetId: uid,
        details: { gpsProvided: gps != null },
        createdAt,
      }),
    },
    {
      ref: firestore.collection('audit_log').doc(),
      data: createAuditEntry({
        actorUid: uid,
        role: 'function:enrollment',
        villageId,
        action: 'qr.issue',
        targetId: uid,
        details: { nonce },
        createdAt,
      }),
    },
    {
      ref: firestore.collection('audit_log').doc(),
      data: createAuditEntry({
        actorUid: uid,
        role: 'function:enrollment',
        villageId,
        action: 'claims.set',
        targetId: uid,
        details: { role: 'resident', villageIds: [villageId] },
        createdAt,
      }),
    },
  ];

  const batch = firestore.batch();
  batch.set(householdRef, household);
  for (const entry of auditEntries) {
    batch.set(entry.ref, { ...entry.data, createdAt: serverTimestamp });
  }
  await batch.commit();

  await admin.auth().setCustomUserClaims(uid, {
    role: 'resident',
    villageIds: [villageId],
  });

  return {
    ok: true,
    householdId: uid,
    qrToken,
    idempotent: false,
  };
}

const createHousehold = createCallable(
  (request) => createHouseholdHandler(request),
  [qrHmacSecret],
);

module.exports = {
  createHousehold,
  createHouseholdHandler,
};
