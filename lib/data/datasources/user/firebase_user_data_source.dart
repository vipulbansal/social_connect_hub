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

}