import 'core/config/flavor_config.dart';
import 'main_dev.dart' as dev;
import 'main_prod.dart' as prod;
import 'main_staging.dart' as staging;

Future<void> main() async {
  final flavor = AppFlavor.fromEnvironment(
    const String.fromEnvironment('FLAVOR', defaultValue: 'dev'),
  );

  switch (flavor) {
    case AppFlavor.dev:
      await dev.main();
    case AppFlavor.staging:
      await staging.main();
    case AppFlavor.prod:
      await prod.main();
  }
}
