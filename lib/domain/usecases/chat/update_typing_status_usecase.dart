import 'package:equatable/equatable.dart';

import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../repositories/chat/chat_repository.dart';

/// Parameters for updating typing status
class UpdateTypingStatusParams extends Equatable {
  /// User ID
  final String userId;
  
  /// Chat ID
  final String chatId;
  
  /// Whether the user is typing
  final bool isTyping;

  /// Constructor
  const UpdateTypingStatusParams({
    required this.userId,
    required this.chatId,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [userId, chatId, isTyping];
}

/// Use case for updating typing status
class UpdateTypingStatusUseCase implements UseCase<void, UpdateTypingStatusParams> {
  final ChatRepository _chatRepository;

  /// Constructor
  UpdateTypingStatusUseCase(this._chatRepository);

  @override
  Future<Result<void>> call(UpdateTypingStatusParams params) async {
    // Updated to use Result<void> instead of Either<Failure, void>
    // Updated to use positional parameters instead of named parameters
    // to match the repository interface
    return await _chatRepository.updateTypingStatus(
      params.userId,
      params.chatId,
      params.isTyping,
    );
  }
}