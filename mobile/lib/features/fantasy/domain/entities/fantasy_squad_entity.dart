import 'squad_player_entity.dart';

class FantasySquadEntity {
  final String id;
  final String userId;
  final double budget;
  final int totalPoints;
  final int gameweekPoints;
  final List<SquadPlayerEntity> players;

  const FantasySquadEntity({
    required this.id,
    required this.userId,
    required this.budget,
    required this.totalPoints,
    required this.gameweekPoints,
    required this.players,
  });
}
