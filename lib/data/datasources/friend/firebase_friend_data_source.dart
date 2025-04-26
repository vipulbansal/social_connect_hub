import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:social_connect_hub/data/models/friend_request.dart';
import 'package:social_connect_hub/data/models/user.dart';

import 'friend_data_source.dart';

/// Firebase implementation of [FriendDataSource]
class FirebaseFriendDataSource implements FriendDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// Constructor
  const FirebaseFriendDataSource({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<List<User>> getUserFriends(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists || userDoc.data() == null) {
        return [];
      }

      final List<dynamic> friendIds = userDoc.data()!['friends'] ?? [];

      if (friendIds.isEmpty) {
        return [];
      }

      final friendDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds.cast<String>())
          .get();

      return friendDocs.docs
          .map((doc) => User.fromJson({
        'id': doc.id,
        ...doc.data(),
      }))
          .toList();
    } catch (e) {
      print('Error getting user friends: $e');
      return [];
    }
  }

  @override
  Future<List<FriendRequest>> getUserFriendRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('friendRequests')
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FriendRequest.fromJson({
        'id': doc.id,
        ...doc.data(),
      }))
          .toList();
    } catch (e) {
      print('Error getting user friend requests: $e');
      return [];
    }
  }

  @override
  Future<List<FriendRequest>> getFriendRequests(String userId) async {
    try {
      // Get both received and sent friend requests
      final receivedSnapshot = await _firestore
          .collection('friendRequests')
          .where('receiverId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      final sentSnapshot = await _firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      final receivedRequests = receivedSnapshot.docs
          .map((doc) => FriendRequest.fromJson({
        'id': doc.id,
        ...doc.data(),
      }))
          .toList();

      final sentRequests = sentSnapshot.docs
          .map((doc) => FriendRequest.fromJson({
        'id': doc.id,
        ...doc.data(),
      }))
          .toList();

      // Combine both lists
      return [...receivedRequests, ...sentRequests];
    } catch (e) {
      print('Error getting all friend requests: $e');
      return [];
    }
  }

  @override
  Future<List<FriendRequest>> getUserSentFriendRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FriendRequest.fromJson({
        'id': doc.id,
        ...doc.data(),
      }))
          .toList();
    } catch (e) {
      print('Error getting user sent friend requests: $e');
      return [];
    }
  }

  @override
  Future<FriendRequest?> sendFriendRequest(String senderId, String receiverId) async {
    try {
      // Check if users are already friends
      final areFriends = await this.areFriends(senderId, receiverId);

      if (areFriends) {
        print('Users are already friends');
        return null;
      }

      // Check if there's already a pending request between these users
      final existingRequest = await _firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        print('Friend request already exists');

        // Return the existing request
        final doc = existingRequest.docs.first;
        return FriendRequest.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }

      // Check if there's a request from the receiver to the sender
      final reverseRequest = await _firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: receiverId)
          .where('receiverId', isEqualTo: senderId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (reverseRequest.docs.isNotEmpty) {
        print('Reverse friend request exists');

        // Accept the reverse request automatically
        await acceptFriendRequest(reverseRequest.docs.first.id);

        return FriendRequest.fromJson({
          'id': reverseRequest.docs.first.id,
          'senderId': receiverId,
          'receiverId': senderId,
          'status': 'accepted',
          'timestamp': DateTime.now(),
        });
      }

      // Create a new friend request
      final requestData = {
        'senderId': senderId,
        'receiverId': receiverId,
        'status': 'pending',
        'timestamp': DateTime.now(),
      };

      final docRef = await _firestore.collection('friendRequests').add(requestData);

      // Create a new FriendRequest object with the document ID
      return FriendRequest(
        id: docRef.id,
        senderId: senderId,
        receiverId: receiverId,
        status: FriendRequestStatus.pending,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error sending friend request: $e');
      return null;
    }
  }

  @override
  Future<bool> acceptFriendRequest(String requestId) async {
    try {
      final requestDoc = await _firestore.collection('friendRequests').doc(requestId).get();

      if (!requestDoc.exists || requestDoc.data() == null) {
        print('Friend request does not exist');
        return false;
      }

      final requestData = requestDoc.data()!;
      final senderId = requestData['senderId'] as String;
      final receiverId = requestData['receiverId'] as String;

      // Update the friend request status
      await _firestore.collection('friendRequests').doc(requestId).update({
        'status': 'accepted',
        'acceptedAt': DateTime.now(),
      });

      // Run a batch write to update both users' friends lists
      final batch = _firestore.batch();

      // Update sender's friends list
      final senderRef = _firestore.collection('users').doc(senderId);
      batch.update(senderRef, {
        'friends': FieldValue.arrayUnion([receiverId]),
      });

      // Update receiver's friends list
      final receiverRef = _firestore.collection('users').doc(receiverId);
      batch.update(receiverRef, {
        'friends': FieldValue.arrayUnion([senderId]),
      });

      // Commit the batch
      await batch.commit();

      return true;
    } catch (e) {
      print('Error accepting friend request: $e');
      return false;
    }
  }

  @override
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friendRequests').doc(requestId).update({
        'status': 'rejected',
        'rejectedAt': DateTime.now(),
      });

      return true;
    } catch (e) {
      print('Error rejecting friend request: $e');
      return false;
    }
  }

  @override
  Future<bool> cancelFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friendRequests').doc(requestId).update({
        'status': 'cancelled',
        'cancelledAt': DateTime.now(),
      });

      return true;
    } catch (e) {
      print('Error cancelling friend request: $e');
      return false;
    }
  }

  @override
  Future<bool> removeFriend(String userId, String friendId) async {
    try {
      // Run a batch write to update both users' friends lists
      final batch = _firestore.batch();

      // Update user's friends list
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'friends': FieldValue.arrayRemove([friendId]),
      });

      // Update friend's friends list
      final friendRef = _firestore.collection('users').doc(friendId);
      batch.update(friendRef, {
        'friends': FieldValue.arrayRemove([userId]),
      });

      // Commit the batch
      await batch.commit();

      return true;
    } catch (e) {
      print('Error removing friend: $e');
      return false;
    }
  }

  @override
  Future<bool> areFriends(String userId, String otherUserId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists || userDoc.data() == null) {
        return false;
      }

      final List<dynamic> friendIds = userDoc.data()!['friends'] ?? [];

      return friendIds.contains(otherUserId);
    } catch (e) {
      print('Error checking if users are friends: $e');
      return false;
    }
  }

  @override
  Stream<List<User>> streamUserFriends(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((userDoc) async {
      if (!userDoc.exists || userDoc.data() == null) {
        return <User>[];
      }

      final List<dynamic> friendIds = userDoc.data()!['friends'] ?? [];

      if (friendIds.isEmpty) {
        return <User>[];
      }

      final friendDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds.cast<String>())
          .get();

      return friendDocs.docs
          .map((doc) => User.fromJson({
        'id': doc.id,
        ...doc.data(),
      }))
          .toList();
    });
  }

  @override
  Stream<List<FriendRequest>> streamUserFriendRequests(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FriendRequest.fromJson({
      'id': doc.id,
      ...doc.data(),
    }))
        .toList());
  }

  @override
  Stream<List<FriendRequest>> streamUserSentFriendRequests(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FriendRequest.fromJson({
      'id': doc.id,
      ...doc.data(),
    }))
        .toList());
  }

  @override
  Stream<List<FriendRequest>> streamReceivedFriendRequests(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
//        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FriendRequest.fromJson({
      'id': doc.id,
      ...doc.data(),
    }))
        .toList());
  }

  @override
  Stream<List<FriendRequest>> streamSentFriendRequests(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FriendRequest.fromJson({
      'id': doc.id,
      ...doc.data(),
    }))
        .toList());
  }
}