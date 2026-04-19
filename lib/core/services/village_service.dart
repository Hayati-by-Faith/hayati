import '../models/village.dart';

class VillageService {
  const VillageService();

  List<Village> mockVillages() {
    return [
      Village(
        id: 'abusir',
        name: 'أبوصير',
        nameEn: 'Abusir',
        governorate: 'الجيزة',
        latitude: 29.97,
        longitude: 31.20,
        phaseConfig: {
          'phase_1_enrollment': true,
          'phase_2_services': false,
          'phase_3_profile': false,
          'phase_4_blog': true,
          'phase_5_community_watch': false,
          'phase_6_training': false,
        },
        featureKillSwitch: false,
        stats: {'enrolledHouseholds': 0, 'activeUsers30d': 0},
        createdBy: 'bootstrap',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        schemaVersion: 1,
        isActive: true,
      ),
    ];
  }
}
