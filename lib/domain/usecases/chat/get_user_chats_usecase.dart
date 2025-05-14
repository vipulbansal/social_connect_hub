import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../entities/chat/chat_entity.dart';
import '../../repositories/chat/chat_repository.dart';

/// Use case to get all chats for a user
class GetUserChatsUseCase implements UseCase<List<ChatEntity>, String> {
  final ChatRepository _chatRepository;

  /// Constructor
  const GetUserChatsUseCase(this._chatRepository);

  @override
  Future<Result<List<ChatEntity>>> call(String userId) async {
    return await _chatRepository.getUserChats(userId);
  }
}