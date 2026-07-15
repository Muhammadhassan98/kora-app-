import 'player_entity.dart';

class SquadPlayerEntity {
  final String id;
  final String fantasySquadId;
  final String playerId;
  final PlayerEntity player;
  final bool isCaptain;
  final bool isViceCaptain;
  final bool isBench;

  const SquadPlayerEntity({
    required this.id,
    required this.fantasySquadId,
    required this.playerId,
    required this.player,
    required this.isCaptain,
    required this.isViceCaptain,
    required this.isBench,
  });
}
