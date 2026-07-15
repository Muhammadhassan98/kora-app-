import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/community_entity.dart';
import '../repositories/social_repository.dart';

@lazySingleton
class GetCommunitiesUseCase {
  final SocialRepository repository;

  GetCommunitiesUseCase(this.repository);

  Future<Either<Failure, List<CommunityEntity>>> call() {
    return repository.getCommunities();
  }
}
