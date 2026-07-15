import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/social_repository.dart';

@lazySingleton
class CreatePostUseCase {
  final SocialRepository repository;

  CreatePostUseCase(this.repository);

  Future<Either<Failure, PostEntity>> call(String content) {
    return repository.createPost(content);
  }
}
