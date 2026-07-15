import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String target,
  }) {
    return repository.sendOtp(target: target);
  }
}
