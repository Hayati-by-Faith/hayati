import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/features/home/screens/staff_home_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('renders staff home screen', (tester) async {
    await pumpLocalizedScreen(tester, const StaffHomeScreen());

    expect(find.text('الصفحة الرئيسية للموظفين'), findsNWidgets(2));
  });
}
