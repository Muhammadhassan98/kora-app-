import '../../domain/entities/coin_transaction_entity.dart';
import '../../domain/entities/profile_entity.dart';

abstract class EconomyState {}

class EconomyInitialState extends EconomyState {}

class EconomyLoadingState extends EconomyState {}

class EconomyTransactionsLoadedState extends EconomyState {
  final List<CoinTransactionEntity> transactions;

  EconomyTransactionsLoadedState(this.transactions);
}

class EconomyActionSuccessState extends EconomyState {
  final ProfileEntity profile;
  final String message;

  EconomyActionSuccessState(this.profile, this.message);
}

class EconomyFailureState extends EconomyState {
  final String message;

  EconomyFailureState(this.message);
}
