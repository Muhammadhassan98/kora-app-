// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/domain/usecases/send_otp_usecase.dart' as _i663;
import '../../features/auth/domain/usecases/verify_otp_usecase.dart' as _i503;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../network/api_client.dart' as _i557;
import '../storage/local_storage.dart' as _i329;
import 'app_module.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    gh.lazySingleton<_i361.Dio>(() => appModule.dio);
    gh.lazySingleton<_i557.ApiClient>(() => appModule.apiClient);
    gh.lazySingleton<_i329.LocalStorage>(() => appModule.localStorage);
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
        () => _i107.AuthRemoteDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i787.AuthRepository>(
        () => _i153.AuthRepositoryImpl(gh<_i107.AuthRemoteDataSource>()));
    gh.factory<_i941.RegisterUseCase>(
        () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i188.LoginUseCase>(
        () => _i188.LoginUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i663.SendOtpUseCase>(
        () => _i663.SendOtpUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i503.VerifyOtpUseCase>(
        () => _i503.VerifyOtpUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i797.AuthBloc>(() => _i797.AuthBloc(
          registerUseCase: gh<_i941.RegisterUseCase>(),
          loginUseCase: gh<_i188.LoginUseCase>(),
          sendOtpUseCase: gh<_i663.SendOtpUseCase>(),
          verifyOtpUseCase: gh<_i503.VerifyOtpUseCase>(),
        ));
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}
