import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads the user profile document: users/{uid}
class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>> fetchUserData(String uid) async {
    final document = await _firestore.collection('users').doc(uid).get();
    return document.data() ?? {};
  }
}
