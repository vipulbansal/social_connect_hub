import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../entities/chat/message_entity.dart';
import '../../repositories/chat/chat_repository.dart';

/// Parameters for the get chat messages use case
class GetChatMessagesParams {
  final String chatId;
  final int limit;
  final MessageEntity? lastMessage;

  /// Constructor
  const GetChatMessagesParams({
    required this.chatId,
    this.limit = 20,
    this.lastMessage,
  });
}

/// Use case to get messages for a chat
class GetChatMessagesUseCase implements UseCase<List<MessageEntity>, GetChatMessagesParams> {
  final ChatRepository _chatRepository;

  /// Constructor
  const GetChatMessagesUseCase(this._chatRepository);

  @override
  Future<Result<List<MessageEntity>>> call(GetChatMessagesParams params) async {
    return await _chatRepository.getChatMessages(
      params.chatId,
      limit: params.limit,
      lastMessageId: params.lastMessage?.id,
    );
  }
}