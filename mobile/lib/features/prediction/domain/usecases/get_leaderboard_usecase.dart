import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/predictions_repository.dart';

@lazySingleton
class GetLeaderboardUseCase {
  final PredictionsRepository repository;

  GetLeaderboardUseCase(this.repository);

  Future<Either<Failure, List<ProfileEntity>>> call() async {
    return await repository.getLeaderboard();
  }
}
