class CommunityEntity {
  final String id;
  final String name;
  final String description;
  final String? avatarUrl;
  final int memberCount;
  final String? symbol;
  final DateTime createdAt;

  const CommunityEntity({
    required this.id,
    required this.name,
    required this.description,
    this.avatarUrl,
    required this.memberCount,
    this.symbol,
    required this.createdAt,
  });
}
