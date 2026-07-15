import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../storage/local_storage.dart';
import '../network/api_client.dart';

@module
abstract class AppModule {
  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  ApiClient get apiClient => ApiClient(dio);

  @lazySingleton
  LocalStorage get localStorage => LocalStorage();
}
