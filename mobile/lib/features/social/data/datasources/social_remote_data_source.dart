import 'package:injectable/injectable.dart';
import 'package:fantkora/core/network/api_client.dart';
import '../models/post_model.dart';
import '../models/community_model.dart';
import '../models/chat_message_model.dart';

abstract class SocialRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<PostModel> createPost(String content);
  Future<PostModel> likePost(String postId);
  Future<List<CommunityModel>> getCommunities();
  Future<List<ChatMessageModel>> getChatMessages(String roomId);
  Future<ChatMessageModel> sendChatMessage(String roomId, String content);
}

@LazySingleton(as: SocialRemoteDataSource)
class SocialRemoteDataSourceImpl implements SocialRemoteDataSource {
  final ApiClient apiClient;

  SocialRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<PostModel>> getPosts() async {
    final response = await apiClient.dio.get('social/posts');
    final list = response.data as List<dynamic>;
    return list.map((item) => PostModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<PostModel> createPost(String content) async {
    final response = await apiClient.dio.post(
      'social/posts',
      data: {'content': content},
    );
    return PostModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PostModel> likePost(String postId) async {
    final response = await apiClient.dio.post('social/posts/$postId/like');
    return PostModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<CommunityModel>> getCommunities() async {
    final response = await apiClient.dio.get('social/communities');
    final list = response.data as List<dynamic>;
    return list.map((item) => CommunityModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ChatMessageModel>> getChatMessages(String roomId) async {
    final response = await apiClient.dio.get('social/chat/$roomId/messages');
    final list = response.data as List<dynamic>;
    return list.map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<ChatMessageModel> sendChatMessage(String roomId, String content) async {
    final response = await apiClient.dio.post(
      'social/chat/$roomId/messages',
      data: {'content': content},
    );
    return ChatMessageModel.fromJson(response.data as Map<String, dynamic>);
  }
}
