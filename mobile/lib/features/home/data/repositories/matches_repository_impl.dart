import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/matches_repository.dart';
import '../datasources/matches_remote_data_source.dart';

@LazySingleton(as: MatchesRepository)
class MatchesRepositoryImpl implements MatchesRepository {
  final MatchesRemoteDataSource remoteDataSource;

  MatchesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MatchEntity>>> getMatches() async {
    try {
      final matches = await remoteDataSource.getMatches();
      return Right(matches);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
