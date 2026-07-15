import '../../domain/entities/prediction_entity.dart';

class PredictionModel extends PredictionEntity {
  const PredictionModel({
    required super.id,
    required super.userId,
    required super.matchId,
    required super.predictedWinner,
    required super.predictedHomeScore,
    required super.predictedAwayScore,
    required super.pointsEarned,
    required super.isProcessed,
    required super.createdAt,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      matchId: json['matchId'] as String,
      predictedWinner: json['predictedWinner'] as String,
      predictedHomeScore: json['predictedHomeScore'] as int,
      predictedAwayScore: json['predictedAwayScore'] as int,
      pointsEarned: json['pointsEarned'] as int? ?? 0,
      isProcessed: json['isProcessed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'matchId': matchId,
      'predictedWinner': predictedWinner,
      'predictedHomeScore': predictedHomeScore,
      'predictedAwayScore': predictedAwayScore,
      'pointsEarned': pointsEarned,
      'isProcessed': isProcessed,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
