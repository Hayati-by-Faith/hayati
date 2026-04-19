import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/core/widgets/phase_placeholder_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('renders localized phase_locked strings in Arabic', (
    tester,
  ) async {
    await pumpLocalizedScreen(tester, const PhasePlaceholderScreen());

    expect(find.text('هذه المرحلة مغلقة'), findsWidgets);
    expect(find.text('القرية الحالية لم تفعل هذه الميزة بعد.'), findsOneWidget);
  });
}
