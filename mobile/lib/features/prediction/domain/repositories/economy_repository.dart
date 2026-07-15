import 'package:dartz/dartz.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/coin_transaction_entity.dart';
import '../entities/profile_entity.dart';

abstract class EconomyRepository {
  Future<Either<Failure, List<CoinTransactionEntity>>> getTransactions();
  Future<Either<Failure, ProfileEntity>> claimAdReward();
  Future<Either<Failure, ProfileEntity>> purchaseItem(String itemId);
}
