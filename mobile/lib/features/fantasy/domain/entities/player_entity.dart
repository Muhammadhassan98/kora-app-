class PlayerEntity {
  final String id;
  final String name;
  final String position; // 'GKP', 'DEF', 'MID', 'FWD'
  final double price; // e.g. 12.0 for 12M
  final int points;
  final String club;
  final String? logo;

  const PlayerEntity({
    required this.id,
    required this.name,
    required this.position,
    required this.price,
    required this.points,
    required this.club,
    this.logo,
  });
}
