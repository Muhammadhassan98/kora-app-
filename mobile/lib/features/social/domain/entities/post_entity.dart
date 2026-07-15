class CommentEntity {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String content;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.content,
    required this.createdAt,
  });
}

class PostEntity {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String content;
  final int likesCount;
  final DateTime createdAt;
  final List<CommentEntity> comments;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.content,
    required this.likesCount,
    required this.createdAt,
    required this.comments,
  });
}
