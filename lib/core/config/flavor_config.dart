enum AppFlavor {
  dev,
  staging,
  prod;

  static AppFlavor fromEnvironment([String value = 'dev']) {
    return switch (value.toLowerCase()) {
      'staging' => AppFlavor.staging,
      'prod' => AppFlavor.prod,
      _ => AppFlavor.dev,
    };
  }

  String get label => switch (this) {
        AppFlavor.dev => 'dev',
        AppFlavor.staging => 'staging',
        AppFlavor.prod => 'prod',
      };
}

