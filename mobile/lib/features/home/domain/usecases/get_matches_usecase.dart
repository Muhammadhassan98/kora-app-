import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/match_entity.dart';
import '../repositories/matches_repository.dart';

@lazySingleton
class GetMatchesUseCase {
  final MatchesRepository repository;

  GetMatchesUseCase(this.repository);

  Future<Either<Failure, List<MatchEntity>>> call() async {
    return await repository.getMatches();
  }
}
