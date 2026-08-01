import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/prediction_record.dart';

/// Persists AI prediction results per user at
/// `users/{uid}/predictions/{id}` so that Reports / Report History and
/// the Home screen's "Latest Prediction" summary always reflect real,
/// saved data.
class PredictionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('predictions');

  String newId() => _uuid.v4();

  Future<void> savePrediction(PredictionRecord record) async {
    await _col(record.uid).doc(record.id).set(record.toMap());
  }

  Stream<List<PredictionRecord>> watchPredictions(String uid) {
    return _col(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PredictionRecord.fromMap(d.data()))
            .toList());
  }

  Future<PredictionRecord?> getLatest(String uid) async {
    final snap = await _col(uid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return PredictionRecord.fromMap(snap.docs.first.data());
  }

  Future<PredictionRecord?> getById(String uid, String id) async {
    final doc = await _col(uid).doc(id).get();
    if (!doc.exists) return null;
    return PredictionRecord.fromMap(doc.data()!);
  }

  Future<void> deletePrediction(String uid, String id) async {
    await _col(uid).doc(id).delete();
  }
}
