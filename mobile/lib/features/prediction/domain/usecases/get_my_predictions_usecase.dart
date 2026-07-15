import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/prediction_entity.dart';
import '../repositories/predictions_repository.dart';

@lazySingleton
class GetMyPredictionsUseCase {
  final PredictionsRepository repository;

  GetMyPredictionsUseCase(this.repository);

  Future<Either<Failure, List<PredictionEntity>>> call() async {
    return await repository.getMyPredictions();
  }
}
