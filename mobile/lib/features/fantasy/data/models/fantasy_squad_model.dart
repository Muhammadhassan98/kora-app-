import '../../domain/entities/fantasy_squad_entity.dart';
import 'squad_player_model.dart';

class FantasySquadModel extends FantasySquadEntity {
  const FantasySquadModel({
    required super.id,
    required super.userId,
    required super.budget,
    required super.totalPoints,
    required super.gameweekPoints,
    required List<SquadPlayerModel> super.players,
  });

  factory FantasySquadModel.fromJson(Map<String, dynamic> json) {
    final list = (json['players'] as List<dynamic>?) ?? [];
    final players = list.map((item) => SquadPlayerModel.fromJson(item as Map<String, dynamic>)).toList();
    
    return FantasySquadModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      budget: (json['budget'] as num).toDouble(),
      totalPoints: json['totalPoints'] as int? ?? 0,
      gameweekPoints: json['gameweekPoints'] as int? ?? 0,
      players: players,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'budget': budget,
      'totalPoints': totalPoints,
      'gameweekPoints': gameweekPoints,
      'players': players.map((item) => (item as SquadPlayerModel).toJson()).toList(),
    };
  }
}
