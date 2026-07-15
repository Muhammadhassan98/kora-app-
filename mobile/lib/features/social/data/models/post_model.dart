import '../../domain/entities/post_entity.dart';
import 'comment_model.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.username,
    super.avatarUrl,
    required super.content,
    required super.likesCount,
    required super.createdAt,
    required super.comments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final commentsList = json['comments'] as List<dynamic>? ?? [];
    return PostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      content: json['content'] as String,
      likesCount: json['likesCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      comments: commentsList.map((c) => CommentModel.fromJson(c as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'content': content,
      'likesCount': likesCount,
      'createdAt': createdAt.toIso8601String(),
      'comments': comments.map((c) => (c as CommentModel).toJson()).toList(),
    };
  }
}
