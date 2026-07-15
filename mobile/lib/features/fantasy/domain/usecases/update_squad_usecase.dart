import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/fantasy_squad_entity.dart';
import '../repositories/fantasy_repository.dart';

@lazySingleton
class UpdateSquadUseCase {
  final FantasyRepository repository;

  UpdateSquadUseCase(this.repository);

  Future<Either<Failure, FantasySquadEntity>> call({
    required List<String> playerIds,
  }) {
    return repository.updateSquad(playerIds: playerIds);
  }
}
