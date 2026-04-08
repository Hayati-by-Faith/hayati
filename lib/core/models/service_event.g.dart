// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServiceEvent _$ServiceEventFromJson(Map<String, dynamic> json) =>
    _ServiceEvent(
      id: json['id'] as String,
      villageId: json['villageId'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      createdBy: json['createdBy'] as String,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ServiceEventToJson(_ServiceEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'villageId': instance.villageId,
      'title': instance.title,
      'type': instance.type,
      'description': instance.description,
      'startAt': instance.startAt.toIso8601String(),
      'endAt': instance.endAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'schemaVersion': instance.schemaVersion,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
