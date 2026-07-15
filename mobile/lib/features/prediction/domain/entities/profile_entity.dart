import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final int coinsBalance;
  final int xpPoints;
  final int level;
  final String? favoriteClub;

  const ProfileEntity({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.coinsBalance,
    required this.xpPoints,
    required this.level,
    this.favoriteClub,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        avatarUrl,
        coinsBalance,
        xpPoints,
        level,
        favoriteClub,
      ];
}
