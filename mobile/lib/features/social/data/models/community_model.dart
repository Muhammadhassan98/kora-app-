import '../../domain/entities/community_entity.dart';

class CommunityModel extends CommunityEntity {
  const CommunityModel({
    required super.id,
    required super.name,
    required super.description,
    super.avatarUrl,
    required super.memberCount,
    super.symbol,
    required super.createdAt,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      memberCount: json['memberCount'] as int? ?? 0,
      symbol: json['symbol'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'memberCount': memberCount,
      'symbol': symbol,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
