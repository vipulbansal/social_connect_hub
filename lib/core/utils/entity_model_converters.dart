import '../../data/models/user.dart';
import '../../domain/entities/user/user_entity.dart';

/// Utility class to convert between domain entities and data models
class EntityModelConverters {
  /// Convert UserEntity to User model
  static User userEntityToModel(UserEntity entity) {
    return User(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      profilePicUrl: entity.avatarUrl,
      bio: entity.bio ?? '',
      createdAt: entity.createdAt,
      lastActive: entity.lastSeen,
      status: entity.isOnline ? UserStatus.online : UserStatus.offline,
      phoneNumber: entity.phoneNumber,
      fcmTokens: entity.fcmToken != null ? [entity.fcmToken!] : [],
      friendIds: entity.friends,
    );
  }

  /// Convert User model to UserEntity
  static UserEntity userModelToEntity(User model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      name: model.name,
      avatarUrl: model.profilePicUrl,
      bio: model.bio,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt ?? model.createdAt,
      lastSeen: model.lastActive,
      isOnline: model.status == UserStatus.online,
      phoneNumber: model.phoneNumber,
      fcmToken: model.fcmTokens.isNotEmpty ? model.fcmTokens.first : null,
      friends: model.friendIds,
    );
  }

}