import 'package:equatable/equatable.dart';

/// Entity representing a chat message
///
/// This is the canonical MessageEntity class that should be used throughout the application.
/// The MessageEntity in the chat directory is deprecated and forwards to this class.
class MessageEntity extends Equatable {
  /// Unique identifier
  final String id;

  /// Chat ID this message belongs to
  final String chatId;

  /// User ID of the sender
  final String senderId;

  /// User ID of the receiver (for direct messages)
  final String? receiverId;

  /// Message content
  final String content;

  /// Type of content (text, image, video, file, audio)
  final String contentType;

  /// Message type (regular, system, etc.)
  final dynamic type;

  /// Message status (sent, delivered, read, etc.)
  final dynamic status;

  /// URL to media (for image, video, file, audio)
  final String? mediaUrl;

  /// Thumbnail URL for media
  final String? thumbnailUrl;

  /// List of user IDs who have read the message
  final List<String> readBy;

  /// Whether the message has been read
  final bool isRead;

  /// Whether the message has been edited
  final bool isEdited;

  /// Whether the message has been deleted
  final bool isDeleted;

  /// Reply to message ID (if this is a reply)
  final String? replyToId;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  /// Created timestamp
  final DateTime createdAt;

  /// Updated timestamp
  final DateTime updatedAt;

  /// Timestamp (used in some implementations)
  final DateTime? timestamp;

  /// Constructor
  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.receiverId,
    required this.content,
    this.contentType = 'text',
    this.type,
    this.status,
    this.mediaUrl,
    this.thumbnailUrl,
    this.readBy = const [],
    this.isRead = false,
    this.isEdited = false,
    this.isDeleted = false,
    this.replyToId,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    chatId,
    senderId,
    receiverId,
    content,
    contentType,
    type,
    status,
    mediaUrl,
    thumbnailUrl,
    readBy,
    isRead,
    isEdited,
    isDeleted,
    replyToId,
    metadata,
    createdAt,
    updatedAt,
    timestamp,
  ];

  /// Create a copy of this entity with specified changes
  MessageEntity copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? content,
    String? contentType,
    dynamic type,
    dynamic status,
    String? mediaUrl,
    String? thumbnailUrl,
    List<String>? readBy,
    bool? isRead,
    bool? isEdited,
    bool? isDeleted,
    String? replyToId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? timestamp,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      type: type ?? this.type,
      status: status ?? this.status,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      readBy: readBy ?? this.readBy,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      replyToId: replyToId ?? this.replyToId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}


