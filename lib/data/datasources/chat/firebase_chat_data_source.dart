import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/chat.dart';
import '../../models/message.dart';
import 'chat_data_source.dart';

/// Firebase implementation of [ChatDataSource]
class FirebaseChatDataSource implements ChatDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  
  /// Constructor
  const FirebaseChatDataSource({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;
  
  @override
  Future<Chat?> getChatById(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return Chat.fromJson({
          'id': doc.id,
          ...data,
        });
      }
      
      return null;
    } catch (e) {
      print('Error getting chat by ID: $e');
      return null;
    }
  }
  
  @override
  Future<List<Chat>> getUserChats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Chat.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    } catch (e) {
      print('Error getting user chats: $e');
      return [];
    }
  }
  
  @override
  Future<List<Message>> getChatMessages(
    String chatId, {
    int limit = 50,
    String? lastMessageId,
  }) async {
    try {
      Query query = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(limit);
      
      if (lastMessageId != null) {
        final lastMessageDoc = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(lastMessageId)
            .get();
        
        if (lastMessageDoc.exists) {
          query = query.startAfterDocument(lastMessageDoc);
        }
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Message.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    } catch (e) {
      print('Error getting chat messages: $e');
      return [];
    }
  }
  
  @override
  Future<Message?> sendMessage(Message message) async {
    try {
      // Get reference to chat document
      final chatRef = _firestore.collection('chats').doc(message.chatId);
      
      // Get reference to message document
      final messageRef = chatRef.collection('messages').doc(message.id);
      
      // Run as a batch to ensure data consistency
      final batch = _firestore.batch();
      
      // Add message to chat's messages collection
      batch.set(messageRef, message.toJson());
      
      // Update chat document with last message info
      batch.update(chatRef, {
        'lastMessage': message.content,
        'lastMessageSenderId': message.senderId,
        'lastMessageTime': message.timestamp.toIso8601String(),
        'hasUnreadMessages': true,
      });
      
      // Commit the batch
      await batch.commit();
      
      return message;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }
  
  @override
  Future<Message?> updateMessage(Message message) async {
    try {
      await _firestore
          .collection('chats')
          .doc(message.chatId)
          .collection('messages')
          .doc(message.id)
          .update(message.toJson());
      
      return message;
    } catch (e) {
      print('Error updating message: $e');
      return null;
    }
  }
  
  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      // To delete a message, we need the chat ID
      // First, we need to find which chat contains this message
      final chatsSnapshot = await _firestore.collection('chats').get();
      
      for (final chatDoc in chatsSnapshot.docs) {
        final messageSnapshot = await _firestore
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .doc(messageId)
            .get();
        
        if (messageSnapshot.exists) {
          await messageSnapshot.reference.delete();
          
          // If this was the last message, update the chat's lastMessage
          final latestMessageSnapshot = await _firestore
              .collection('chats')
              .doc(chatDoc.id)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();
          
          if (latestMessageSnapshot.docs.isNotEmpty) {
            final latestMessage = latestMessageSnapshot.docs.first;
            final latestMessageData = latestMessage.data();
            
            await _firestore.collection('chats').doc(chatDoc.id).update({
              'lastMessage': latestMessageData['content'] ?? '',
              'lastMessageSenderId': latestMessageData['senderId'] ?? '',
              'lastMessageTime': latestMessageData['timestamp'] ?? DateTime.now().toIso8601String(),
            });
          } else {
            // No messages left in the chat
            await _firestore.collection('chats').doc(chatDoc.id).update({
              'lastMessage': '',
              'lastMessageSenderId': '',
              'lastMessageTime': DateTime.now().toIso8601String(),
              'hasUnreadMessages': false,
            });
          }
          
          // We found and deleted the message, so we can break the loop
          break;
        }
      }
    } catch (e) {
      print('Error deleting message: $e');
      throw Exception('Failed to delete message: $e');
    }
  }
  
  @override
  Future<Chat?> createChat(Chat chat) async {
    try {
      // Check if direct chat between the same participants already exists
      if (chat.participants.length == 2) {
        final existingChat = await findExistingDirectChat(
          chat.participants[0],
          chat.participants[1],
        );
        
        if (existingChat != null) {
          return existingChat;
        }
      }
      
      // Create a new chat document
      final docRef = _firestore.collection('chats').doc(chat.id);
      await docRef.set(chat.toJson());
      
      return chat;
    } catch (e) {
      print('Error creating chat: $e');
      return null;
    }
  }
  
  /// Find an existing direct chat between two users
  Future<Chat?> findExistingDirectChat(String user1Id, String user2Id) async {
    try {
      // Query for chats where user1 is a participant
      final query1Snapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: user1Id)
          .get();
      
      // Filter the results to find chats where user2 is also a participant
      for (final doc in query1Snapshot.docs) {
        final participants = List<String>.from(doc.data()['participants'] ?? []);
        
        if (participants.contains(user2Id) && participants.length == 2) {
          return Chat.fromJson({
            'id': doc.id,
            ...doc.data(),
          });
        }
      }
      
      return null;
    } catch (e) {
      print('Error finding existing direct chat: $e');
      return null;
    }
  }
  
  @override
  Future<Chat?> updateChat(Chat chat) async {
    try {
      await _firestore.collection('chats').doc(chat.id).update(chat.toJson());
      return chat;
    } catch (e) {
      print('Error updating chat: $e');
      return null;
    }
  }
  
  @override
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages in the chat
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();
      
      final batch = _firestore.batch();
      
      for (final messageDoc in messagesSnapshot.docs) {
        batch.delete(messageDoc.reference);
      }
      
      // Delete the chat document
      batch.delete(_firestore.collection('chats').doc(chatId));
      
      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error deleting chat: $e');
      throw Exception('Failed to delete chat: $e');
    }
  }
  
  @override
  Stream<List<Message>> streamChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Message.fromJson({
                'id': doc.id,
                ...data,
              });
            })
            .toList());
  }
  
  @override
  Stream<List<Chat>> streamUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Chat.fromJson({
                'id': doc.id,
                ...data,
              });
            })
            .toList());
  }
  
  @override
  Future<void> markMessageAsRead(String messageId, String userId) async {
    try {
      // Find the chat that contains this message
      final chatsSnapshot = await _firestore.collection('chats').get();
      
      for (final chatDoc in chatsSnapshot.docs) {
        final messageSnapshot = await _firestore
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .doc(messageId)
            .get();
        
        if (messageSnapshot.exists) {
          // Update the read status of the message
          final readBy = List<String>.from(messageSnapshot.data()?['readBy'] ?? []);
          
          if (!readBy.contains(userId)) {
            readBy.add(userId);
            
            await messageSnapshot.reference.update({
              'readBy': readBy,
              'status': readBy.isNotEmpty ? 'read' : 'delivered',
            });
          }
          
          // If the current user is not the sender and this is the latest message,
          // update the chat's hasUnreadMessages field
          final senderId = messageSnapshot.data()?['senderId'];
          
          if (senderId != userId) {
            final latestMessageSnapshot = await _firestore
                .collection('chats')
                .doc(chatDoc.id)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .limit(1)
                .get();
            
            if (latestMessageSnapshot.docs.isNotEmpty &&
                latestMessageSnapshot.docs.first.id == messageId) {
              await _firestore.collection('chats').doc(chatDoc.id).update({
                'hasUnreadMessages': false,
              });
            }
          }
          
          break;
        }
      }
    } catch (e) {
      print('Error marking message as read: $e');
      throw Exception('Failed to mark message as read: $e');
    }
  }
  
  @override
  Future<void> markAllMessagesAsRead(String chatId, String userId) async {
    try {
      // Get all unread messages in the chat
      final unreadMessagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('readBy', arrayContains: userId, isEqualTo: false)
          .get();
      
      // Update each message's read status
      final batch = _firestore.batch();
      
      for (final messageDoc in unreadMessagesSnapshot.docs) {
        final readBy = List<String>.from(messageDoc.data()['readBy'] ?? []);
        
        if (!readBy.contains(userId)) {
          readBy.add(userId);
          
          batch.update(messageDoc.reference, {
            'readBy': readBy,
            'status': 'read',
          });
        }
      }
      
      // Update the chat's hasUnreadMessages field
      batch.update(_firestore.collection('chats').doc(chatId), {
        'hasUnreadMessages': false,
      });
      
      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error marking all messages as read: $e');
      throw Exception('Failed to mark all messages as read: $e');
    }
  }
  
  @override
  Stream<List<String>> streamMessageReadReceipts(String messageId) {
    // To get read receipts, we need to find which chat contains this message
    return _firestore.collectionGroup('messages')
        .where('id', isEqualTo: messageId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return <String>[];
          }
          
          final messageDoc = snapshot.docs.first;
          return List<String>.from(messageDoc.data()['readBy'] ?? []);
        });
  }
  
  @override
  Future<void> updateTypingStatus(String userId, String chatId, bool isTyping) async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      
      // Update typing status in the chat's typing collection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('typing')
          .doc(userId)
          .set({
        'isTyping': isTyping,
        'timestamp': currentTime,
      });
      
      // If not typing, delete the typing status after 5 seconds
      if (!isTyping) {
        Future.delayed(Duration(seconds: 5), () async {
          try {
            final docRef = _firestore
                .collection('chats')
                .doc(chatId)
                .collection('typing')
                .doc(userId);
            
            final doc = await docRef.get();
            
            // Only delete if the timestamp hasn't changed (no new typing)
            if (doc.exists && doc.data()?['timestamp'] == currentTime) {
              await docRef.delete();
            }
          } catch (e) {
            print('Error deleting typing status: $e');
          }
        });
      }
    } catch (e) {
      print('Error updating typing status: $e');
      throw Exception('Failed to update typing status: $e');
    }
  }
  
  @override
  Stream<List<String>> streamTypingIndicators(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .where('isTyping', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.id)
            .toList());
  }
}