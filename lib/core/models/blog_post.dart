import 'package:freezed_annotation/freezed_annotation.dart';

part 'blog_post.freezed.dart';
part 'blog_post.g.dart';

@freezed
sealed class BlogPost with _$BlogPost {
  const factory BlogPost({
    required String id,
    required String villageId,
    required String title,
    required String summary,
    required String body,
    String? audioUrl,
    String? imageUrl,
    required bool isPublished,
    DateTime? deletedAt,
    required int schemaVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String createdBy,
  }) = _BlogPost;

  factory BlogPost.fromJson(Map<String, dynamic> json) =>
      _$BlogPostFromJson(json);
}
