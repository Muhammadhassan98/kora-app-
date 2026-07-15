import 'package:equatable/equatable.dart';

class PredictionEntity extends Equatable {
  final String id;
  final String userId;
  final String matchId;
  final String predictedWinner; // 'home', 'away', 'draw'
  final int predictedHomeScore;
  final int predictedAwayScore;
  final int pointsEarned;
  final bool isProcessed;
  final DateTime createdAt;

  const PredictionEntity({
    required this.id,
    required this.userId,
    required this.matchId,
    required this.predictedWinner,
    required this.predictedHomeScore,
    required this.predictedAwayScore,
    required this.pointsEarned,
    required this.isProcessed,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        matchId,
        predictedWinner,
        predictedHomeScore,
        predictedAwayScore,
        pointsEarned,
        isProcessed,
        createdAt,
      ];
}
