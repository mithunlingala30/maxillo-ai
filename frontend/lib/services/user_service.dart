import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

/// All reads/writes for the `users` collection - this is where "all the
/// details of a particular user" live: personal info, medical history,
/// contact info, and app settings (notifications/privacy).
class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<void> createUserProfile(AppUser user) async {
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!..putIfAbsent('uid', () => uid));
  }

  /// Fetches the profile, or creates a minimal one if this is the first
  /// time we see this uid (e.g. first Google sign-in).
  Future<AppUser> getOrCreateUserProfile({
    required String uid,
    required String email,
    required String fallbackName,
    String? photoUrl,
  }) async {
    final existing = await getUserProfile(uid);
    if (existing != null) return existing;

    final newUser = AppUser(
      uid: uid,
      fullName: fallbackName,
      email: email,
      photoUrl: photoUrl,
    );
    await createUserProfile(newUser);
    return newUser;
  }

  Stream<AppUser?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data()!..putIfAbsent('uid', () => uid));
    });
  }

  Future<void> updateUserProfile(AppUser user) async {
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> updateFields(String uid, Map<String, dynamic> fields) async {
    fields['updatedAt'] = FieldValue.serverTimestamp();
    await _users.doc(uid).set(fields, SetOptions(merge: true));
  }

  /// Deletes the user's profile plus their predictions/recovery
  /// sub-collections (used on account deletion).
  Future<void> deleteUserData(String uid) async {
    final batch = _db.batch();
    final predictions = await _users.doc(uid).collection('predictions').get();
    for (final doc in predictions.docs) {
      batch.delete(doc.reference);
    }
    final recovery = await _users.doc(uid).collection('recoveryLogs').get();
    for (final doc in recovery.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_users.doc(uid));
    await batch.commit();
  }
}
