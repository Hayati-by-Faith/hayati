import 'package:freezed_annotation/freezed_annotation.dart';

part 'household.freezed.dart';
part 'household.g.dart';

@freezed
sealed class Household with _$Household {
  const factory Household({
    required String id,
    required String villageId,
    required String ownerUid,
    required String name,
    required int householdSize,
    required String address,
    required String comment,
    double? latitude,
    double? longitude,
    String? geohash,
    String? qrTokenId,
    DateTime? deletedAt,
    required int schemaVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Household;

  factory Household.fromJson(Map<String, dynamic> json) =>
      _$HouseholdFromJson(json);
}
