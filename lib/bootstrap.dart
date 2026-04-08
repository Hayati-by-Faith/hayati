import 'dart:async';

import 'package:flutter/widgets.dart';

import 'core/config/flavor_config.dart';
import 'core/services/app_check_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/services/firebase_service.dart';

Future<void> bootstrap(AppFlavor flavor, Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize(flavor);
  await AppCheckService.activate(flavor);
  final zoneErrorHandler = await CrashlyticsService.install();
  runZonedGuarded(() {
    runApp(app);
  }, zoneErrorHandler);
}
