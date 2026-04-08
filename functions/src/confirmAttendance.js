const { HttpsError } = require('firebase-functions/v2/https');
const {
  createAuditEntry,
  createCallable,
  getAdmin,
  hashValue,
  getQrSecret,
  requireAuth,
  requireRole,
  verifyQrTokenString,
} = require('./runtime');

async function confirmAttendanceHandler(request, deps = {}) {
  const actorUid = requireAuth(request);
  const role = requireRole(request, [
    'field_worker',
    'health_worker',
    'service_provider',
    'admin',
    'super_admin',
  ]);

  const data = request.data || {};
  const serviceId = data.serviceId;
  const token = data.token;

  if (typeof serviceId !== 'string' || !serviceId.trim()) {
    throw new HttpsError('invalid-argument', 'serviceId is required.');
  }
  if (typeof token !== 'string' || !token.trim()) {
    throw new HttpsError('invalid-argument', 'token is required.');
  }

  const payload = verifyQrTokenString(token, getQrSecret(deps));
  if (typeof data.villageId === 'string' && data.villageId !== payload.villageId) {
    throw new HttpsError('permission-denied', 'Village does not match the QR token.');
  }

  const admin = deps.admin || getAdmin();
  const firestore = admin.firestore();
  const now = deps.clock ? new Date(deps.clock()) : new Date();

  const participation = {
    villageId: payload.villageId,
    householdId: payload.householdId,
    residentUid: payload.issuerUid,
    serviceId,
    confirmedByUid: actorUid,
    confirmedByRole: role,
    qrTokenHash: hashValue(token),
    status: 'confirmed',
    confirmedAt: now,
    schemaVersion: 1,
  };

  const auditEntry = createAuditEntry({
    actorUid,
    role,
    villageId: payload.villageId,
    action: 'confirm_attendance',
    targetId: serviceId,
    details: {
      householdId: payload.householdId,
      residentUid: payload.issuerUid,
    },
    createdAt: now.toISOString(),
  });

  const batch = firestore.batch();
  const participationRef = firestore.collection('participations').doc();
  const auditRef = firestore.collection('audit_log').doc();
  batch.set(participationRef, participation);
  batch.set(auditRef, auditEntry);
  await batch.commit();

  return {
    ok: true,
    participationId: participationRef.id,
    auditLogId: auditRef.id,
    participation,
    auditEntry,
  };
}

const confirmAttendance = createCallable((request) => confirmAttendanceHandler(request));

module.exports = {
  confirmAttendance,
  confirmAttendanceHandler,
};
