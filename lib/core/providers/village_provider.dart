import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/village.dart';
import '../services/village_service.dart';

final villageServiceProvider = Provider<VillageService>((ref) {
  return const VillageService();
});

final villagesProvider = Provider<List<Village>>((ref) {
  return ref.watch(villageServiceProvider).mockVillages();
});

final activeVillageProvider = StateProvider<Village?>((ref) {
  final villages = ref.watch(villagesProvider);
  return villages.isEmpty ? null : villages.first;
});
