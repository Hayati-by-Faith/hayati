import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/features/onboarding/screens/phone_otp_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('renders phone otp screen', (tester) async {
    await pumpLocalizedScreen(tester, const PhoneOtpScreen());

    expect(find.text('تأكيد رقم الهاتف'), findsOneWidget);
    expect(find.text('رقم الهاتف'), findsOneWidget);
    expect(find.text('إرسال رمز التحقق'), findsOneWidget);
  });
}
