import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/features/onboarding/screens/consent_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('renders consent screen', (tester) async {
    await pumpLocalizedScreen(tester, const ConsentScreen());

    expect(find.text('الموافقة والشروط'), findsOneWidget);
    expect(find.text('موافقة ومتابعة'), findsOneWidget);
  });
}
