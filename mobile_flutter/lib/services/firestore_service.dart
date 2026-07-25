import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> createUserProfile(UserProfile profile) async {
    await _users.doc(profile.uid).set(profile.toFirestore());
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _users.doc(profile.uid).update(profile.toFirestore());
  }
}
