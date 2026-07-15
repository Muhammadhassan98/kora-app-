import '../../domain/entities/player_entity.dart';

class PlayerModel extends PlayerEntity {
  const PlayerModel({
    required super.id,
    required super.name,
    required super.position,
    required super.price,
    required super.points,
    required super.club,
    super.logo,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      position: json['position'] as String,
      price: (json['price'] as num).toDouble(),
      points: json['points'] as int,
      club: json['club'] as String,
      logo: json['logo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'price': price,
      'points': points,
      'club': club,
      'logo': logo,
    };
  }
}
