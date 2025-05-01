/// Represents a direct chat conversation in the domain layer
///
/// This class is used to represent a one-to-one chat conversation between users.
/// It contains the chat metadata such as participants and timestamps.
class ChatEntity {
  /// Unique identifier for the chat
  final String id;
  
  /// Display name for the chat (other user's name)
  final String name;
  
  /// List of user IDs who are participants in this chat (always 2 users for direct chats)
  final List<String> participantIds;
  
  /// When the chat was created
  final DateTime createdAt;
  
  /// When the chat was last updated (e.g., message sent)
  final DateTime updatedAt;
  
  /// Optional ID of the last message in this chat
  final String? lastMessageId;
  
  /// Optional content of the last message in this chat
  final String? lastMessageContent;
  
  /// Optional sender ID of the last message in this chat
  final String? lastMessageSenderId;
  
  /// Optional timestamp of the last message in this chat
  final DateTime? lastMessageTimestamp;

  /// Creates a new [ChatEntity]
  ChatEntity({
    required this.id,
    required this.name,
    required this.participantIds,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageId,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.lastMessageTimestamp,
  });

  /// Creates a copy of this [ChatEntity] with specified fields replaced
  ChatEntity copyWith({
    String? id,
    String? name,
    List<String>? participantIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageId,
    String? lastMessageContent,
    String? lastMessageSenderId,
    DateTime? lastMessageTimestamp,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatEntity(id: $id, name: $name, participants: ${participantIds.length})';
  }
}