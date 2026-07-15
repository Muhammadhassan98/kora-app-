import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.roomId,
    required super.userId,
    required super.username,
    super.avatarUrl,
    required super.content,
    required super.isVip,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      content: json['content'] as String,
      isVip: json['isVip'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'content': content,
      'isVip': isVip,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
