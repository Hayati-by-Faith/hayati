// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'village.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Village _$VillageFromJson(Map<String, dynamic> json) => _Village(
  id: json['id'] as String,
  name: json['name'] as String,
  nameEn: json['nameEn'] as String,
  governorate: json['governorate'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  phaseConfig: Map<String, bool>.from(json['phaseConfig'] as Map),
  featureKillSwitch: json['featureKillSwitch'] as bool,
  stats: json['stats'] as Map<String, dynamic>,
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$VillageToJson(_Village instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nameEn': instance.nameEn,
  'governorate': instance.governorate,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'phaseConfig': instance.phaseConfig,
  'featureKillSwitch': instance.featureKillSwitch,
  'stats': instance.stats,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'schemaVersion': instance.schemaVersion,
  'isActive': instance.isActive,
};
