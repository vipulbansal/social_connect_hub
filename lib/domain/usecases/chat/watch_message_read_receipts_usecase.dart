import '../../core/usecase_stream.dart';
import '../../repositories/chat/chat_repository.dart';

/// Use case for watching read receipts for a message
class WatchMessageReadReceiptsUseCase implements UseCaseStream<List<String>, String> {
  final ChatRepository _chatRepository;

  /// Constructor
  WatchMessageReadReceiptsUseCase(this._chatRepository);

  @override
  Stream<List<String>> call(String messageId) {
    return _chatRepository.streamMessageReadReceipts(messageId);
  }
}