import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/community_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/social_remote_data_source.dart';

@LazySingleton(as: SocialRepository)
class SocialRepositoryImpl implements SocialRepository {
  final SocialRemoteDataSource remoteDataSource;

  SocialRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts() async {
    try {
      final list = await remoteDataSource.getPosts();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> createPost(String content) async {
    try {
      final post = await remoteDataSource.createPost(content);
      return Right(post);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> likePost(String postId) async {
    try {
      final post = await remoteDataSource.likePost(postId);
      return Right(post);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CommunityEntity>>> getCommunities() async {
    try {
      final list = await remoteDataSource.getCommunities();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getChatMessages(String roomId) async {
    try {
      final list = await remoteDataSource.getChatMessages(roomId);
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessageEntity>> sendChatMessage(String roomId, String content) async {
    try {
      final msg = await remoteDataSource.sendChatMessage(roomId, content);
      return Right(msg);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
