// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Household _$HouseholdFromJson(Map<String, dynamic> json) => _Household(
  id: json['id'] as String,
  villageId: json['villageId'] as String,
  ownerUid: json['ownerUid'] as String,
  name: json['name'] as String,
  householdSize: (json['householdSize'] as num).toInt(),
  address: json['address'] as String,
  comment: json['comment'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  geohash: json['geohash'] as String?,
  qrTokenId: json['qrTokenId'] as String?,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$HouseholdToJson(_Household instance) =>
    <String, dynamic>{
      'id': instance.id,
      'villageId': instance.villageId,
      'ownerUid': instance.ownerUid,
      'name': instance.name,
      'householdSize': instance.householdSize,
      'address': instance.address,
      'comment': instance.comment,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'geohash': instance.geohash,
      'qrTokenId': instance.qrTokenId,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'schemaVersion': instance.schemaVersion,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
