import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/player_entity.dart';
import '../repositories/fantasy_repository.dart';

@lazySingleton
class GetPlayersUseCase {
  final FantasyRepository repository;

  GetPlayersUseCase(this.repository);

  Future<Either<Failure, List<PlayerEntity>>> call({
    String? position,
    String? club,
    String? search,
  }) {
    return repository.getPlayers(
      position: position,
      club: club,
      search: search,
    );
  }
}
