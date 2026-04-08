const {
  setUserClaims,
  signQrToken,
  verifyQrToken,
  confirmAttendance,
  auditLogWriter,
} = require('./index');

test('exports all handlers', () => {
  expect(typeof setUserClaims).toBe('function');
  expect(typeof signQrToken).toBe('function');
  expect(typeof verifyQrToken).toBe('function');
  expect(typeof confirmAttendance).toBe('function');
  expect(typeof auditLogWriter).toBe('function');
});
