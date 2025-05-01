/// Represents a message in a chat conversation in the domain layer
///
/// This class is used to represent a single message within a chat.
/// It contains all the message data including content, sender, and timestamps.
class MessageEntity {
  /// Unique identifier for the message
  final String id;
  
  /// ID of the chat this message belongs to
  final String chatId;
  
  /// ID of the user who sent the message
  final String senderId;
  
  /// Content of the message
  final String content;
  
  /// Type of content (e.g. 'text', 'image', 'video', 'audio')
  final String contentType;
  
  /// Whether the message has been read by the recipient
  final bool isRead;
  
  /// When the message was created
  final DateTime createdAt;
  
  /// When the message was last updated
  final DateTime updatedAt;
  
  /// Optional URL for media content
  final String? mediaUrl;
  
  /// Optional metadata for the message (e.g. image dimensions)
  final Map<String, dynamic>? metadata;

  /// Creates a new [MessageEntity]
  MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.contentType,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.mediaUrl,
    this.metadata,
  });

  /// Creates a copy of this [MessageEntity] with the specified fields replaced
  MessageEntity copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    String? contentType,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? mediaUrl,
    Map<String, dynamic>? metadata,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MessageEntity(id: $id, chatId: $chatId, senderId: $senderId, contentType: $contentType)';
  }
}