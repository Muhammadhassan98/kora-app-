import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    String? email,
    String? phoneNumber,
    required String password,
    required String username,
    String? favoriteClub,
    String? interests,
  }) {
    return repository.register(
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      username: username,
      favoriteClub: favoriteClub,
      interests: interests,
    );
  }
}
