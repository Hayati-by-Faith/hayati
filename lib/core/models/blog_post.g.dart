// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blog_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BlogPost _$BlogPostFromJson(Map<String, dynamic> json) => _BlogPost(
  id: json['id'] as String,
  villageId: json['villageId'] as String,
  title: json['title'] as String,
  summary: json['summary'] as String,
  body: json['body'] as String,
  audioUrl: json['audioUrl'] as String?,
  imageUrl: json['imageUrl'] as String?,
  isPublished: json['isPublished'] as bool,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  createdBy: json['createdBy'] as String,
);

Map<String, dynamic> _$BlogPostToJson(_BlogPost instance) => <String, dynamic>{
  'id': instance.id,
  'villageId': instance.villageId,
  'title': instance.title,
  'summary': instance.summary,
  'body': instance.body,
  'audioUrl': instance.audioUrl,
  'imageUrl': instance.imageUrl,
  'isPublished': instance.isPublished,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'schemaVersion': instance.schemaVersion,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'createdBy': instance.createdBy,
};
