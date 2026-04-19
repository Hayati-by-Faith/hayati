import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

typedef ZoneErrorHandler = void Function(Object error, StackTrace stack);

class CrashlyticsService {
  const CrashlyticsService();

  static Future<ZoneErrorHandler> install() async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    return (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    };
  }
}
