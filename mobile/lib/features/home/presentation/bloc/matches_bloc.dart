import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_matches_usecase.dart';
import 'matches_event.dart';
import 'matches_state.dart';

@injectable
class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final GetMatchesUseCase getMatchesUseCase;

  MatchesBloc(this.getMatchesUseCase) : super(MatchesInitialState()) {
    on<FetchMatchesEvent>((event, emit) async {
      emit(MatchesLoadingState());
      final result = await getMatchesUseCase();
      result.fold(
        (failure) => emit(MatchesFailureState(failure.message)),
        (matches) => emit(MatchesLoadedState(matches)),
      );
    });
  }
}
