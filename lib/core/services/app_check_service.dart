import 'package:firebase_app_check/firebase_app_check.dart';

import '../config/flavor_config.dart';

class AppCheckService {
  const AppCheckService();

  static Future<void> activate(AppFlavor flavor) async {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: flavor == AppFlavor.dev
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: flavor == AppFlavor.dev
          ? const AppleDebugProvider()
          : const AppleAppAttestProvider(),
    );
  }
}
