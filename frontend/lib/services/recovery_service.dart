import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/recovery_log.dart';

/// Persists recovery tracker check-ins per user at
/// `users/{uid}/recoveryLogs/{id}`.
class RecoveryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('recoveryLogs');

  String newId() => _uuid.v4();

  Future<void> addLog(RecoveryLog log) async {
    await _col(log.uid).doc(log.id).set(log.toMap());
  }

  Stream<List<RecoveryLog>> watchLogs(String uid) {
    return _col(uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => RecoveryLog.fromMap(d.data())).toList());
  }

  Future<void> deleteLog(String uid, String id) async {
    await _col(uid).doc(id).delete();
  }
}
