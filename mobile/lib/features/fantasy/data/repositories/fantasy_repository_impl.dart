import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/fantasy_squad_entity.dart';
import '../../domain/repositories/fantasy_repository.dart';
import '../datasources/fantasy_remote_data_source.dart';

@LazySingleton(as: FantasyRepository)
class FantasyRepositoryImpl implements FantasyRepository {
  final FantasyRemoteDataSource remoteDataSource;

  FantasyRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<PlayerEntity>>> getPlayers({
    String? position,
    String? club,
    String? search,
  }) async {
    try {
      final players = await remoteDataSource.getPlayers(
        position: position,
        club: club,
        search: search,
      );
      return Right(players);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FantasySquadEntity>> getSquad() async {
    try {
      final squad = await remoteDataSource.getSquad();
      return Right(squad);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FantasySquadEntity>> updateSquad({
    required List<String> playerIds,
  }) async {
    try {
      final squad = await remoteDataSource.updateSquad(playerIds: playerIds);
      return Right(squad);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
