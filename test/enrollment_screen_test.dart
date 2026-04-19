import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/features/enrollment/screens/enrollment_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('renders enrollment screen', (tester) async {
    await pumpLocalizedScreen(tester, const EnrollmentScreen());

    expect(find.text('استمارة التسجيل'), findsOneWidget);
    expect(find.text('الاسم بالعربية'), findsOneWidget);
    expect(find.text('حجم الأسرة'), findsOneWidget);
  });
}
