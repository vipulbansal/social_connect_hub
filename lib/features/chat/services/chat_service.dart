import 'package:flutter/foundation.dart';
import 'package:social_connect_hub/domain/entities/chat/message_status.dart';
import '../../../domain/entities/chat/message_entity.dart';
import '../../../domain/entities/chat/message_type.dart';
import '../../../domain/repositories/chat/chat_repository.dart';
import '../../../domain/repositories/user/user_repository.dart';
import '../../../domain/repositories/auth/auth_repository.dart';
import '../../../domain/entities/chat/chat_entity.dart';
import '../../../domain/entities/user/user_entity.dart';
import '../../../domain/core/result.dart';
import '../../../domain/usecases/notification/send_push_notification_usecase.dart';

/// Chat service that manages chat operations
/// using the Provider pattern and clean architecture principles.
class ChatService extends ChangeNotifier {
  // Core repositories
  final ChatRepository _chatRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  // Use cases
  final SendPushNotificationUseCase? _sendPushNotificationUseCase;

  // Chat state
  List<ChatEntity> _chats = [];
  Map<String, List<MessageEntity>> _messagesCache = {};
  String? _currentChatId;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters for state
  List<ChatEntity> get chats => _chats;
  List<MessageEntity> get currentMessages =>
      _currentChatId != null ? _messagesCache[_currentChatId] ?? [] : [];
  String? get currentChatId => _currentChatId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor
  ChatService({
    required ChatRepository chatRepository,
    required UserRepository userRepository,
    required AuthRepository authRepository,
    SendPushNotificationUseCase? sendPushNotificationUseCase,
  }) : _chatRepository = chatRepository,
        _userRepository = userRepository,
        _authRepository = authRepository,
        _sendPushNotificationUseCase = sendPushNotificationUseCase;

  // Stream chats for the current user - used by UI components directly
  Stream<List<ChatEntity>> watchUserChats() async* {
    final currentUserResult = await _authRepository.getCurrentUserId();

    if (currentUserResult.isFailure) {
      yield [];
      return;
    }

    final userId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );

    if (userId.isEmpty) {
      yield [];
      return;
    }

