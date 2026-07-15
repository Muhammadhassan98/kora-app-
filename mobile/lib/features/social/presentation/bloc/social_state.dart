import '../../domain/entities/post_entity.dart';
import '../../domain/entities/community_entity.dart';
import '../../domain/entities/chat_message_entity.dart';

abstract class SocialState {}

class SocialInitialState extends SocialState {}

class SocialLoadingState extends SocialState {}

class SocialLoadedState extends SocialState {
  final List<PostEntity> posts;
  final List<CommunityEntity> communities;

  SocialLoadedState({required this.posts, required this.communities});
}

class ChatLoadedState extends SocialState {
  final List<ChatMessageEntity> messages;

  ChatLoadedState(this.messages);
}

class SocialFailureState extends SocialState {
  final String message;

  SocialFailureState(this.message);
}
