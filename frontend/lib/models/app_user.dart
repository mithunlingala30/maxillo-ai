import 'package:cloud_firestore/cloud_firestore.dart';

/// Full profile of a MaxilloAI user, stored in Firestore at
/// `users/{uid}`. Holds every detail collected at registration plus
/// medical/profile data editable later from the Profile screen.
class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? smokingStatus;
  final String? medicalHistory;
  final String? phone;
  final String? photoUrl;
  final bool notificationsEnabled;
  final bool privacyDataSharing;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.smokingStatus,
    this.medicalHistory,
    this.phone,
    this.photoUrl,
    this.notificationsEnabled = true,
    this.privacyDataSharing = false,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'smokingStatus': smokingStatus,
      'medicalHistory': medicalHistory,
      'phone': phone,
      'photoUrl': photoUrl,
      'notificationsEnabled': notificationsEnabled,
      'privacyDataSharing': privacyDataSharing,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;
    return AppUser(
      uid: map['uid'] as String,
      fullName: (map['fullName'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      age: map['age'] is int ? map['age'] as int : (map['age'] as num?)?.toInt(),
      gender: map['gender'] as String?,
      heightCm: (map['heightCm'] as num?)?.toDouble(),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      smokingStatus: map['smokingStatus'] as String?,
      medicalHistory: map['medicalHistory'] as String?,
      phone: map['phone'] as String?,
      photoUrl: map['photoUrl'] as String?,
      notificationsEnabled: (map['notificationsEnabled'] as bool?) ?? true,
      privacyDataSharing: (map['privacyDataSharing'] as bool?) ?? false,
      createdAt: _ts(map['createdAt']) ?? DateTime.now(),
      updatedAt: _ts(map['updatedAt']),
    );
  }

  AppUser copyWith({
    String? fullName,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? smokingStatus,
    String? medicalHistory,
    String? phone,
    String? photoUrl,
    bool? notificationsEnabled,
    bool? privacyDataSharing,
  }) {
    return AppUser(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      smokingStatus: smokingStatus ?? this.smokingStatus,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      privacyDataSharing: privacyDataSharing ?? this.privacyDataSharing,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
