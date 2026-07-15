import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/fantasy_squad_entity.dart';
import '../repositories/fantasy_repository.dart';

@lazySingleton
class GetSquadUseCase {
  final FantasyRepository repository;

  GetSquadUseCase(this.repository);

  Future<Either<Failure, FantasySquadEntity>> call() {
    return repository.getSquad();
  }
}
