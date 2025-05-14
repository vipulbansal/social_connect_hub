import 'package:equatable/equatable.dart';

import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../repositories/chat/chat_repository.dart';

/// Parameters for marking a message as read
class MarkMessageAsReadParams extends Equatable {
  /// Message ID
  final String messageId;
  
  /// User ID who read the message
  final String userId;

  /// Constructor
  const MarkMessageAsReadParams({
    required this.messageId,
    required this.userId,
  });

  @override
  List<Object?> get props => [messageId, userId];
}

/// Use case for marking a message as read
class MarkMessageAsReadUseCase implements UseCase<void, MarkMessageAsReadParams> {
  final ChatRepository _chatRepository;

  /// Constructor
  MarkMessageAsReadUseCase(this._chatRepository);

  @override
  Future<Result<void>> call(MarkMessageAsReadParams params) async {
    // Updated to use Result<void> instead of Either<Failure, void>
    // Updated to use positional parameters instead of named parameters
    // to match the repository interface
    return await _chatRepository.markMessageAsRead(
      params.messageId,
      params.userId,
    );
  }
}