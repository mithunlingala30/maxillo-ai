import 'package:cloud_firestore/cloud_firestore.dart';

/// A single recovery check-in, stored at `users/{uid}/recoveryLogs/{id}`.
/// Used by the Recovery Tracker to plot healing/swelling graphs and to
/// show a photo timeline.
class RecoveryLog {
  final String id;
  final String uid;
  final String milestone; // Post-Op Day, Week 1, Month 1, Month 3, Month 6
  final int painLevel; // 0-10
  final int swellingLevel; // 0-10
  final int recoveryPercent; // 0-100
  final String? photoUrl;
  final String notes;
  final DateTime createdAt;

  RecoveryLog({
    required this.id,
    required this.uid,
    required this.milestone,
    required this.painLevel,
    required this.swellingLevel,
    required this.recoveryPercent,
    this.photoUrl,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': uid,
        'milestone': milestone,
        'painLevel': painLevel,
        'swellingLevel': swellingLevel,
        'recoveryPercent': recoveryPercent,
        'photoUrl': photoUrl,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory RecoveryLog.fromMap(Map<String, dynamic> map) {
    DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;
    return RecoveryLog(
      id: map['id'] as String,
      uid: map['uid'] as String,
      milestone: (map['milestone'] ?? '') as String,
      painLevel: (map['painLevel'] as num?)?.toInt() ?? 0,
      swellingLevel: (map['swellingLevel'] as num?)?.toInt() ?? 0,
      recoveryPercent: (map['recoveryPercent'] as num?)?.toInt() ?? 0,
      photoUrl: map['photoUrl'] as String?,
      notes: (map['notes'] ?? '') as String,
      createdAt: _ts(map['createdAt']) ?? DateTime.now(),
    );
  }
}
