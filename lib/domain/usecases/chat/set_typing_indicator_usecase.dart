import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../repositories/chat/chat_repository.dart';

/// Parameters for setting a typing indicator
class SetTypingIndicatorParams {
  final String userId;
  final String chatId;
  final bool isTyping;

  /// Constructor
  const SetTypingIndicatorParams({
    required this.userId,
    required this.chatId,
    required this.isTyping,
  });
}

/// Use case to set a typing indicator
class SetTypingIndicatorUseCase implements UseCase<void, SetTypingIndicatorParams> {
  final ChatRepository _chatRepository;

  /// Constructor
  const SetTypingIndicatorUseCase(this._chatRepository);

  @override
  Future<Result<void>> call(SetTypingIndicatorParams params) async {
    // Using updateTypingStatus instead of setTypingIndicator to match repository interface
    // Also using positional parameters instead of named parameters
    return await _chatRepository.updateTypingStatus(
      params.userId,
      params.chatId,
      params.isTyping,
    );
  }
}