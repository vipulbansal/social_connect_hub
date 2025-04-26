import '../../models/friend_request.dart';
import '../../models/user.dart';

/// Interface for friend data source
abstract class FriendDataSource {
  /// Get a user's friends
  Future<List<User>> getUserFriends(String userId);

  /// Get a user's received friend requests
  Future<List<FriendRequest>> getUserFriendRequests(String userId);

  /// Get all friend requests for a user
  Future<List<FriendRequest>> getFriendRequests(String userId);

  /// Get a user's sent friend requests
  Future<List<FriendRequest>> getUserSentFriendRequests(String userId);

  /// Send a friend request
  Future<FriendRequest?> sendFriendRequest(String senderId, String receiverId);

  /// Accept a friend request
  Future<bool> acceptFriendRequest(String requestId);

  /// Reject a friend request
  Future<bool> rejectFriendRequest(String requestId);

  /// Cancel a friend request
  Future<bool> cancelFriendRequest(String requestId);

  /// Remove a friend
  Future<bool> removeFriend(String userId, String friendId);

  /// Check if users are friends
  Future<bool> areFriends(String userId, String otherUserId);

  /// Stream a user's friends
  Stream<List<User>> streamUserFriends(String userId);

  /// Stream a user's friend requests
  Stream<List<FriendRequest>> streamUserFriendRequests(String userId);

  /// Stream a user's sent friend requests
  Stream<List<FriendRequest>> streamUserSentFriendRequests(String userId);

  /// Stream received friend requests
  Stream<List<FriendRequest>> streamReceivedFriendRequests(String userId);

  /// Stream sent friend requests
  Stream<List<FriendRequest>> streamSentFriendRequests(String userId);
}