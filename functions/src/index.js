const { setUserClaims } = require('./setUserClaims');
const { signQrToken } = require('./signQrToken');
const { verifyQrToken } = require('./verifyQrToken');
const { confirmAttendance } = require('./confirmAttendance');
const { auditLogWriter } = require('./auditLogWriter');

module.exports = {
  setUserClaims,
  signQrToken,
  verifyQrToken,
  confirmAttendance,
  auditLogWriter,
};
