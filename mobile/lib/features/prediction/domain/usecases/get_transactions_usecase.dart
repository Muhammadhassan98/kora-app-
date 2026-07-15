import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/coin_transaction_entity.dart';
import '../repositories/economy_repository.dart';

@lazySingleton
class GetTransactionsUseCase {
  final EconomyRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<CoinTransactionEntity>>> call() {
    return repository.getTransactions();
  }
}
