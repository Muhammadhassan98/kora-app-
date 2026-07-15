import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:fantkora/core/error/failures.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/social_repository.dart';

@lazySingleton
class SendChatMessageUseCase {
  final SocialRepository repository;

  SendChatMessageUseCase(this.repository);

  Future<Either<Failure, ChatMessageEntity>> call(String roomId, String content) {
    return repository.sendChatMessage(roomId, content);
  }
}
