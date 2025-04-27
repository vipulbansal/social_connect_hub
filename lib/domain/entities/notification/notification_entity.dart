/// Represents a notification in the domain layer
///
/// This class is used to represent a notification to a user.
/// It contains all the notification data including content, type, and related data.
class NotificationEntity {
  /// Unique identifier for the notification
  final String id;

  /// ID of the user who this notification is for
  final String userId;

  /// ID of the user who sent this notification (if applicable)
  final String? senderId;

  /// Title of the notification
  final String title;

  /// Body text of the notification
  final String body;

  /// Type of notification (e.g. 'friend_request', 'new_message', 'group_invite')
  final String type;

  /// Whether the notification has been read by the user
  final bool read;

  /// When the notification was created
  final DateTime createdAt;

  /// Additional data associated with the notification (e.g. chatId)
  final Map<String, dynamic>? data;

  /// Optional URL for an image to display with the notification
  final String? imageUrl;

  /// Creates a new [NotificationEntity]
  NotificationEntity({
    required this.id,
    required this.userId,
    this.senderId,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
    this.data,
    this.imageUrl,
  });

  /// Creates a copy of this [NotificationEntity] with the specified fields replaced
  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? senderId,
    String? title,
    String? body,
    String? type,
    bool? read,
    DateTime? createdAt,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      senderId: senderId ?? this.senderId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationEntity(id: $id, type: $type, title: $title)';
  }
}