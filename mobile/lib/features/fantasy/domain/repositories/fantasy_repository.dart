import 'package:dartz/dartz.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/player_entity.dart';
import '../entities/fantasy_squad_entity.dart';

abstract class FantasyRepository {
  Future<Either<Failure, List<PlayerEntity>>> getPlayers({
    String? position,
    String? club,
    String? search,
  });

  Future<Either<Failure, FantasySquadEntity>> getSquad();

  Future<Either<Failure, FantasySquadEntity>> updateSquad({
    required List<String> playerIds,
  });
}
