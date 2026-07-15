import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prediction_entity.dart';
import '../../domain/entities/profile_entity.dart';

abstract class PredictionsRepository {
  Future<Either<Failure, PredictionEntity>> createPrediction({
    required String matchId,
    required String predictedWinner,
    required int predictedHomeScore,
    required int predictedAwayScore,
  });

  Future<Either<Failure, List<PredictionEntity>>> getMyPredictions();

  Future<Either<Failure, List<ProfileEntity>>> getLeaderboard();
}
