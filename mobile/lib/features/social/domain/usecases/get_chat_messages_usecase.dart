import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/social_repository.dart';

@lazySingleton
class GetChatMessagesUseCase {
  final SocialRepository repository;

  GetChatMessagesUseCase(this.repository);

  Future<Either<Failure, List<ChatMessageEntity>>> call(String roomId) {
    return repository.getChatMessages(roomId);
  }
}
