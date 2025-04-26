import 'package:social_connect_hub/domain/core/result.dart';
import 'package:social_connect_hub/domain/entities/friend/friend_request_entity.dart';
import 'package:social_connect_hub/domain/entities/user/user_entity.dart';
import 'package:social_connect_hub/domain/repositories/friend/friend_repository.dart';

import '../../../domain/core/failures.dart';
import '../../datasources/friend/friend_data_source.dart';
import '../../models/friend_request.dart';
import '../../models/user.dart';
// Implementation of [FriendRepository] following clean architecture
class FriendRepositoryImpl implements FriendRepository {
  final FriendDataSource _friendDataSource;

  /// Constructor
  const FriendRepositoryImpl({
    required FriendDataSource friendDataSource,
  }) : _friendDataSource = friendDataSource;

  @override
  Future<Result<List<UserEntity>>> getUserFriends(String userId) async {
    try {
      final friends = await _friendDataSource.getUserFriends(userId);
      return Result.success(friends.map(_mapToUserEntity).toList());
    } catch (e) {
      return Result.failure(FriendFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<FriendRequestEntity>>> getUserFriendRequests(String userId) async {
    try {
      final requests = await _friendDataSource.getUserFriendRequests(userId);
      return Result.success(requests.map(_mapToFriendRequestEntity).toList());
    } catch (e) {
      return Result.failure(FriendFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<FriendRequestEntity>>> getUserSentFriendRequests(String userId) async {
    try {
      final requests = await _friendDataSource.getUserSentFriendRequests(userId);
      return Result.success(requests.map(_mapToFriendRequestEntity).toList());
    } catch (e) {
      return Result.failure(FriendFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendFriendRequest(String senderId, String recipientId) async {
    try {
      await _friendDataSource.sendFriendRequest(senderId, recipientId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(FriendFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> acceptFriendRequest(String requestId) async {
    try {
      final success = await _friendDataSource.acceptFriendRequest(requestId);
      return Result.success(success);
    } catch (e) {
      return Result.failure(FriendFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> rejectFriendRequest(String requestId) async {
    try {
      final success = await _friendDataSource.rejectFriendRequest(requestId);
      return Result.success(success);
    } catch (e) {
      return Result.failure(FriendFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> cancelFriendRequest(String requestId) async {
    try {
      final success = await _friendDataSource.cancelFriendRequest(requestId);
      return Result.success(success);
    } catch (e) {
      return Result.failure(FriendFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> removeFriend(String userId, String friendId) async {
    try {
      final success = await _friendDataSource.removeFriend(userId, friendId);
      return Result.success(success);
    } catch (e) {
      return Result.failure(FriendFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> areFriends(String userId, String otherUserId) async {
    try {
      final areFriends = await _friendDataSource.areFriends(userId, otherUserId);
      return Result.success(areFriends);
    } catch (e) {
      return Result.failure(FriendFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> checkFriendshipStatus(String userId, String otherUserId) async {
    try {
      final areFriends = await _friendDataSource.areFriends(userId, otherUserId);
      return Result.success(areFriends);
    } catch (e) {
      return Result.failure(FriendFailure(e.toString()));
    }
  }

  @override
  Stream<List<UserEntity>> streamUserFriends(String userId) {
    return _friendDataSource.streamUserFriends(userId)
        .map((friends) => friends.map(_mapToUserEntity).toList());
  }

  @override
  Stream<List<FriendRequestEntity>> streamUserFriendRequests(String userId) {
    return _friendDataSource.streamUserFriendRequests(userId)
        .map((requests) => requests.map(_mapToFriendRequestEntity).toList());
  }

  @override
  Future<Result<List<FriendRequestEntity>>> getFriendRequests(String userId) async {
    try {
      final requests = await _friendDataSource.getFriendRequests(userId);
      return Result.success(requests.map(_mapToFriendRequestEntity).toList());
    } catch (e) {
      return Result.failure(FriendFailure(e.toString()));
    }
  }

  @override
  Stream<List<UserEntity>> watchUserFriends(String userId) {
    return _friendDataSource.streamUserFriends(userId)
        .map((friends) => friends.map(_mapToUserEntity).toList());
  }

  @override
  Stream<List<FriendRequestEntity>> watchFriendRequests(String userId) {
    return _friendDataSource.streamUserFriendRequests(userId)
        .map((requests) => requests.map(_mapToFriendRequestEntity).toList());
  }

  @override
  Stream<List<FriendRequestEntity>> streamReceivedFriendRequests(String userId,) {
    return _friendDataSource.streamReceivedFriendRequests(userId)
        .map((requests) => requests.map(_mapToFriendRequestEntity).toList());
  }

  @override
  Stream<Result<List<FriendRequestEntity>>> streamSentFriendRequests(String userId) {
    // Option 2: Using Stream transformation with error handling
    try {
      // We still need to handle errors that might occur in the stream events
      return _friendDataSource.streamSentFriendRequests(userId)
          .map<Result<List<FriendRequestEntity>>>((requests) {
        try {
          // Convert each event to a success Result
          return Result.success(requests.map(_mapToFriendRequestEntity).toList());
        } catch (e) {
          // Handle errors during the mapping process
          return Result.failure(FriendFailure(e.toString()));
        }
      });
    } catch (e) {
      // This only catches errors during stream creation, not during event emission
      return Stream.value(Result.failure(FriendFailure(e.toString())));
    }
  }


  // Helper method to map model to entity
  UserEntity _mapToUserEntity(User user) {
    return UserEntity(
      id: user.id,
      email: user.email,
      name: user.name,
      photoUrl: user.profilePicUrl,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  // Helper method to map model to entity
  FriendRequestEntity _mapToFriendRequestEntity(FriendRequest request) {
    return FriendRequestEntity(
      id: request.id,
      fromUserId: request.senderId,
      toUserId: request.receiverId,
      status: request.status.toString().split('.').last,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
    );
  }
}