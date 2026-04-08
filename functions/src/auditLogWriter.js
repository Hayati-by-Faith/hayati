const { HttpsError } = require('firebase-functions/v2/https');
const {
  createAuditEntry,
  createCallable,
  getAdmin,
  requireAuth,
  requireRole,
} = require('./runtime');

async function auditLogWriterHandler(request, deps = {}) {
  const actorUid = requireAuth(request);
  const role = requireRole(request, ['admin', 'super_admin']);
  const data = request.data || {};
  const villageId = typeof data.villageId === 'string' ? data.villageId.trim() : data.villageId;
  const action = typeof data.action === 'string' ? data.action.trim() : data.action;

  if (typeof villageId !== 'string' || !villageId.trim()) {
    throw new HttpsError('invalid-argument', 'villageId is required.');
  }
  if (typeof action !== 'string' || !action.trim()) {
    throw new HttpsError('invalid-argument', 'action is required.');
  }

  const admin = deps.admin || getAdmin();
  const firestore = admin.firestore();
  const createdAt = deps.clock ? new Date(deps.clock()) : new Date();
  const entry = createAuditEntry({
    actorUid,
    role,
    villageId,
    action,
    targetId: typeof data.targetId === 'string' ? data.targetId : null,
    details:
      data.details && typeof data.details === 'object' && !Array.isArray(data.details)
        ? data.details
        : {},
    createdAt: createdAt.toISOString(),
  });

  const ref = firestore.collection('audit_log').doc();
  await ref.set(entry);

  return {
    ok: true,
    auditLogId: ref.id,
    entry,
  };
}

const auditLogWriter = createCallable((request) => auditLogWriterHandler(request));

module.exports = {
  auditLogWriter,
  auditLogWriterHandler,
};
