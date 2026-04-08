class TimeoutConstants {
  const TimeoutConstants._();

  static const Duration otpTimeout = Duration(seconds: 60);
  static const Duration networkTimeout = Duration(seconds: 20);
  static const Duration syncRetryDelay = Duration(seconds: 3);
}

