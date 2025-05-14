import 'package:equatable/equatable.dart';

/// Entity representing a user
class UserEntity extends Equatable {
  /// Unique identifier
  final String id;

  /// User's display name
  final String name;

  /// User's email address
  final String email;

  /// URL to user's avatar image
  final String? avatarUrl;

  /// Alternative URL to user's photo (for backwards compatibility)
  final String? photoUrl;

  /// User's bio or status
  final String? bio;

  /// User's online status
  final bool isOnline;

  /// Timestamp of last activity
  final DateTime? lastSeen;

  /// User's FCM token for push notifications
  final String? fcmToken;

  /// User's phone number
  final String? phoneNumber;

  /// List of friend IDs
  final List<String> friends;

  /// Timestamp when user was created
  final DateTime createdAt;

  /// Timestamp when user profile was last updated
  final DateTime updatedAt;

  // /// User's custom display name (can be different from regular name)
  // final String? displayName;
  //
  // /// User's location
  // final String? location;
  //
  // /// User's website URL
  // final String? website;
  //
  // /// URL to the user's banner image
  // final String? bannerImageUrl;

  // Backward compatibility getters
  String? get profilePicUrl => avatarUrl;
  String? get displayName => name;
  String? get location => null; // Add if needed in entity
  String? get website => null; // Add if needed in entity
  String? get bannerImageUrl => null; // Add if needed in entity
  List<String> get friendIds => friends;

  /// Constructor
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.photoUrl,
    this.bio,
    this.isOnline = false,
    this.lastSeen,
    this.fcmToken,
    this.phoneNumber,
    List<String>? friends,
    required this.createdAt,
    required this.updatedAt,
  }) : this.friends = friends ?? const [];

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatarUrl,
        photoUrl,
        bio,
        isOnline,
        lastSeen,
        fcmToken,
        phoneNumber,
        friends,
        createdAt,
        updatedAt,
      ];

  /// Create a copy of this entity with specified changes
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? photoUrl,
    String? bio,
    bool? isOnline,
    DateTime? lastSeen,
    String? fcmToken,
    String? phoneNumber,
    List<String>? friends,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      fcmToken: fcmToken ?? this.fcmToken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      friends: friends ?? this.friends,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}