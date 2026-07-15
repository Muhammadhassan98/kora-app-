import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/create_prediction_usecase.dart';
import '../../domain/usecases/get_my_predictions_usecase.dart';
import '../../domain/usecases/get_leaderboard_usecase.dart';
import 'prediction_event.dart';
import 'prediction_state.dart';

@injectable
class PredictionBloc extends Bloc<PredictionEvent, PredictionState> {
  final CreatePredictionUseCase createPredictionUseCase;
  final GetMyPredictionsUseCase getMyPredictionsUseCase;
  final GetLeaderboardUseCase getLeaderboardUseCase;

  PredictionBloc({
    required this.createPredictionUseCase,
    required this.getMyPredictionsUseCase,
    required this.getLeaderboardUseCase,
  }) : super(PredictionInitialState()) {
    on<SubmitPredictionEvent>((event, emit) async {
      emit(PredictionLoadingState());
      final result = await createPredictionUseCase(
        matchId: event.matchId,
        predictedWinner: event.predictedWinner,
        predictedHomeScore: event.predictedHomeScore,
        predictedAwayScore: event.predictedAwayScore,
      );
      result.fold(
        (failure) => emit(PredictionFailureState(failure.message)),
        (prediction) => emit(PredictionSuccessState(prediction)),
      );
    });

    on<FetchMyPredictionsEvent>((event, emit) async {
      emit(PredictionLoadingState());
      final result = await getMyPredictionsUseCase();
      result.fold(
        (failure) => emit(PredictionFailureState(failure.message)),
        (predictions) => emit(PredictionsLoadedState(predictions)),
      );
    });

    on<FetchLeaderboardEvent>((event, emit) async {
      emit(PredictionLoadingState());
      final result = await getLeaderboardUseCase();
      result.fold(
        (failure) => emit(PredictionFailureState(failure.message)),
        (profiles) => emit(LeaderboardLoadedState(profiles)),
      );
    });
  }
}
