import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.userId,
    required super.username,
    super.avatarUrl,
    required super.coinsBalance,
    required super.xpPoints,
    required super.level,
    super.favoriteClub,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      coinsBalance: json['coinsBalance'] as int? ?? 0,
      xpPoints: json['xpPoints'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      favoriteClub: json['favoriteClub'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'coinsBalance': coinsBalance,
      'xpPoints': xpPoints,
      'level': level,
      'favoriteClub': favoriteClub,
    };
  }
}
