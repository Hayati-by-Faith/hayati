import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/features/enrollment/screens/enrollment_success_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('renders enrollment success screen', (tester) async {
    await pumpLocalizedScreen(tester, const EnrollmentSuccessScreen());

    expect(find.text('اكتمل التسجيل'), findsOneWidget);
    expect(find.text('بطاقة QR الخاصة بك جاهزة.'), findsOneWidget);
  });
}

