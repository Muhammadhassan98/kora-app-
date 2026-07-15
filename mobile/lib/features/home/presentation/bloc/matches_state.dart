import 'package:equatable/equatable.dart';
import '../../domain/entities/match_entity.dart';

abstract class MatchesState extends Equatable {
  const MatchesState();

  @override
  List<Object?> get props => [];
}

class MatchesInitialState extends MatchesState {}

class MatchesLoadingState extends MatchesState {}

class MatchesLoadedState extends MatchesState {
  final List<MatchEntity> matches;

  const MatchesLoadedState(this.matches);

  @override
  List<Object?> get props => [matches];
}

class MatchesFailureState extends MatchesState {
  final String message;

  const MatchesFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
