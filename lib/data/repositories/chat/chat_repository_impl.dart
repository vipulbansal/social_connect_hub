import '../../../domain/core/failures.dart';
import '../../../domain/core/result.dart';
import '../../../domain/entities/chat/chat_entity.dart';

import '../../../domain/entities/chat/message_entity.dart';
import '../../../domain/entities/chat/message_status.dart' as domain_status;
import '../../../domain/entities/chat/message_type.dart' as domain_type;
import '../../../domain/repositories/chat/chat_repository.dart';
import '../../datasources/chat/chat_data_source.dart';
import '../../models/chat.dart';
import '../../models/message.dart';

/// Implementation of [ChatRepository] following clean architecture
class ChatRepositoryImpl implements ChatRepository {
  final ChatDataSource _chatDataSource;

  /// Constructor
  const ChatRepositoryImpl({
    required ChatDataSource chatDataSource,
  }) : _chatDataSource = chatDataSource;

  @override
  Future<Result<ChatEntity>> getChatById(String chatId) async {
    try {
      final chat = await _chatDataSource.getChatById(chatId);

      if (chat != null) {
        return Result.success(_mapToChatEntity(chat));
      }

      return Result.failure(
        ChatFailure('Chat with ID $chatId not found'),
      );
    } catch (e) {
      return Result.failure(ChatFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ChatEntity>>> getUserChats(String userId) async {
    try {
      final chats = await _chatDataSource.getUserChats(userId);
      final chatEntities = chats.map(_mapToChatEntity).toList();

      return Result.success(chatEntities);
    } catch (e) {
      return Result.failure(ChatFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<MessageEntity>>> getChatMessages(
      String chatId,
      {int limit = 50, String? lastMessageId}
      ) async {
    try {
      final messages = await _chatDataSource.getChatMessages(
        chatId,
        limit: limit,
        lastMessageId: lastMessageId,
      );
      final messageEntities = messages.map(_mapToMessageEntity).toList();

      return Result.success(messageEntities);
    } catch (e) {
      return Result.failure(ChatFailure(e.toString()));
    }
  }

  @override
  Future<Result<MessageEntity>> sendMessage(MessageEntity message) async {
    try {
      final messageModel = _mapToMessageModel(message);
      final sentMessage = await _chatDataSource.sendMessage(messageModel);

      if (sentMessage != null) {
        return Result.success(_mapToMessageEntity(sentMessage));
      }

      return Result.failure(
        const ChatFailure('Failed to send message'),
      );
    } catch (e) {
      return Result.failure(ChatFailure(e.toString()));
    }
  }

  @override
  Future<Result<MessageEntity>> updateMessage(MessageEntity message) async {
    try {
      final messageModel = _mapToMessageModel(message);
      final updatedMessage = await _chatDataSource.updateMessage(messageModel);

      if (updatedMessage != null) {
        return Result.success(_mapToMessageEntity(updatedMessage));
      }

      return Result.failure(
        const ChatFailure('Failed to update message'),
      );
    } catch (e) {
      return Result.failure(ChatFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteMessage(String messageId) async {
    try {
      await _chatDataSource.deleteMessage(messageId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ChatFailure(e.toString()));
    }
  }

  @override
  Future<Result<ChatEntity>> createChat(ChatEntity chat) async {
    try {
      final chatModel = _mapToChatModel(chat);
      final createdChat = await _chatDataSource.createChat(chatModel);

      if (createdChat != null) {
        return Result.success(_mapToChatEntity(createdChat));
      }

      return Result.failure(
        const ChatFailure('Failed to create chat'),
      );
    } catch (e) {
      return Result.failure(ChatFailure(e.toString()));
    }
  }

  @override
  Future<Result<ChatEntity>> updateChat(ChatEntity chat) async {
    try {
      final chatModel = _mapToChatModel(chat);
      final updatedChat = await _chatDataSource.updateChat(chatModel);

      if (updatedChat != null) {
        return Result.success(_mapToChatEntity(updatedChat));
      }

      return Result.failure(
        const ChatFailure('Failed to update chat'),
      );
    } catch (e) {
      return Result.failure(ChatFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteChat(String chatId) async {
    try {
      await _chatDataSource.deleteChat(chatId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ChatFailure(e.toString()));
    }
  }

  @override
  Stream<List<MessageEntity>> streamChatMessages(String chatId) {
    return _chatDataSource.streamChatMessages(chatId)
        .map((messages) => messages.map(_mapToMessageEntity).toList());
  }

  @override
  Stream<List<ChatEntity>> streamUserChats(String userId) {
    return _chatDataSource.streamUserChats(userId)
        .map((chats) => chats.map(_mapToChatEntity).toList());
  }

  @override
  Future<Result<void>> markMessageAsRead(String messageId, String userId) async {
    try {
      await _chatDataSource.markMessageAsRead(messageId, userId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ChatFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markAllMessagesAsRead(String chatId, String userId) async {
    try {
      await _chatDataSource.markAllMessagesAsRead(chatId, userId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ChatFailure(e.toString()));
    }
  }

  @override
  Stream<List<String>> streamMessageReadReceipts(String messageId) {
    return _chatDataSource.streamMessageReadReceipts(messageId);
  }

  @override
  Future<Result<void>> updateTypingStatus(String userId, String chatId, bool isTyping) async {
    try {
      await _chatDataSource.updateTypingStatus(userId, chatId, isTyping);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ChatFailure(e.toString()));
    }
  }

  @override
  Stream<List<String>> streamTypingIndicators(String chatId) {
    return _chatDataSource.streamTypingIndicators(chatId);
  }

  // Helper method to map model to entity
  ChatEntity _mapToChatEntity(Chat chat) {
    // Create a name based on participants count
    final chatName = chat.participants.length > 1
        ? "Chat with ${chat.participants.length} users"
        : "Direct Chat";

    return ChatEntity(
      id: chat.id,
      participantIds: chat.participants,
      name: chatName,
      lastMessageContent: chat.lastMessage,
      lastMessageSenderId: chat.lastMessageSenderId,
      lastMessageTimestamp: chat.lastMessageTime, // Map from lastMessageTime
      createdAt: chat.createdAt,
      updatedAt: chat.updatedAt ?? chat.lastMessageTime,
    );
  }

  // Helper method to map entity to model
  Chat _mapToChatModel(ChatEntity entity) {
    return Chat(
      id: entity.id,
      participants: entity.participantIds,
      lastMessage: entity.lastMessageContent ?? '', // Map to lastMessage
      lastMessageSenderId: entity.lastMessageSenderId ?? '',
      hasUnreadMessages: false, // Default since entity doesn't track this
      lastMessageTime: entity.lastMessageTimestamp ?? entity.updatedAt, // Map from lastMessageTimestamp to lastMessageTime
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Helper method to map model to entity
  MessageEntity _mapToMessageEntity(Message message) {
    return MessageEntity(
      id: message.id,
      chatId: message.chatId,
      senderId: message.senderId,
      receiverId: message.receiverId,
      content: message.content,
      type: _mapToMessageTypeEntity(message.type),
      status: _mapToMessageStatusEntity(message.status),
      isRead: message.isRead,
      timestamp: message.timestamp,
      mediaUrl: message.mediaUrl,
      thumbnailUrl: message.thumbnailUrl,
      metadata: message.metadata,
      createdAt: message.createdAt ?? message.timestamp,
      updatedAt: message.updatedAt ?? message.timestamp,
    );
  }

  // Helper method to map entity to model
  Message _mapToMessageModel(MessageEntity entity) {
    return Message(
      id: entity.id,
      chatId: entity.chatId,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      content: entity.content,
      type: _mapToMessageTypeModel(entity.type),
      status: _mapToMessageStatusModel(entity.status),
      isRead: entity.isRead,
      timestamp: entity.timestamp ?? entity.createdAt,
      mediaUrl: entity.mediaUrl,
      thumbnailUrl: entity.thumbnailUrl,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Helper method to map message type
  domain_type.MessageType _mapToMessageTypeEntity(MessageType type) {
    switch (type) {
      case MessageType.text:
        return domain_type.MessageType.text;
      case MessageType.image:
        return domain_type.MessageType.image;
      case MessageType.video:
        return domain_type.MessageType.video;
      case MessageType.file:
        return domain_type.MessageType.file;
      case MessageType.audio:
        return domain_type.MessageType.audio;
      case MessageType.location:
        return domain_type.MessageType.location;
      case MessageType.system:
        return domain_type.MessageType.system;
    }
  }

  // Helper method to map message type
  MessageType _mapToMessageTypeModel(domain_type.MessageType type) {
    switch (type) {
      case domain_type.MessageType.text:
        return MessageType.text;
      case domain_type.MessageType.image:
        return MessageType.image;
      case domain_type.MessageType.video:
        return MessageType.video;
      case domain_type.MessageType.file:
        return MessageType.file;
      case domain_type.MessageType.audio:
        return MessageType.audio;
      case domain_type.MessageType.location:
        return MessageType.location;
      case domain_type.MessageType.system:
        return MessageType.system;
    }
  }

  // Helper method to map message status
  domain_status.MessageStatus _mapToMessageStatusEntity(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return domain_status.MessageStatus.sending;
      case MessageStatus.sent:
        return domain_status.MessageStatus.sent;
      case MessageStatus.delivered:
        return domain_status.MessageStatus.delivered;
      case MessageStatus.read:
        return domain_status.MessageStatus.read;
      case MessageStatus.failed:
        return domain_status.MessageStatus.failed;
    }
  }

  // Helper method to map message status
  MessageStatus _mapToMessageStatusModel(domain_status.MessageStatus? status) {
    if(status==null){
      return MessageStatus.sending;
    }
    switch (status) {
      case domain_status.MessageStatus.sending:
        return MessageStatus.sending;
      case domain_status.MessageStatus.sent:
        return MessageStatus.sent;
      case domain_status.MessageStatus.delivered:
        return MessageStatus.delivered;
      case domain_status.MessageStatus.read:
        return MessageStatus.read;
      case domain_status.MessageStatus.failed:
        return MessageStatus.failed;
    }
  }
}