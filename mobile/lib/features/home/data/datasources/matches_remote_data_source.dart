import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/match_model.dart';

abstract class MatchesRemoteDataSource {
  Future<List<MatchModel>> getMatches();
}

@LazySingleton(as: MatchesRemoteDataSource)
class MatchesRemoteDataSourceImpl implements MatchesRemoteDataSource {
  final ApiClient apiClient;

  MatchesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<MatchModel>> getMatches() async {
    final response = await apiClient.dio.get('matches');
    if (response.statusCode == 200) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList
          .map((json) => MatchModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }
}
