abstract class SocialEvent {}

class FetchPostsAndCommunitiesEvent extends SocialEvent {}

class CreatePostEvent extends SocialEvent {
  final String content;

  CreatePostEvent(this.content);
}

class LikePostEvent extends SocialEvent {
  final String postId;

  LikePostEvent(this.postId);
}

class FetchChatMessagesEvent extends SocialEvent {
  final String roomId;

  FetchChatMessagesEvent(this.roomId);
}

class SendChatMessageEvent extends SocialEvent {
  final String roomId;
  final String content;

  SendChatMessageEvent(this.roomId, this.content);
}
