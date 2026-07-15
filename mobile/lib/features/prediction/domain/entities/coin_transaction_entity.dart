class CoinTransactionEntity {
  final String id;
  final String userId;
  final int amount;
  final String transactionType; // 'purchase', 'ad_reward', 'store_buy', 'gift'
  final String? description;
  final DateTime createdAt;

  const CoinTransactionEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.transactionType,
    this.description,
    required this.createdAt,
  });
}
