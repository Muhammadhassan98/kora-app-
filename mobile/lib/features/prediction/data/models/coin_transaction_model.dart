import '../../domain/entities/coin_transaction_entity.dart';

class CoinTransactionModel extends CoinTransactionEntity {
  const CoinTransactionModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.transactionType,
    super.description,
    required super.createdAt,
  });

  factory CoinTransactionModel.fromJson(Map<String, dynamic> json) {
    return CoinTransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: json['amount'] as int,
      transactionType: json['transactionType'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'transactionType': transactionType,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
