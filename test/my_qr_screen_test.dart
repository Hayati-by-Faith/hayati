import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/features/qr/screens/my_qr_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('renders my qr screen', (tester) async {
    await pumpLocalizedScreen(tester, const MyQrScreen());

    expect(find.text('رمز QR الخاص بي'), findsOneWidget);
    expect(find.text('مشاركة'), findsOneWidget);
    expect(find.text('حفظ في المعرض'), findsOneWidget);
  });
}

