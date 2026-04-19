import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/flavor_config.dart';
import 'bootstrap.dart';

Future<void> main() async {
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  await bootstrap(
    AppFlavor.prod,
    HayatiApp(config: AppConfig.fromFlavor(AppFlavor.prod)),
  );
}
