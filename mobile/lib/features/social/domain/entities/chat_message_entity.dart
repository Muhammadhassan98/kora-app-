class ChatMessageEntity {
  final String id;
  final String roomId;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String content;
  final bool isVip;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.content,
    required this.isVip,
    required this.createdAt,
  });
}
