import '../../../domain/core/failures.dart';
import '../../../domain/core/result.dart';
import '../../../domain/entities/user/user_entity.dart';
import '../../../domain/repositories/user/user_repository.dart';
import '../../datasources/user/user_data_source.dart';
import '../../models/user.dart' as app_models;

/// Implementation of [UserRepository] using clean architecture
class UserRepositoryImpl implements UserRepository {
  final UserDataSource _userDataSource;

  /// Constructor
  const UserRepositoryImpl({
    required UserDataSource userDataSource,
  }) : _userDataSource = userDataSource;

  @override
  Future<Result<UserEntity>> getUserById(String userId) async {
    try {
      final user = await _userDataSource.getUserById(userId);
      
      if (user != null) {
        return Result.success(_mapToUserEntity(user));
      }
      
      return Result.failure(
        UserFailure('User with ID $userId not found'),
      );
    } catch (e) {
      return Result.failure(UserFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<UserEntity>>> searchUsers(String query) async{
    try {
      final users = await _userDataSource.searchUsers(query);
      final userEntities=users.map((user)=>_mapToUserEntity(user)).toList();
      return Result.success(userEntities);
    } catch (e) {
      return Result.failure(UserFailure(e.toString()));
    }
  }

  // Helper method to map data model to domain entity
  UserEntity _mapToUserEntity(app_models.User user) {
    return UserEntity(
      id: user.id,
      name: user.name,
      email: user.email,
      avatarUrl: user.profilePicUrl,
      bio: user.bio,
      isOnline: user.status == app_models.UserStatus.online,
      lastSeen: user.lastActive,
      friends: user.friendIds,
      fcmToken: user.fcmTokens.isNotEmpty ? user.fcmTokens.first : null,
      createdAt: user.createdAt,
      updatedAt: user.lastActive ?? user.createdAt,
    );
  }

  // Helper method to map domain entity to data model
  app_models.User _mapToUserModel(UserEntity entity) {
    return app_models.User(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      profilePicUrl: entity.avatarUrl,
      bio: entity.bio,
      status: entity.isOnline ? app_models.UserStatus.online : app_models.UserStatus.offline,
      lastActive: entity.lastSeen,
      fcmTokens: entity.fcmToken != null ? [entity.fcmToken!] : [],
      friendIds: [],  // This would need to be fetched from the database
      createdAt: entity.createdAt,
    );
  }


  @override
  Future<Result<UserEntity>> getCurrentUser() async {
    try {
      final user = await _userDataSource.getCurrentUser();

      if (user != null) {
        return Result.success(_mapToUserEntity(user));
      }

      return Result.failure(
        const UserFailure('No authenticated user found'),
      );
    } catch (e) {
      return Result.failure(UserFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteUserAccount(String userId) async {
    try {
      await _userDataSource.deleteUserAccount(userId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UserFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<String>>> getUserFcmTokens(String userId) async {
    try {
      final tokens = await _userDataSource.getUserFcmTokens(userId);
      return Result.success(tokens);
    } catch (e) {
      return Result.failure(UserFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addFcmToken(String userId, String token) async {
    try {
      await _userDataSource.addFcmToken(userId, token);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UserFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> removeFcmToken(String userId, String token) async {
    try {
      await _userDataSource.removeFcmToken(userId, token);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UserFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity> watchUser(String userId) {
    return _userDataSource.watchUser(userId)
        .map((user) => user != null
        ? _mapToUserEntity(user)
        : UserEntity(
      id: userId,
      name: 'Unknown User',
      email: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Stream<UserEntity?> watchCurrentUser() {
    return _userDataSource.watchCurrentUser()
        .map((user) => user != null ? _mapToUserEntity(user) : null);
  }


  @override
  Future<Result<bool>> getUserOnlineStatus(String userId) async {
    try {
      final isOnline = await _userDataSource.getUserOnlineStatus(userId);
      return Result.success(isOnline);
    } catch (e) {
      return Result.failure(UserFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await _userDataSource.updateUserOnlineStatus(userId, isOnline);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UserFailure(e.toString()));
    }
  }





  @override
  Future<Result<UserEntity>> updateUserProfile(UserEntity user) async {
    try {
      // Convert domain entity to data model
      final userModel = _mapToUserModel(user);

      // Update user profile
      final updatedUser = await _userDataSource.updateUserProfile(userModel);

      if (updatedUser != null) {
        return Result.success(_mapToUserEntity(updatedUser));
      }

      return Result.failure(
        const UserFailure('Failed to update user profile'),
      );
    } catch (e) {
      return Result.failure(UserFailure(e.toString()));
    }
  }





}