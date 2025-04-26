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

}