/// Represents a friend request in the domain layer
///
/// This class is used to represent a request from one user to another
/// to become friends. It contains all the data related to the friend request.
class FriendRequestEntity {
  /// Unique identifier for the friend request
  final String id;

  /// ID of the user who sent the request
  final String fromUserId;

  /// ID of the user who received the request
  final String toUserId;

  /// Status of the request ('pending', 'accepted', 'rejected')
  final String status;

  /// When the request was created
  final DateTime createdAt;

  /// When the request status was last updated
  final DateTime? updatedAt;

  /// Creates a new [FriendRequestEntity]
  /// The constructor is not const to allow DateTime.now() usage
  FriendRequestEntity({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this [FriendRequestEntity] with the specified fields replaced
  FriendRequestEntity copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FriendRequestEntity(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FriendRequestEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FriendRequestEntity(id: $id, from: $fromUserId, to: $toUserId, status: $status)';
  }
}