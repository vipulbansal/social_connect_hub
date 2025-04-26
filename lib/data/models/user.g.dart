// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 2;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      friendIds: (fields[3] as List).cast<String>(),
      profilePicUrl: fields[4] as String?,
      bio: fields[5] as String?,
      location: fields[6] as String?,
      phoneNumber: fields[7] as String?,
      website: fields[8] as String?,
      bannerImageUrl: fields[9] as String?,
      displayName: fields[10] as String?,
      preferences: (fields[11] as Map?)?.cast<String, dynamic>(),
      fcmTokens: (fields[12] as List).cast<String>(),
      pendingFriendRequestIds: (fields[13] as List?)?.cast<String>(),
      status: fields[14] as UserStatus,
      createdAt: fields[15] as DateTime,
      lastActive: fields[16] as DateTime?,
      updatedAt: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.friendIds)
      ..writeByte(4)
      ..write(obj.profilePicUrl)
      ..writeByte(5)
      ..write(obj.bio)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.phoneNumber)
      ..writeByte(8)
      ..write(obj.website)
      ..writeByte(9)
      ..write(obj.bannerImageUrl)
      ..writeByte(10)
      ..write(obj.displayName)
      ..writeByte(11)
      ..write(obj.preferences)
      ..writeByte(12)
      ..write(obj.fcmTokens)
      ..writeByte(13)
      ..write(obj.pendingFriendRequestIds)
      ..writeByte(14)
      ..write(obj.status)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.lastActive)
      ..writeByte(17)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserStatusAdapter extends TypeAdapter<UserStatus> {
  @override
  final int typeId = 5;

  @override
  UserStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserStatus.offline;
      case 1:
        return UserStatus.online;
      case 2:
        return UserStatus.away;
      case 3:
        return UserStatus.busy;
      default:
        return UserStatus.offline;
    }
  }

  @override
  void write(BinaryWriter writer, UserStatus obj) {
    switch (obj) {
      case UserStatus.offline:
        writer.writeByte(0);
        break;
      case UserStatus.online:
        writer.writeByte(1);
        break;
      case UserStatus.away:
        writer.writeByte(2);
        break;
      case UserStatus.busy:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      friendIds:
          (json['friendIds'] as List<dynamic>).map((e) => e as String).toList(),
      profilePicUrl: json['profilePicUrl'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      bannerImageUrl: json['bannerImageUrl'] as String?,
      displayName: json['displayName'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      fcmTokens:
          (json['fcmTokens'] as List<dynamic>).map((e) => e as String).toList(),
      pendingFriendRequestIds:
          (json['pendingFriendRequestIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      status: json['status'] == null
          ? UserStatus.offline
          : User._userStatusFromJson(json['status']),
      createdAt: User._dateTimeFromJson(json['createdAt']),
      lastActive: User._dateTimeFromJson(json['lastActive']),
      updatedAt: User._dateTimeFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'friendIds': instance.friendIds,
      'profilePicUrl': instance.profilePicUrl,
      'bio': instance.bio,
      'location': instance.location,
      'phoneNumber': instance.phoneNumber,
      'website': instance.website,
      'bannerImageUrl': instance.bannerImageUrl,
      'displayName': instance.displayName,
      'preferences': instance.preferences,
      'fcmTokens': instance.fcmTokens,
      'pendingFriendRequestIds': instance.pendingFriendRequestIds,
      'status': User._userStatusToJson(instance.status),
      'createdAt': User._dateTimeToJson(instance.createdAt),
      'lastActive': User._dateTimeToJson(instance.lastActive),
      'updatedAt': User._dateTimeToJson(instance.updatedAt),
    };
