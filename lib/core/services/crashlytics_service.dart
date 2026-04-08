import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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

typedef ZoneErrorHandler = void Function(Object error, StackTrace stack);
