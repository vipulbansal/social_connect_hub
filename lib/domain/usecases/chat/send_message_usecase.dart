import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../entities/chat/message_entity.dart';
import '../../repositories/chat/chat_repository.dart';

/// Parameters for sending a message
class SendMessageParams {
  /// The message to send
  final MessageEntity message;

  /// Constructor
  const SendMessageParams({
    required this.message,
  });
}

/// Use case to send a message
///
/// Takes a SendMessageParams object as input and returns a MessageEntity as output.
/// This makes it clearer than having both input and output be MessageEntity.
class SendMessageUseCase implements UseCase<MessageEntity, SendMessageParams> {
  final ChatRepository _chatRepository;

  /// Constructor
  const SendMessageUseCase(this._chatRepository);

  @override
  Future<Result<MessageEntity>> call(SendMessageParams params) async {
    return await _chatRepository.sendMessage(params.message);
  }
}