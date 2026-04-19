import 'package:flutter/foundation.dart';

import 'logger_service.dart';

typedef ZoneErrorHandler = void Function(Object error, StackTrace stack);

class CrashlyticsService {
  const CrashlyticsService();

  static Future<ZoneErrorHandler> install() async {
    return (Object error, StackTrace stack) {
      const AppLogger().log(
        'Unhandled web error',
        level: AppLogLevel.error,
        error: error,
        stackTrace: stack,
      );
      FlutterError.presentError(
        FlutterErrorDetails(exception: error, stack: stack),
      );
    };
  }
}
