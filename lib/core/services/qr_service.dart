class QrService {
  const QrService();

  String buildResidentPayload({
    required String villageId,
    required String householdId,
  }) {
    return 'hayati://qr?villageId=$villageId&householdId=$householdId';
  }
}

