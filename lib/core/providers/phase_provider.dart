import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/feature_flags.dart';
import '../services/phase_gate_service.dart';
import 'village_provider.dart';

final phaseGateServiceProvider = Provider<PhaseGateService>((ref) {
  return const PhaseGateService();
});

final phaseProvider = Provider<PhaseState>((ref) {
  final village = ref.watch(activeVillageProvider);
  if (village == null) {
    return const PhaseState.initial();
  }
  return ref.watch(phaseGateServiceProvider).fromVillage(village);
});

final phaseEnabledProvider = Provider.family<bool, String>((ref, key) {
  return ref.watch(phaseProvider).isEnabled(key);
});

final phase1Provider = Provider<bool>((ref) {
  return ref.watch(phaseEnabledProvider(FeatureFlags.phase1Enrollment));
});
