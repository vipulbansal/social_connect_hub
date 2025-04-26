import '../../core/usecase.dart';
import '../../entities/friend/friend_request_entity.dart';
import '../../repositories/friend/friend_repository.dart';

/// Use case to watch friend requests for a user (stream)
class WatchFriendRequestsUseCase implements StreamUseCase<List<FriendRequestEntity>, String> {
  final FriendRepository _friendRepository;

  /// Constructor
  const WatchFriendRequestsUseCase(this._friendRepository);

  @override
  Stream<List<FriendRequestEntity>> call(String userId) {
    return _friendRepository.watchFriendRequests(userId);
  }
}