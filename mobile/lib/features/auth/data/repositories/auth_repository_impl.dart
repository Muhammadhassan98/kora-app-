import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> register({
    String? email,
    String? phoneNumber,
    required String password,
    required String username,
    String? favoriteClub,
    String? interests,
  }) async {
    try {
      final user = await remoteDataSource.register(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        username: username,
        favoriteClub: favoriteClub,
        interests: interests,
      );
      return Right(user);
    } on DioException catch (e) {
      final errorMessage = _getErrorMessage(e);
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    try {
      final responseData = await remoteDataSource.login(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      final dataMap = responseData['data'] as Map<String, dynamic>;
      final userJson = dataMap['user'] as Map<String, dynamic>;
      
      // TODO: Save accessToken and refreshToken to secure storage here
      
      final userModel = UserModel.fromJson(userJson);
      return Right(userModel);
    } on DioException catch (e) {
      final errorMessage = _getErrorMessage(e);
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sendOtp({
    required String target,
  }) async {
    try {
      final success = await remoteDataSource.sendOtp(target: target);
      return Right(success);
    } on DioException catch (e) {
      final errorMessage = _getErrorMessage(e);
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp({
    required String target,
    required String code,
  }) async {
    try {
      final success = await remoteDataSource.verifyOtp(target: target, code: code);
      return Right(success);
    } on DioException catch (e) {
      final errorMessage = _getErrorMessage(e);
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        final message = data['message'];
        if (message is List) {
          return message.join(', ');
        }
        return message.toString();
      }
    }
    return e.message ?? 'Unknown connection error';
  }
}
