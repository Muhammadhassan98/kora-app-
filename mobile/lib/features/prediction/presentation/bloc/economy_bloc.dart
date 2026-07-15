import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/claim_ad_reward_usecase.dart';
import '../../domain/usecases/purchase_item_usecase.dart';
import 'economy_event.dart';
import 'economy_state.dart';

@injectable
class EconomyBloc extends Bloc<EconomyEvent, EconomyState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final ClaimAdRewardUseCase claimAdRewardUseCase;
  final PurchaseItemUseCase purchaseItemUseCase;

  EconomyBloc({
    required this.getTransactionsUseCase,
    required this.claimAdRewardUseCase,
    required this.purchaseItemUseCase,
  }) : super(EconomyInitialState()) {

    on<FetchTransactionsEvent>((event, emit) async {
      emit(EconomyLoadingState());
      final result = await getTransactionsUseCase();
      result.fold(
        (failure) => emit(EconomyFailureState(failure.message)),
        (transactions) => emit(EconomyTransactionsLoadedState(transactions)),
      );
    });

    on<ClaimAdRewardEvent>((event, emit) async {
      emit(EconomyLoadingState());
      final result = await claimAdRewardUseCase();
      result.fold(
        (failure) => emit(EconomyFailureState(failure.message)),
        (profile) => emit(EconomyActionSuccessState(profile, 'تم الحصول على ٢٠ عملة افتراضية بنجاح! 🎉')),
      );
    });

    on<PurchaseItemEvent>((event, emit) async {
      emit(EconomyLoadingState());
      final result = await purchaseItemUseCase(event.itemId);
      result.fold(
        (failure) => emit(EconomyFailureState(failure.message)),
        (profile) => emit(EconomyActionSuccessState(profile, 'تم شراء العنصر بنجاح من المتجر! 🛍️')),
      );
    });
  }
}
