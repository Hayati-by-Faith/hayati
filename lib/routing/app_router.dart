import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/auth_provider.dart';
import '../core/utils/localization.dart';
import '../features/enrollment/screens/enrollment_screen.dart';
import '../features/enrollment/screens/enrollment_success_screen.dart';
import '../features/home/screens/resident_home_screen.dart';
import '../features/home/screens/staff_home_screen.dart';
import '../features/home/screens/super_admin_home_screen.dart';
import '../features/onboarding/screens/consent_screen.dart';
import '../features/onboarding/screens/phone_otp_screen.dart';
import '../features/onboarding/screens/welcome_screen.dart';
import '../features/qr/screens/my_qr_screen.dart';
import '../features/qr/screens/qr_scanner_screen.dart';
import '../features/village_picker/screens/village_picker_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authSessionProvider);
  return GoRouter(
    initialLocation: '/welcome',
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l('not_found_title'))),
        body: Center(
          child: Text(
            context.l('not_found_body'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/phone-otp',
        builder: (context, state) => const PhoneOtpScreen(),
      ),
      GoRoute(
        path: '/consent',
        builder: (context, state) => const ConsentScreen(),
      ),
      GoRoute(
        path: '/enrollment',
        builder: (context, state) => const EnrollmentScreen(),
      ),
      GoRoute(
        path: '/enrollment/success',
        builder: (context, state) => const EnrollmentSuccessScreen(),
      ),
      GoRoute(
        path: '/qr',
        builder: (context, state) => const MyQrScreen(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => switch (session.role) {
          'super_admin' => const SuperAdminHomeScreen(),
          'field_worker' ||
          'health_worker' ||
          'data_collector' ||
          'service_provider' =>
            const StaffHomeScreen(),
          _ => const ResidentHomeScreen(),
        },
      ),
      GoRoute(
        path: '/village-picker',
        builder: (context, state) => const VillagePickerScreen(),
      ),
    ],
  );
});

