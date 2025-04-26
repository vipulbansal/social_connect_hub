import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../entities/friend/friend_request_entity.dart';
import '../../repositories/friend/friend_repository.dart';

/// Parameters for the send friend request use case
class SendFriendRequestParams {
  final String senderId;
  final String receiverId;

  /// Constructor
  const SendFriendRequestParams({
    required this.senderId,
    required this.receiverId,
  });
}

/// Use case to send a friend request
class SendFriendRequestUseCase implements UseCase<void, SendFriendRequestParams> {
  final FriendRepository _friendRepository;

  /// Constructor
  const SendFriendRequestUseCase(this._friendRepository);

  @override
  Future<Result<void>> call(SendFriendRequestParams params) async {
    return await _friendRepository.sendFriendRequest(
      params.senderId,
      params.receiverId,
    );
  }
}