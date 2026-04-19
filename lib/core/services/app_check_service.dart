import 'package:flutter/foundation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import '../config/flavor_config.dart';

class AppCheckService {
  const AppCheckService();

  static const String _webSiteKey = String.fromEnvironment(
    'FIREBASE_WEB_APPCHECK_SITE_KEY',
    defaultValue: '',
  );

  static Future<void> activate(AppFlavor flavor) async {
    if (kIsWeb) {
      final webProvider = kDebugMode
          ? WebDebugProvider()
          : (_webSiteKey.isEmpty
                ? throw StateError(
                    'FIREBASE_WEB_APPCHECK_SITE_KEY is required for non-debug web builds',
                  )
                : ReCaptchaV3Provider(_webSiteKey));
      await FirebaseAppCheck.instance.activate(providerWeb: webProvider);
      return;
    }

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
