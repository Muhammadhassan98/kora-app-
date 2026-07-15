import '../../domain/entities/player_entity.dart';
import '../../domain/entities/fantasy_squad_entity.dart';

abstract class FantasyState {}

class FantasyInitialState extends FantasyState {}

class FantasyLoadingState extends FantasyState {}

class FantasySquadLoadedState extends FantasyState {
  final FantasySquadEntity squad;

  FantasySquadLoadedState(this.squad);
}

class FantasyPlayersLoadedState extends FantasyState {
  final List<PlayerEntity> players;

  FantasyPlayersLoadedState(this.players);
}

class FantasyTransfersSuccessState extends FantasyState {
  final FantasySquadEntity squad;

  FantasyTransfersSuccessState(this.squad);
}

class FantasyFailureState extends FantasyState {
  final String message;

  FantasyFailureState(this.message);
}
