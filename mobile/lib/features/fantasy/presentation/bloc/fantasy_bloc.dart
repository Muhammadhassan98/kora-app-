import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_players_usecase.dart';
import '../../domain/usecases/get_squad_usecase.dart';
import '../../domain/usecases/update_squad_usecase.dart';
import 'fantasy_event.dart';
import 'fantasy_state.dart';

@injectable
class FantasyBloc extends Bloc<FantasyEvent, FantasyState> {
  final GetPlayersUseCase getPlayersUseCase;
  final GetSquadUseCase getSquadUseCase;
  final UpdateSquadUseCase updateSquadUseCase;

  FantasyBloc({
    required this.getPlayersUseCase,
    required this.getSquadUseCase,
    required this.updateSquadUseCase,
  }) : super(FantasyInitialState()) {
    
    on<FetchSquadEvent>((event, emit) async {
      emit(FantasyLoadingState());
      final result = await getSquadUseCase();
      result.fold(
        (failure) => emit(FantasyFailureState(failure.message)),
        (squad) => emit(FantasySquadLoadedState(squad)),
      );
    });

    on<FetchPlayersEvent>((event, emit) async {
      emit(FantasyLoadingState());
      final result = await getPlayersUseCase(
        position: event.position,
        club: event.club,
        search: event.search,
      );
      result.fold(
        (failure) => emit(FantasyFailureState(failure.message)),
        (players) => emit(FantasyPlayersLoadedState(players)),
      );
    });

    on<UpdateSquadTransfersEvent>((event, emit) async {
      emit(FantasyLoadingState());
      final result = await updateSquadUseCase(playerIds: event.playerIds);
      result.fold(
        (failure) => emit(FantasyFailureState(failure.message)),
        (squad) => emit(FantasyTransfersSuccessState(squad)),
      );
    });
  }
}
