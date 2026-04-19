import 'package:flutter/foundation.dart';
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  const PerformanceService();

  static Future<void> activate() async {
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(
      kIsWeb || !kDebugMode,
    );
  }
}
