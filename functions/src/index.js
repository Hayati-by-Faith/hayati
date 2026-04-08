const { setUserClaims, setUserClaimsHandler } = require('./setUserClaims');
const { signQrToken, signQrTokenHandler } = require('./signQrToken');
const { verifyQrToken, verifyQrTokenHandler } = require('./verifyQrToken');
const { confirmAttendance, confirmAttendanceHandler } = require('./confirmAttendance');
const { auditLogWriter, auditLogWriterHandler } = require('./auditLogWriter');

module.exports = {
  setUserClaims,
  setUserClaimsHandler,
  signQrToken,
  signQrTokenHandler,
  verifyQrToken,
  verifyQrTokenHandler,
  confirmAttendance,
  confirmAttendanceHandler,
  auditLogWriter,
  auditLogWriterHandler,
};
