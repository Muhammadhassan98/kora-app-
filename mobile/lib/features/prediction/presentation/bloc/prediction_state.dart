import 'package:equatable/equatable.dart';
import '../../domain/entities/prediction_entity.dart';
import '../../domain/entities/profile_entity.dart';

abstract class PredictionState extends Equatable {
  const PredictionState();

  @override
  List<Object?> get props => [];
}

class PredictionInitialState extends PredictionState {}

class PredictionLoadingState extends PredictionState {}

class PredictionSuccessState extends PredictionState {
  final PredictionEntity prediction;

  const PredictionSuccessState(this.prediction);

  @override
  List<Object?> get props => [prediction];
}

class PredictionsLoadedState extends PredictionState {
  final List<PredictionEntity> predictions;

  const PredictionsLoadedState(this.predictions);

  @override
  List<Object?> get props => [predictions];
}

class LeaderboardLoadedState extends PredictionState {
  final List<ProfileEntity> profiles;

  const LeaderboardLoadedState(this.profiles);

  @override
  List<Object?> get props => [profiles];
}

class PredictionFailureState extends PredictionState {
  final String message;

  const PredictionFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