    yield* _chatRepository.streamUserChats(userId);
  }

  // Compatibility alias for the watchUserChats method
  Stream<List<ChatEntity>> getChatListStream() => watchUserChats();

  // Stream messages for a specific chat - used by UI components directly
  Stream<List<MessageEntity>> watchChatMessages(String chatId) {
    _currentChatId = chatId;
    return _chatRepository.streamChatMessages(chatId);
  }

  // Compatibility alias for the watchChatMessages method
  Stream<List<MessageEntity>> getMessagesStream(String chatId) => watchChatMessages(chatId);

  // Get all chats for the current user
  Future<void> loadUserChats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final currentUserResult = await _authRepository.getCurrentUserId();

    if (currentUserResult.isFailure) {
      _errorMessage = 'Failed to get current user';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final userId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );

    if (userId.isEmpty) {
      _errorMessage = 'Current user ID is empty';
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Using the stream method directly to get a snapshot of chats
    final chatsStream = _chatRepository.streamUserChats(userId);
    chatsStream.listen((chatsList) {
      _chats = chatsList;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  // Get a specific chat by ID
  Future<ChatEntity?> getChatById(String chatId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First check the local cache
      final localChat = _chats.firstWhere(
            (chat) => chat.id == chatId,
        orElse: () => ChatEntity(
          id: '',
          name: '',
          participantIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (localChat.id.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return localChat;
      }

      // If not in cache, fetch from repository
      final result = await _chatRepository.getChatById(chatId);

      _isLoading = false;

      return result.fold(
          onSuccess: (chat) {
            // Add to local cache if not already there
            if (!_chats.any((c) => c.id == chat.id)) {
              _chats.add(chat);
            }
            notifyListeners();
            return chat;
          },
          onFailure: (failure) {
            _errorMessage = failure.message;
            notifyListeners();
            return null;
          }
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Load messages for a specific chat
  Future<void> loadChatMessages(String chatId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentChatId = chatId;
    notifyListeners();

    // Using the stream method directly to get a snapshot of messages
    final messagesStream = _chatRepository.streamChatMessages(chatId);
    messagesStream.listen((messagesList) {
      _messagesCache[chatId] = messagesList;
      _isLoading = false;
      notifyListeners();

      // Mark messages as read
      markMessagesAsRead(chatId);
    }, onError: (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  // Send a new message in a chat
  Future<bool> sendMessage({
    required String chatId,
    required String text,
    MessageType type = MessageType.text,
    String? mediaUrl,
    Map<String, dynamic>? metadata,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final currentUserResult = await _authRepository.getCurrentUserId();

    if (currentUserResult.isFailure) {
      _errorMessage = 'Failed to get current user';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final senderId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );

    if (senderId.isEmpty) {
      _errorMessage = 'Current user ID is empty';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Convert type to content type string
    String contentType;
    switch (type) {
      case MessageType.text:
        contentType = 'text';
        break;
      case MessageType.image:
        contentType = 'image';
        break;
      case MessageType.video:
        contentType = 'video';
        break;
      case MessageType.audio:
        contentType = 'audio';
        break;
      case MessageType.file:
        contentType = 'file';
        break;
      case MessageType.location:
        contentType = 'location';
        break;
      case MessageType.system:
        contentType = 'system';
        break;
      default:
        contentType = 'text';
    }

    final message = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
      chatId: chatId,
      senderId: senderId,
      content: text,
      contentType: contentType,
      status: MessageStatus.sent,
      type: type, // Include the actual enum type
      isRead: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      mediaUrl: mediaUrl,
      metadata: metadata,

    );

    final result = await _chatRepository.sendMessage(message);

    _isLoading = false;

    return result.fold(
        onSuccess: (_) async {
          // Update chat's last message info in local state
          final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
          if (chatIndex != -1) {
            _chats[chatIndex] = _chats[chatIndex].copyWith(
              lastMessageContent: text,
              lastMessageSenderId: senderId,
              lastMessageTimestamp: DateTime.now(),
            );

            // Send push notifications to all other participants
            if (_sendPushNotificationUseCase != null) {
              final chat = _chats[chatIndex];
              final senderDetailsResult = await _userRepository.getUserById(senderId);
              final senderName = senderDetailsResult.fold(
                onSuccess: (user) => user.name,
                onFailure: (_) => 'Someone',
              );

              // Get message preview - truncate if too long
              String messagePreview = text;
              if (type != MessageType.text) {
                messagePreview = "Sent a ${type.toString().split('.').last}";
              } else if (text.length > 50) {
                messagePreview = text.substring(0, 47) + '...';
              }

              // Send to all participants except the sender
              for (final participantId in chat.participantIds) {
                if (participantId != senderId) {
                  await _sendPushNotificationUseCase!.call(
                    SendPushNotificationParams(
                      userId: participantId,
                      title: senderName,
                      body: messagePreview,
                      data: {
                        'type': 'new_message',
                        'chatId': chatId,
                        'senderId': senderId,
                        'senderName': senderName,

                        'messageType': type.toString().split('.').last,
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                      },
                    ),
                  );
                }
              }
            }
          }
          notifyListeners();
          return true;
        },
        onFailure: (failure) {
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        }
    );
  }

  // Create a new private chat (one-to-one) or get existing one
  Future<String?> createOrGetChat(String otherUserId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final currentUserResult = await _authRepository.getCurrentUserId();

    if (currentUserResult.isFailure) {
      _errorMessage = 'Failed to get current user';
      _isLoading = false;
      notifyListeners();
      return null;
    }

    final currentUserId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );

    if (currentUserId.isEmpty) {
      _errorMessage = 'Current user ID is empty';
      _isLoading = false;
      notifyListeners();
      return null;
    }

    // First check if there's an existing chat with this user
    final existingChat = _chats.firstWhere(
          (chat) => chat.participantIds.length == 2 &&
          chat.participantIds.contains(currentUserId) &&
          chat.participantIds.contains(otherUserId),
      orElse: () => ChatEntity(
        id: '',
        name: '',
        participantIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (existingChat.id.isNotEmpty) {
      _isLoading = false;
      notifyListeners();
      return existingChat.id;
    }

    // Get the other user's name for the chat
    final otherUserResult = await _userRepository.getUserById(otherUserId);

    if (otherUserResult.isFailure) {
      _errorMessage = 'Failed to get user information';
      _isLoading = false;
      notifyListeners();
      return null;
    }

    final otherUser = otherUserResult.fold(
      onSuccess: (user) => user,
      onFailure: (_) => null,
    );

    if (otherUser == null) {
      _errorMessage = 'User not found';
      _isLoading = false;
      notifyListeners();
      return null;
    }

    // Create new chat
    final chat = ChatEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
      name: otherUser.name,
      participantIds: [currentUserId, otherUserId],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _chatRepository.createChat(chat);

    _isLoading = false;

    return result.fold(
        onSuccess: (createdChat) {
          // Add the new chat to local state
          _chats.add(createdChat);
          notifyListeners();
          return createdChat.id;
        },
        onFailure: (failure) {
          _errorMessage = failure.message;
          notifyListeners();
          return null;
        }
    );
  }



  // Delete a chat
  Future<bool> deleteChat(String chatId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _chatRepository.deleteChat(chatId);

      _isLoading = false;

      return result.fold(
          onSuccess: (_) {
            // Remove from local state
            _chats.removeWhere((c) => c.id == chatId);
            if (_currentChatId == chatId) {
              _currentChatId = null;
              _messagesCache.remove(chatId);
            }
            notifyListeners();
            return true;
          },
          onFailure: (failure) {
            _errorMessage = failure.message;
            notifyListeners();
            return false;
          }
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get chat participants
  Future<List<UserEntity>> getChatParticipants(String chatId) async {
    try {
      // Get the chat
      final chatResult = await _chatRepository.getChatById(chatId);

      final chat = chatResult.fold(
        onSuccess: (chat) => chat,
        onFailure: (_) => null,
      );

      if (chat == null) {
        return [];
      }

      // Get participant user objects
      final participants = <UserEntity>[];
      for (final userId in chat.participantIds) {
        final userResult = await _userRepository.getUserById(userId);
        userResult.fold(
            onSuccess: (user) => participants.add(user),
            onFailure: (_) {} // Skip on failure
        );
      }

      return participants;
    } catch (e) {
      debugPrint('Error getting chat participants: $e');
      return [];
    }
  }

  // Update typing status for the current user
  Future<void> updateTypingStatus({
    required String chatId,
    required bool isTyping,
  }) async {
    final currentUserResult = await _authRepository.getCurrentUserId();

    if (currentUserResult.isFailure) {
      return;
    }

    final userId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );

    if (userId.isEmpty) {
      return;
    }

    await _chatRepository.updateTypingStatus(userId, chatId, isTyping);
  }

  // Stream users who are typing in a specific chat
  Stream<List<String>> streamTypingIndicators(String chatId) {
    return _chatRepository.streamTypingIndicators(chatId);
  }

  // Mark all messages in a chat as read
  Future<void> markMessagesAsRead(String chatId) async {
    final currentUserResult = await _authRepository.getCurrentUserId();

    if (currentUserResult.isFailure) {
      return;
    }

    final userId = currentUserResult.fold(
      onSuccess: (id) => id,
      onFailure: (_) => '',
    );

    if (userId.isEmpty) {
      return;
    }

    await _chatRepository.markAllMessagesAsRead(chatId, userId);
  }

  // Set the current active chat
  void setCurrentChat(String chatId) {
    _currentChatId = chatId;
    notifyListeners();

    // Load messages for this chat
    loadChatMessages(chatId);
  }

  // Clear the current chat selection
  void clearCurrentChat() {
    _currentChatId = null;
    notifyListeners();
  }

  // Clear any error messages
  void clearErrors() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get a user by ID - for UI components to use
  Future<UserEntity?> getUserById(String userId) async {
    if (userId.isEmpty) return null;

    final userResult = await _userRepository.getUserById(userId);

    return userResult.fold(
      onSuccess: (user) => user,
      onFailure: (_) => null,
    );
  }
}