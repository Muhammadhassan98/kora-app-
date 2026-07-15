import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String target,
    required String code,
  }) {
    return repository.verifyOtp(target: target, code: code);
  }
}
