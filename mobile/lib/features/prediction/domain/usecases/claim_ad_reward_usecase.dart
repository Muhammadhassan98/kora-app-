import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/economy_repository.dart';

@lazySingleton
class ClaimAdRewardUseCase {
  final EconomyRepository repository;

  ClaimAdRewardUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call() {
    return repository.claimAdReward();
  }
}
