import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/social_repository.dart';

@lazySingleton
class GetPostsUseCase {
  final SocialRepository repository;

  GetPostsUseCase(this.repository);

  Future<Either<Failure, List<PostEntity>>> call() {
    return repository.getPosts();
  }
}
