import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/match_entity.dart';

abstract class MatchesRepository {
  Future<Either<Failure, List<MatchEntity>>> getMatches();
}
