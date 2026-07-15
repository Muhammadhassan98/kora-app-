import 'package:injectable/injectable.dart';
import 'package:fantkora/core/network/api_client.dart';
import '../models/player_model.dart';
import '../models/fantasy_squad_model.dart';

abstract class FantasyRemoteDataSource {
  Future<List<PlayerModel>> getPlayers({
    String? position,
    String? club,
    String? search,
  });

  Future<FantasySquadModel> getSquad();

  Future<FantasySquadModel> updateSquad({
    required List<String> playerIds,
  });
}

@LazySingleton(as: FantasyRemoteDataSource)
class FantasyRemoteDataSourceImpl implements FantasyRemoteDataSource {
  final ApiClient apiClient;

  FantasyRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<PlayerModel>> getPlayers({
    String? position,
    String? club,
    String? search,
  }) async {
    final response = await apiClient.dio.get(
      'fantasy/players',
      queryParameters: {
        'position': position,
        'club': club,
        'search': search,
      },
    );
    final list = response.data as List<dynamic>;
    return list.map((item) => PlayerModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<FantasySquadModel> getSquad() async {
    final response = await apiClient.dio.get('fantasy/squad');
    return FantasySquadModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<FantasySquadModel> updateSquad({
    required List<String> playerIds,
  }) async {
    final response = await apiClient.dio.post(
      'fantasy/squad/transfers',
      data: {
        'playerIds': playerIds,
      },
    );
    return FantasySquadModel.fromJson(response.data as Map<String, dynamic>);
  }
}
