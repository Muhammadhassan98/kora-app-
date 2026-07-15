import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/economy_repository.dart';

@lazySingleton
class PurchaseItemUseCase {
  final EconomyRepository repository;

  PurchaseItemUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call(String itemId) {
    return repository.purchaseItem(itemId);
  }
}
