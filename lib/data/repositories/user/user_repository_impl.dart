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

}