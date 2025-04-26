import '../../core/result.dart';
import '../../core/usecase.dart';
import '../../entities/user/user_entity.dart';
import '../../repositories/friend/friend_repository.dart';

/// Use case to get all friends for a user
class GetUserFriendsUseCase implements UseCase<List<UserEntity>, String> {
  final FriendRepository _friendRepository;

  /// Constructor
  const GetUserFriendsUseCase(this._friendRepository);

  @override
  Future<Result<List<UserEntity>>> call(String userId) async {
    return await _friendRepository.getUserFriends(userId);
  }
}