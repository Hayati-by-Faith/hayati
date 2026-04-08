import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/features/onboarding/screens/welcome_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('renders welcome screen', (tester) async {
    await pumpLocalizedScreen(tester, const WelcomeScreen());

    expect(find.text('أهلاً بك في حياتي'), findsOneWidget);
    expect(find.text('بدء التسجيل'), findsOneWidget);
  });
}

