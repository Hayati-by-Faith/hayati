import 'dart:developer' as developer;

enum AppLogLevel { debug, info, warning, error }

class AppLogger {
  const AppLogger();

  void log(
    String message, {
    AppLogLevel level = AppLogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'Hayati',
      level: switch (level) {
        AppLogLevel.debug => 500,
        AppLogLevel.info => 800,
        AppLogLevel.warning => 900,
        AppLogLevel.error => 1000,
      },
      error: error,
      stackTrace: stackTrace,
    );
  }
}

