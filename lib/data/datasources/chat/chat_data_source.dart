import '../../models/chat.dart';
import '../../models/message.dart';

/// Interface for chat data source
abstract class ChatDataSource {
  /// Get a chat by ID
  Future<Chat?> getChatById(String chatId);
  
  /// Get chats for a user
  Future<List<Chat>> getUserChats(String userId);
  
  /// Get messages for a chat
  Future<List<Message>> getChatMessages(String chatId, {int limit = 50, String? lastMessageId});
  
  /// Send a message
  Future<Message?> sendMessage(Message message);
  
  /// Update a message
  Future<Message?> updateMessage(Message message);
  
  /// Delete a message
  Future<void> deleteMessage(String messageId);
  
  /// Create a new chat
  Future<Chat?> createChat(Chat chat);
  
  /// Update a chat
  Future<Chat?> updateChat(Chat chat);
  
  /// Delete a chat
  Future<void> deleteChat(String chatId);
  
  /// Stream chat messages
  Stream<List<Message>> streamChatMessages(String chatId);
  
  /// Stream user chats
  Stream<List<Chat>> streamUserChats(String userId);
  
  /// Mark a message as read by a user
  Future<void> markMessageAsRead(String messageId, String userId);
  
  /// Mark all messages in a chat as read by a user
  Future<void> markAllMessagesAsRead(String chatId, String userId);
  
  /// Stream read receipts for a message
  Stream<List<String>> streamMessageReadReceipts(String messageId);
  
  /// Update typing status for a user in a chat
  Future<void> updateTypingStatus(String userId, String chatId, bool isTyping);
  
  /// Stream typing indicators for a chat
  Stream<List<String>> streamTypingIndicators(String chatId);
}