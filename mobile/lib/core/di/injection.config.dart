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
import '../../features/fantasy/data/datasources/fantasy_remote_data_source.dart'
    as _i336;
import '../../features/fantasy/data/repositories/fantasy_repository_impl.dart'
    as _i269;
import '../../features/fantasy/domain/repositories/fantasy_repository.dart'
    as _i63;
import '../../features/fantasy/domain/usecases/get_players_usecase.dart'
    as _i806;
import '../../features/fantasy/domain/usecases/get_squad_usecase.dart' as _i658;
import '../../features/fantasy/domain/usecases/update_squad_usecase.dart'
    as _i209;
import '../../features/fantasy/presentation/bloc/fantasy_bloc.dart' as _i514;
import '../../features/home/data/datasources/matches_remote_data_source.dart'
    as _i192;
import '../../features/home/data/repositories/matches_repository_impl.dart'
    as _i613;
import '../../features/home/domain/repositories/matches_repository.dart'
    as _i211;
import '../../features/home/domain/usecases/get_matches_usecase.dart' as _i1031;
import '../../features/home/presentation/bloc/matches_bloc.dart' as _i1059;
import '../../features/prediction/data/datasources/predictions_remote_data_source.dart'
    as _i935;
import '../../features/prediction/data/repositories/predictions_repository_impl.dart'
    as _i707;
import '../../features/prediction/domain/repositories/predictions_repository.dart'
    as _i1019;
import '../../features/prediction/domain/usecases/create_prediction_usecase.dart'
    as _i798;
import '../../features/prediction/domain/usecases/get_leaderboard_usecase.dart'
    as _i777;
import '../../features/prediction/domain/usecases/get_my_predictions_usecase.dart'
    as _i508;
import '../../features/prediction/presentation/bloc/prediction_bloc.dart'
    as _i1013;
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
    gh.lazySingleton<_i336.FantasyRemoteDataSource>(
        () => _i336.FantasyRemoteDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
        () => _i107.AuthRemoteDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i935.PredictionsRemoteDataSource>(
        () => _i935.PredictionsRemoteDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i1019.PredictionsRepository>(() =>
        _i707.PredictionsRepositoryImpl(
            gh<_i935.PredictionsRemoteDataSource>()));
    gh.lazySingleton<_i192.MatchesRemoteDataSource>(
        () => _i192.MatchesRemoteDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i787.AuthRepository>(
        () => _i153.AuthRepositoryImpl(gh<_i107.AuthRemoteDataSource>()));
    gh.lazySingleton<_i63.FantasyRepository>(
        () => _i269.FantasyRepositoryImpl(gh<_i336.FantasyRemoteDataSource>()));
    gh.lazySingleton<_i508.GetMyPredictionsUseCase>(() =>
        _i508.GetMyPredictionsUseCase(gh<_i1019.PredictionsRepository>()));
    gh.lazySingleton<_i777.GetLeaderboardUseCase>(
        () => _i777.GetLeaderboardUseCase(gh<_i1019.PredictionsRepository>()));
    gh.lazySingleton<_i798.CreatePredictionUseCase>(() =>
        _i798.CreatePredictionUseCase(gh<_i1019.PredictionsRepository>()));
    gh.factory<_i1013.PredictionBloc>(() => _i1013.PredictionBloc(
          createPredictionUseCase: gh<_i798.CreatePredictionUseCase>(),
          getMyPredictionsUseCase: gh<_i508.GetMyPredictionsUseCase>(),
          getLeaderboardUseCase: gh<_i777.GetLeaderboardUseCase>(),
        ));
    gh.lazySingleton<_i658.GetSquadUseCase>(
        () => _i658.GetSquadUseCase(gh<_i63.FantasyRepository>()));
    gh.lazySingleton<_i209.UpdateSquadUseCase>(
        () => _i209.UpdateSquadUseCase(gh<_i63.FantasyRepository>()));
    gh.lazySingleton<_i806.GetPlayersUseCase>(
        () => _i806.GetPlayersUseCase(gh<_i63.FantasyRepository>()));
    gh.lazySingleton<_i211.MatchesRepository>(
        () => _i613.MatchesRepositoryImpl(gh<_i192.MatchesRemoteDataSource>()));
    gh.factory<_i941.RegisterUseCase>(
        () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i188.LoginUseCase>(
        () => _i188.LoginUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i663.SendOtpUseCase>(
        () => _i663.SendOtpUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i503.VerifyOtpUseCase>(
        () => _i503.VerifyOtpUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i1031.GetMatchesUseCase>(
        () => _i1031.GetMatchesUseCase(gh<_i211.MatchesRepository>()));
    gh.factory<_i514.FantasyBloc>(() => _i514.FantasyBloc(
          getPlayersUseCase: gh<_i806.GetPlayersUseCase>(),
          getSquadUseCase: gh<_i658.GetSquadUseCase>(),
          updateSquadUseCase: gh<_i209.UpdateSquadUseCase>(),
        ));
    gh.factory<_i1059.MatchesBloc>(
        () => _i1059.MatchesBloc(gh<_i1031.GetMatchesUseCase>()));
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
