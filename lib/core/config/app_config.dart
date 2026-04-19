import 'flavor_config.dart';

class AppConfig {
  const AppConfig({required this.flavor, required this.isProduction});

  final AppFlavor flavor;
  final bool isProduction;

  String get buildFlavor => flavor.label;

  factory AppConfig.fromFlavor(AppFlavor flavor) {
    return AppConfig(flavor: flavor, isProduction: flavor == AppFlavor.prod);
  }
}
