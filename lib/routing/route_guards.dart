class RouteGuards {
  const RouteGuards._();

  static const String welcomeRoute = '/welcome';
  static const String phoneOtpRoute = '/phone-otp';
  static const String homeRoute = '/home';

  static const Set<String> publicRoutes = <String>{welcomeRoute, phoneOtpRoute};

  static bool isPhaseEnabled(bool enabled) => enabled;
}
