import '../../core/result.dart';
import '../../entities/friend/friend_request_entity.dart';
import '../../entities/user/user_entity.dart';

/// Interface for the friend repository
abstract class FriendRepository {

  /// Get all friends for a user
  Future<Result<List<UserEntity>>> getUserFriends(String userId);

  /// Watch friends for a user (stream)
  Stream<List<UserEntity>> watchUserFriends(String userId);

  /// Get all friend requests for a user (both sent and received)
  Future<Result<List<FriendRequestEntity>>> getFriendRequests(String userId);

  /// Watch friend requests for a user (both sent and received) (stream)
  Stream<List<FriendRequestEntity>> watchFriendRequests(String userId);

  /// Watch received friend requests for a user (stream)
  Stream<List<FriendRequestEntity>> streamReceivedFriendRequests(String userId,);

  /// Watch sent friend requests for a user (stream)
  Stream<Result<List<FriendRequestEntity>>> streamSentFriendRequests(String userId,);

  /// Reject a friend request
  Future<Result<void>> rejectFriendRequest(String requestId);

  /// Cancel a sent friend request
  Future<Result<void>> cancelFriendRequest(String requestId);

  /// Remove a friend (unfriend)
  Future<Result<void>> removeFriend(String userId, String friendId);

  /// Check if two users are friends
  Future<Result<bool>> checkFriendshipStatus(String userId, String otherUserId);

  /// Send a friend request to another user
  Future<Result<void>> sendFriendRequest(String senderId, String recipientId);

  /// Accept a friend request
  Future<Result<void>> acceptFriendRequest(String requestId);

}