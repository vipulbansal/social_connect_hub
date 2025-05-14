import 'package:equatable/equatable.dart';

import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../repositories/chat/chat_repository.dart';

/// Parameters for marking all messages in a chat as read
class MarkAllMessagesAsReadParams extends Equatable {
  /// Chat ID
  final String chatId;
  
  /// User ID who read the messages
  final String userId;

  /// Constructor
  const MarkAllMessagesAsReadParams({
    required this.chatId,
    required this.userId,
  });

  @override
  List<Object?> get props => [chatId, userId];
}

/// Use case for marking all messages in a chat as read
class MarkAllMessagesAsReadUseCase implements UseCase<void, MarkAllMessagesAsReadParams> {
  final ChatRepository _chatRepository;

  /// Constructor
  MarkAllMessagesAsReadUseCase(this._chatRepository);

  @override
  Future<Result<void>> call(MarkAllMessagesAsReadParams params) async {
    // Updated to use Result<void> instead of Either<Failure, void>
    // Updated to use positional parameters instead of named parameters
    // to match the repository interface
    return await _chatRepository.markAllMessagesAsRead(
      params.chatId,
      params.userId,
    );
  }
}