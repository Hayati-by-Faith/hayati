import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/flavor_config.dart';
import 'bootstrap.dart';

Future<void> main() async {
  await bootstrap(
    AppFlavor.staging,
    HayatiApp(config: AppConfig.fromFlavor(AppFlavor.staging)),
  );
}
