import '../../core/usecase.dart';

import '../../entities/chat/message_entity.dart';
import '../../repositories/chat/chat_repository.dart';

/// Parameters for the watch chat messages use case
class WatchChatMessagesParams {
  final String chatId;
  final int limit;

  /// Constructor
  const WatchChatMessagesParams({
    required this.chatId,
    this.limit = 20,
  });
}

/// Use case to watch messages for a chat (stream)
class WatchChatMessagesUseCase implements StreamUseCase<List<MessageEntity>, WatchChatMessagesParams> {
  final ChatRepository _chatRepository;

  /// Constructor
  const WatchChatMessagesUseCase(this._chatRepository);

  @override
  Stream<List<MessageEntity>> call(WatchChatMessagesParams params) {
    // Using streamChatMessages instead of watchChatMessages to match repository interface
    return _chatRepository.streamChatMessages(
      params.chatId,
    );
  }
}