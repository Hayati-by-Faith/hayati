import 'package:flutter/widgets.dart';

import 'core/config/flavor_config.dart';
import 'core/services/firebase_service.dart';

Future<void> bootstrap(AppFlavor flavor, Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize(flavor);
  runApp(app);
}

