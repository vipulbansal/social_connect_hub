import '../../core/result.dart';
import '../../entities/chat/chat_entity.dart';
import '../../entities/chat/message_entity.dart';

/// Interface for chat repository
abstract class ChatRepository {
  /// Get a chat by ID
  Future<Result<ChatEntity>> getChatById(String chatId);
  
  /// Get chats for a user
  Future<Result<List<ChatEntity>>> getUserChats(String userId);

  /// Get messages for a chat
  Future<Result<List<MessageEntity>>> getChatMessages(String chatId, {int limit = 50, String? lastMessageId});


  /// Send a message
  Future<Result<MessageEntity>> sendMessage(MessageEntity message);
  
  /// Update a message
  Future<Result<MessageEntity>> updateMessage(MessageEntity message);
  
  /// Delete a message
  Future<Result<void>> deleteMessage(String messageId);
  
  /// Create a new chat
  Future<Result<ChatEntity>> createChat(ChatEntity chat);
  
  /// Update a chat
  Future<Result<ChatEntity>> updateChat(ChatEntity chat);
  
  /// Delete a chat
  Future<Result<void>> deleteChat(String chatId);

  /// Stream chat messages
  Stream<List<MessageEntity>> streamChatMessages(String chatId);
  
  /// Stream user chats
  Stream<List<ChatEntity>> streamUserChats(String userId);
  
  /// Mark a message as read by a user
  Future<Result<void>> markMessageAsRead(String messageId, String userId);
  
  /// Mark all messages in a chat as read by a user
  Future<Result<void>> markAllMessagesAsRead(String chatId, String userId);
  
  /// Stream read receipts for a message
  Stream<List<String>> streamMessageReadReceipts(String messageId);
  
  /// Update typing status for a user in a chat
  Future<Result<void>> updateTypingStatus(String userId, String chatId, bool isTyping);
  
  /// Stream typing indicators for a chat
  Stream<List<String>> streamTypingIndicators(String chatId);
}