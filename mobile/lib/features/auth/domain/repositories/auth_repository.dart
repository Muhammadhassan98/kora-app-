import 'package:dartz/dartz.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> register({
    String? email,
    String? phoneNumber,
    required String password,
    required String username,
  });

  Future<Either<Failure, UserEntity>> login({
    String? email,
    String? phoneNumber,
    required String password,
  });

  Future<Either<Failure, bool>> sendOtp({
    required String target,
  });

  Future<Either<Failure, bool>> verifyOtp({
    required String target,
    required String code,
  });
}
