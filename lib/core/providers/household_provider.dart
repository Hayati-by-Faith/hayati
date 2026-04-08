import 'package:flutter_riverpod/legacy.dart';

import '../models/household.dart';

final householdProvider = StateProvider<Household?>((ref) {
  return Household(
    id: 'household-demo',
    villageId: 'abusir',
    ownerUid: 'resident-demo',
    name: 'أسرة نموذجية',
    householdSize: 4,
    address: 'أبوصير، الجيزة',
    comment: '...',
    latitude: 29.97,
    longitude: 31.20,
    geohash: 'staging-geohash',
    qrTokenId: 'qr-demo',
    schemaVersion: 1,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
});
