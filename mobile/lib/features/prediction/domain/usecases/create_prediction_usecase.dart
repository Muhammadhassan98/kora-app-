import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/prediction_entity.dart';
import '../repositories/predictions_repository.dart';

@lazySingleton
class CreatePredictionUseCase {
  final PredictionsRepository repository;

  CreatePredictionUseCase(this.repository);

  Future<Either<Failure, PredictionEntity>> call({
    required String matchId,
    required String predictedWinner,
    required int predictedHomeScore,
    required int predictedAwayScore,
  }) async {
    return await repository.createPrediction(
      matchId: matchId,
      predictedWinner: predictedWinner,
      predictedHomeScore: predictedHomeScore,
      predictedAwayScore: predictedAwayScore,
    );
  }
}
