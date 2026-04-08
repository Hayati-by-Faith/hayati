import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/core/config/flavor_config.dart';
import 'package:hayati/core/services/firebase_service.dart';

import 'package:hayati/firebase_options_dev.dart' as dev_options;

void main() {
  test('dev firebase options pass the placeholder guard', () {
    expect(
      () => FirebaseService.validateOptions(
        dev_options.DefaultFirebaseOptions.android,
        AppFlavor.dev,
      ),
      returnsNormally,
    );
  });
}
