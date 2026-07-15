abstract class FantasyEvent {}

class FetchSquadEvent extends FantasyEvent {}

class FetchPlayersEvent extends FantasyEvent {
  final String? position;
  final String? club;
  final String? search;

  FetchPlayersEvent({this.position, this.club, this.search});
}

class UpdateSquadTransfersEvent extends FantasyEvent {
  final List<String> playerIds;

  UpdateSquadTransfersEvent(this.playerIds);
}
