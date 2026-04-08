import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options_dev.dart' as dev_options;
import '../../firebase_options_prod.dart' as prod_options;
import '../../firebase_options_staging.dart' as staging_options;
import '../config/flavor_config.dart';

class FirebaseService {
  const FirebaseService._();

  static void validateOptions(FirebaseOptions options, AppFlavor flavor) {
    final invalidMarkers = <String>['TODO_', 'REPLACE'];
    final values = <String>[options.apiKey, options.projectId, options.appId];

    for (final value in values) {
      final normalized = value.toLowerCase();
      final hasMarker =
          invalidMarkers.any(value.contains) ||
          normalized.contains('placeholder');
      if (hasMarker) {
        throw StateError(
          'Firebase options not configured for flavor $flavor — run flutterfire configure',
        );
      }
    }
  }

  static Future<FirebaseApp> initialize(AppFlavor flavor) async {
    final options = switch (flavor) {
      AppFlavor.dev => dev_options.DefaultFirebaseOptions.currentPlatform,
      AppFlavor.staging =>
        staging_options.DefaultFirebaseOptions.currentPlatform,
      AppFlavor.prod => prod_options.DefaultFirebaseOptions.currentPlatform,
    };
    validateOptions(options, flavor);

    if (Firebase.apps.isNotEmpty) {
      return Firebase.app();
    }

    return Firebase.initializeApp(options: options);
  }
}
