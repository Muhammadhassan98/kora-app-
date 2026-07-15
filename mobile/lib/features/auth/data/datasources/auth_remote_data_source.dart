// ignore_for_file: use_null_aware_elements

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register({
    String? email,
    String? phoneNumber,
    required String password,
    required String username,
    String? favoriteClub,
    String? interests,
  });

  Future<Map<String, dynamic>> login({
    String? email,
    String? phoneNumber,
    required String password,
  });

  Future<bool> sendOtp({
    required String target,
  });

  Future<bool> verifyOtp({
    required String target,
    required String code,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> register({
    String? email,
    String? phoneNumber,
    required String password,
    required String username,
    String? favoriteClub,
    String? interests,
  }) async {
    final response = await apiClient.dio.post(
      'auth/register',
      data: {
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'password': password,
        'username': username,
        if (favoriteClub != null) 'favoriteClub': favoriteClub,
        if (interests != null) 'interests': interests,
      },
    );

    if (response.statusCode == 201) {
      final responseData = response.data as Map<String, dynamic>;
      final userJson = responseData['data'] as Map<String, dynamic>;
      return UserModel.fromJson(userJson);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Registration failed',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    final response = await apiClient.dio.post(
      'auth/login',
      data: {
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Login failed',
      );
    }
  }

  @override
  Future<bool> sendOtp({
    required String target,
  }) async {
    final response = await apiClient.dio.post(
      'auth/otp/send',
      data: {
        'target': target,
      },
    );
    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      return body['success'] as bool? ?? false;
    }
    return false;
  }

  @override
  Future<bool> verifyOtp({
    required String target,
    required String code,
  }) async {
    final response = await apiClient.dio.post(
      'auth/otp/verify',
      data: {
        'target': target,
        'code': code,
      },
    );
    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      return body['success'] as bool? ?? false;
    }
    return false;
  }
}
