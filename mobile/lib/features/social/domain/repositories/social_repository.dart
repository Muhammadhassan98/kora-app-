import 'package:dartz/dartz.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/post_entity.dart';
import '../entities/community_entity.dart';
import '../entities/chat_message_entity.dart';

abstract class SocialRepository {
  Future<Either<Failure, List<PostEntity>>> getPosts();
  Future<Either<Failure, PostEntity>> createPost(String content);
  Future<Either<Failure, PostEntity>> likePost(String postId);
  Future<Either<Failure, List<CommunityEntity>>> getCommunities();
  Future<Either<Failure, List<ChatMessageEntity>>> getChatMessages(String roomId);
  Future<Either<Failure, ChatMessageEntity>> sendChatMessage(String roomId, String content);
}
