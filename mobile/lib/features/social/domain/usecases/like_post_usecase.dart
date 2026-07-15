import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/social_repository.dart';

@lazySingleton
class LikePostUseCase {
  final SocialRepository repository;

  LikePostUseCase(this.repository);

  Future<Either<Failure, PostEntity>> call(String postId) {
    return repository.likePost(postId);
  }
}
