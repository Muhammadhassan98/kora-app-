import 'package:equatable/equatable.dart';

abstract class PredictionEvent extends Equatable {
  const PredictionEvent();

  @override
  List<Object?> get props => [];
}

class SubmitPredictionEvent extends PredictionEvent {
  final String matchId;
  final String predictedWinner;
  final int predictedHomeScore;
  final int predictedAwayScore;

  const SubmitPredictionEvent({
    required this.matchId,
    required this.predictedWinner,
    required this.predictedHomeScore,
    required this.predictedAwayScore,
  });

  @override
  List<Object?> get props => [
        matchId,
        predictedWinner,
        predictedHomeScore,
        predictedAwayScore,
      ];
}

class FetchMyPredictionsEvent extends PredictionEvent {}

class FetchLeaderboardEvent extends PredictionEvent {}
