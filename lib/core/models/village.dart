import 'package:freezed_annotation/freezed_annotation.dart';

part 'village.freezed.dart';
part 'village.g.dart';

@freezed
sealed class Village with _$Village {
  const factory Village({
    required String id,
    required String name,
    required String nameEn,
    required String governorate,
    double? latitude,
    double? longitude,
    required Map<String, bool> phaseConfig,
    required bool featureKillSwitch,
    required Map<String, dynamic> stats,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int schemaVersion,
    required bool isActive,
  }) = _Village;

  factory Village.fromJson(Map<String, dynamic> json) =>
      _$VillageFromJson(json);
}
