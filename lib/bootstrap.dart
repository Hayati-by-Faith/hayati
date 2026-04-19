import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/flavor_config.dart';
import 'core/constants/business_constants.dart';
import 'core/services/app_check_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/performance_service.dart';

Future<void> bootstrap(AppFlavor flavor, Widget app) async {
  late final ZoneErrorHandler zoneErrorHandler;
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FirebaseService.initialize(flavor);
    await FirebaseAuth.instance.setLanguageCode(
      BusinessConstants.defaultLocaleCode,
    );
    await AppCheckService.activate(flavor);
    await PerformanceService.activate();
    zoneErrorHandler = await CrashlyticsService.install();
    runApp(ProviderScope(child: app));
  }, (error, stack) {
    zoneErrorHandler(error, stack);
  });
}
