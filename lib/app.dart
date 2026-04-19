import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/constants/business_constants.dart';
import 'core/theme/app_theme.dart';
import 'gen_l10n/app_localizations.dart';
import 'routing/app_router.dart';

class HayatiApp extends ConsumerWidget {
  const HayatiApp({
    super.key,
    required this.config,
  });

  final AppConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: BusinessConstants.appName,
      locale: const Locale(BusinessConstants.defaultLocaleCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

