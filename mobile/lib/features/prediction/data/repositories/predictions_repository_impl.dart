import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prediction_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/predictions_repository.dart';
import '../datasources/predictions_remote_data_source.dart';

@LazySingleton(as: PredictionsRepository)
class PredictionsRepositoryImpl implements PredictionsRepository {
  final PredictionsRemoteDataSource remoteDataSource;

  PredictionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PredictionEntity>> createPrediction({
    required String matchId,
    required String predictedWinner,
    required int predictedHomeScore,
    required int predictedAwayScore,
  }) async {
    try {
      final prediction = await remoteDataSource.createPrediction(
        matchId: matchId,
        predictedWinner: predictedWinner,
        predictedHomeScore: predictedHomeScore,
        predictedAwayScore: predictedAwayScore,
      );
      return Right(prediction);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PredictionEntity>>> getMyPredictions() async {
    try {
      final list = await remoteDataSource.getMyPredictions();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProfileEntity>>> getLeaderboard() async {
    try {
      final list = await remoteDataSource.getLeaderboard();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
