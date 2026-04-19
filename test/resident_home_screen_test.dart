import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/features/home/screens/resident_home_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('renders resident home screen', (tester) async {
    await pumpLocalizedScreen(tester, const ResidentHomeScreen());

    expect(find.text('الصفحة الرئيسية للمقيم'), findsOneWidget);
    expect(find.text('تغذية المدونة'), findsOneWidget);
  });
}
