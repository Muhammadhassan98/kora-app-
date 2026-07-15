import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../../domain/entities/coin_transaction_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/economy_repository.dart';
import '../datasources/economy_remote_data_source.dart';

@LazySingleton(as: EconomyRepository)
class EconomyRepositoryImpl implements EconomyRepository {
  final EconomyRemoteDataSource remoteDataSource;

  EconomyRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<CoinTransactionEntity>>> getTransactions() async {
    try {
      final list = await remoteDataSource.getTransactions();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> claimAdReward() async {
    try {
      final profile = await remoteDataSource.claimAdReward();
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> purchaseItem(String itemId) async {
    try {
      final profile = await remoteDataSource.purchaseItem(itemId);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
