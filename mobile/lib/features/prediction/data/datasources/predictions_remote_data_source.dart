import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/prediction_model.dart';
import '../models/profile_model.dart';

abstract class PredictionsRemoteDataSource {
  Future<PredictionModel> createPrediction({
    required String matchId,
    required String predictedWinner,
    required int predictedHomeScore,
    required int predictedAwayScore,
  });

  Future<List<PredictionModel>> getMyPredictions();

  Future<List<ProfileModel>> getLeaderboard();
}

@LazySingleton(as: PredictionsRemoteDataSource)
class PredictionsRemoteDataSourceImpl implements PredictionsRemoteDataSource {
  final ApiClient apiClient;

  PredictionsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PredictionModel> createPrediction({
    required String matchId,
    required String predictedWinner,
    required int predictedHomeScore,
    required int predictedAwayScore,
  }) async {
    final response = await apiClient.dio.post(
      'predictions',
      data: {
        'matchId': matchId,
        'predictedWinner': predictedWinner,
        'predictedHomeScore': predictedHomeScore,
        'predictedAwayScore': predictedAwayScore,
      },
    );

    if (response.statusCode == 201) {
      final jsonResponse = response.data as Map<String, dynamic>;
      final predictionData = jsonResponse['data'] as Map<String, dynamic>;
      return PredictionModel.fromJson(predictionData);
    } else {
      throw Exception('Failed to save prediction');
    }
  }

  @override
  Future<List<PredictionModel>> getMyPredictions() async {
    final response = await apiClient.dio.get('predictions/my');
    if (response.statusCode == 200) {
      final jsonResponse = response.data as Map<String, dynamic>;
      final List<dynamic> listData = jsonResponse['data'] as List<dynamic>;
      return listData
          .map((json) => PredictionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  @override
  Future<List<ProfileModel>> getLeaderboard() async {
    final response = await apiClient.dio.get('predictions/leaderboard');
    if (response.statusCode == 200) {
      final jsonResponse = response.data as Map<String, dynamic>;
      final List<dynamic> listData = jsonResponse['data'] as List<dynamic>;
      return listData
          .map((json) => ProfileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }
}
