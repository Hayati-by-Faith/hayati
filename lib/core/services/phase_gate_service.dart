import '../models/village.dart';

class PhaseState {
  const PhaseState({
    required this.flags,
  });

  final Map<String, bool> flags;

  const PhaseState.initial()
      : flags = const {
          'phase_1_enrollment': true,
          'phase_2_services': false,
          'phase_3_profile': false,
          'phase_4_blog': true,
          'phase_5_community_watch': false,
          'phase_6_training': false,
        };

  bool isEnabled(String key) => flags[key] ?? false;
}

class PhaseGateService {
  const PhaseGateService();

  PhaseState fromVillage(Village village) {
    return PhaseState(flags: village.phaseConfig);
  }
}

