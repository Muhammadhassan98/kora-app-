import '../../domain/entities/squad_player_entity.dart';
import 'player_model.dart';

class SquadPlayerModel extends SquadPlayerEntity {
  const SquadPlayerModel({
    required super.id,
    required super.fantasySquadId,
    required super.playerId,
    required PlayerModel super.player,
    required super.isCaptain,
    required super.isViceCaptain,
    required super.isBench,
  });

  factory SquadPlayerModel.fromJson(Map<String, dynamic> json) {
    return SquadPlayerModel(
      id: json['id'] as String,
      fantasySquadId: json['fantasySquadId'] as String,
      playerId: json['playerId'] as String,
      player: PlayerModel.fromJson(json['player'] as Map<String, dynamic>),
      isCaptain: json['isCaptain'] as bool? ?? false,
      isViceCaptain: json['isViceCaptain'] as bool? ?? false,
      isBench: json['isBench'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fantasySquadId': fantasySquadId,
      'playerId': playerId,
      'player': (player as PlayerModel).toJson(),
      'isCaptain': isCaptain,
      'isViceCaptain': isViceCaptain,
      'isBench': isBench,
    };
  }
}
