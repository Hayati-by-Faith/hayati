import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/features/village_picker/screens/village_picker_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('renders village picker screen', (tester) async {
    await pumpLocalizedScreen(tester, const VillagePickerScreen());

    expect(find.text('اختيار القرية'), findsOneWidget);
    expect(find.text('أبوصير'), findsOneWidget);
  });
}
