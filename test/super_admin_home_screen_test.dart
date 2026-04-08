import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/features/home/screens/super_admin_home_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('renders super admin home screen', (tester) async {
    await pumpLocalizedScreen(tester, const SuperAdminHomeScreen());

    expect(find.text('الصفحة الرئيسية للسوبر أدمن'), findsNWidgets(2));
  });
}
