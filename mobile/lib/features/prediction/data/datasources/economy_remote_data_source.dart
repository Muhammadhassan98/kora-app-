import 'package:injectable/injectable.dart';
import 'package:fantkora/core/network/api_client.dart';
import '../models/coin_transaction_model.dart';
import '../models/profile_model.dart';

abstract class EconomyRemoteDataSource {
  Future<List<CoinTransactionModel>> getTransactions();
  Future<ProfileModel> claimAdReward();
  Future<ProfileModel> purchaseItem(String itemId);
}

@LazySingleton(as: EconomyRemoteDataSource)
class EconomyRemoteDataSourceImpl implements EconomyRemoteDataSource {
  final ApiClient apiClient;

  EconomyRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CoinTransactionModel>> getTransactions() async {
    final response = await apiClient.dio.get('economy/transactions');
    final list = response.data as List<dynamic>;
    return list.map((item) => CoinTransactionModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<ProfileModel> claimAdReward() async {
    final response = await apiClient.dio.post('economy/claim-ad');
    return ProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProfileModel> purchaseItem(String itemId) async {
    final response = await apiClient.dio.post(
      'economy/purchase-item',
      data: {
        'itemId': itemId,
      },
    );
    return ProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}
