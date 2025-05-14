import '../../core/usecase_stream.dart';
import '../../repositories/chat/chat_repository.dart';

/// Use case for watching typing indicators in a chat
class WatchTypingIndicatorsUseCase implements UseCaseStream<List<String>, String> {
  final ChatRepository _chatRepository;

  /// Constructor
  WatchTypingIndicatorsUseCase(this._chatRepository);

  @override
  Stream<List<String>> call(String chatId) {
    return _chatRepository.streamTypingIndicators(chatId);
  }
}