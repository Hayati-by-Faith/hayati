import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options_dev.dart' as dev_options;
import '../../firebase_options_prod.dart' as prod_options;
import '../../firebase_options_staging.dart' as staging_options;
import '../config/flavor_config.dart';

class FirebaseService {
  const FirebaseService._();

  static Future<FirebaseApp> initialize(AppFlavor flavor) async {
    if (Firebase.apps.isNotEmpty) {
      return Firebase.app();
    }

    final options = switch (flavor) {
      AppFlavor.dev => dev_options.DefaultFirebaseOptions.currentPlatform,
      AppFlavor.staging => staging_options.DefaultFirebaseOptions.currentPlatform,
      AppFlavor.prod => prod_options.DefaultFirebaseOptions.currentPlatform,
    };
    return Firebase.initializeApp(options: options);
  }
}

