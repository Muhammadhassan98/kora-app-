import '../../domain/entities/post_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.userId,
    required super.username,
    super.avatarUrl,
    required super.content,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
