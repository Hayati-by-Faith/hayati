import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/core/services/qr_service.dart';

void main() {
  test('resident payload encodes village and household ids', () {
    final payload = QrService().buildResidentPayload(
      villageId: 'abusir',
      householdId: 'household-demo',
    );

    expect(payload, contains('villageId=abusir'));
    expect(payload, contains('householdId=household-demo'));
    expect(payload, startsWith('hayati://qr?'));
  });
}
