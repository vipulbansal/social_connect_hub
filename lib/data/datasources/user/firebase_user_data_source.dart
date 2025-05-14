import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/user.dart';
import 'user_data_source.dart';

/// Firebase implementation of [UserDataSource]
class FirebaseUserDataSource implements UserDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  
  /// Constructor
  const FirebaseUserDataSource({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;
  
  @override
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists && doc.data() != null) {
        return User.fromJson({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  @override
  Future<List<User>> searchUsers(String query)async {
    try {
      // Convert the query to lowercase for case-insensitive search
      final queryLower = query.toLowerCase();
      final nameSnap = await _firestore.collection('users').where(
          'name', isGreaterThanOrEqualTo: queryLower )
          .where('name', isLessThanOrEqualTo:'$queryLower\uf8ff')
          .get();

      final emailSnap = await _firestore.collection('users').where(
          'email', isEqualTo: query)
          .limit(5)
          .get();

      final nameResults = nameSnap.docs.map((doc) {
        return User.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();

      final emailResults = emailSnap.docs.map((doc) {
        return User.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();

      // Remove duplicates
      final combinedResults = [...nameResults];
      for (User user in emailResults) {
        if (!combinedResults.any((u) => u.id == user.id)) {
          combinedResults.add(user);
        }
      }
      return combinedResults;
    }
    catch(e){
      return [];
    }
  }

  @override
  Future<void> addFcmToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (e) {
      print('Error adding FCM token: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Delete the user document
      await _firestore.collection('users').doc(userId).delete();

      // Delete the Firebase Auth user
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null && firebaseUser.uid == userId) {
        await firebaseUser.delete();
      }
    } catch (e) {
      print('Error deleting user account: $e');
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      return null;
    }

    return getUserById(userId);
  }

  @override
  Future<List<String>> getUserFcmTokens(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        final userData = doc.data()!;
        final tokens = userData['fcmTokens'] as List<dynamic>? ?? [];
        return tokens.map((token) => token.toString()).toList();
      }

      return [];
    } catch (e) {
      print('Error getting user FCM tokens: $e');
      return [];
    }
  }

  @override
  Future<bool> getUserOnlineStatus(String userId) {
    // TODO: implement getUserOnlineStatus
    throw UnimplementedError();
  }

  @override
  Future<void> removeFcmToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    } catch (e) {
      print('Error removing FCM token: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': isOnline ? 'online' : 'offline',
        'lastActive': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating user online status: $e');
      rethrow;
    }
  }

  @override
  Future<User?> updateUserProfile(User user) async {
    try {
      // Update Firestore document
      await _firestore.collection('users').doc(user.id).update(user.toJson());

      // Update Firebase Auth user profile if needed
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null && firebaseUser.uid == user.id) {
        await firebaseUser.updateDisplayName(user.name);
        if (user.profilePicUrl != null) {
          await firebaseUser.updatePhotoURL(user.profilePicUrl);
        }
      }

      // Return the updated user
      return getUserById(user.id);
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }


  @override
  Stream<User?> watchUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return User.fromJson({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    });
  }

  @override
  Stream<User?> watchCurrentUser() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      final userId = firebaseUser.uid;
      return await getUserById(userId);
    });
  }

}