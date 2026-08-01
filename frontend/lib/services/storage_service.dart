import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Uploads patient images (facial photos, medical scans, recovery
/// progress photos) to Firebase Storage under a per-user path, and
/// returns a public download URL that is stored alongside the
/// prediction/recovery records in Firestore.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile({
    required String uid,
    required Uint8List file,
    required String folder, // e.g. "predictions", "recovery", "profile"
    String? fileName,
  }) async {
    try {
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('users/$uid/$folder/$name');
      final task = await ref.putData(file).timeout(const Duration(seconds: 4));
      return await task.ref.getDownloadURL().timeout(const Duration(seconds: 3));
    } catch (e) {
      print('Firebase Storage upload skipped or timed out: $e');
      return null;
    }
  }

  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (_) {
      // Ignore - file may already be gone.
    }
  }
}
