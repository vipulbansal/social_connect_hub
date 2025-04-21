import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 5)
enum UserStatus {
  @HiveField(0)
  offline,
  @HiveField(1)
  online,
  @HiveField(2)
  away,
  @HiveField(3)
  busy
}

@JsonSerializable()
@HiveType(typeId: 2)
class User {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String email;
  
  @HiveField(3)
  List<String> friendIds;
  
  @HiveField(4)
  String? profilePicUrl;
  
  @HiveField(5)
  String? bio;
  
  @HiveField(6)
  String? location;
  
  @HiveField(7)
  String? phoneNumber;
  
  @HiveField(8)
  String? website;
  
  @HiveField(9)
  String? bannerImageUrl;
  
  @HiveField(10)
  String? displayName;
  
  @HiveField(11)
  Map<String, dynamic>? preferences; // For storing user preferences
  
  @HiveField(12)
  List<String> fcmTokens;
  
  @HiveField(13)
  List<String> pendingFriendRequestIds;
  
  @HiveField(14)
  @JsonKey(fromJson: _userStatusFromJson, toJson: _userStatusToJson)
  UserStatus status;
  
  @HiveField(15)
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime createdAt;
  
  @HiveField(16)
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? lastActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.friendIds,
    this.profilePicUrl,
    this.bio,
    this.location,
    this.phoneNumber,
    this.website,
    this.bannerImageUrl,
    this.displayName,
    this.preferences,
    required this.fcmTokens,
    List<String>? pendingFriendRequestIds,
    this.status = UserStatus.offline,
    required this.createdAt,
    this.lastActive,
  }) : pendingFriendRequestIds = pendingFriendRequestIds ?? [];

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  // For handling Timestamp <-> DateTime conversion
  static DateTime _dateTimeFromJson(dynamic timestamp) {
    if (timestamp is DateTime) return timestamp;
    
    if (timestamp != null) {
      try {
        // Handle Firestore Timestamp
        return timestamp.toDate();
      } catch (e) {
        // Handle ISO date string
        return DateTime.parse(timestamp.toString());
      }
    }
    
    return DateTime.now();
  }

  static dynamic _dateTimeToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
  
  // For handling UserStatus enum conversion
  static UserStatus _userStatusFromJson(dynamic status) {
    if (status is UserStatus) return status;
    
    if (status is String) {
      return UserStatus.values.firstWhere(
        (e) => e.toString() == 'UserStatus.$status', 
        orElse: () => UserStatus.offline,
      );
    }
    
    if (status is int) {
      return UserStatus.values[status];
    }
    
    return UserStatus.offline;
  }
  
  static dynamic _userStatusToJson(UserStatus status) {
    return status.toString().split('.').last;
  }
}