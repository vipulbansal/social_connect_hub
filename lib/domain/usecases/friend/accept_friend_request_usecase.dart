import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../repositories/friend/friend_repository.dart';

/// Use case to accept a friend request
class AcceptFriendRequestUseCase implements UseCase<void, String> {
  final FriendRepository _friendRepository;

  /// Constructor
  const AcceptFriendRequestUseCase(this._friendRepository);

  @override
  Future<Result<void>> call(String requestId) async {
    return await _friendRepository.acceptFriendRequest(requestId);
  }
}