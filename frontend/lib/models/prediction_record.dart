import 'package:cloud_firestore/cloud_firestore.dart';

/// One AI prediction run, stored at `users/{uid}/predictions/{id}`.
/// Captures the patient/reconstruction inputs sent to the backend and
/// the outcome returned by the deployed Gemini model, so it can be
/// re-rendered on the Results screen, Reports list and PDF export.
class PredictionRecord {
  final String id;
  final String uid;

  // Step 1: patient info snapshot at time of prediction
  final String name;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String smokingStatus;
  final String medicalHistory;

  // Step 2: reconstruction details
  final String surgeryType; // Jaw / Cheek / Trauma / Tumour / Congenital
  final String reconstructionMethod;
  final String affectedRegion;
  final DateTime? surgeryDate;

  // Step 3: uploaded image URLs (Firebase Storage)
  final String? facialImageUrl;
  final String? scanImageUrl;

  // Step 5: AI result
  final double confidenceScore; // 0-100
  final String reliability; // Low / Medium / High
  final String riskLevel; // Low / Medium / High
  final Map<String, dynamic> softTissueMetrics; // e.g. lipMovementMm, chinPositionMm...
  final String aiSummary;
  final String recoveryEstimate; // e.g. "6 Months"
  final String modelVersion;

  final DateTime createdAt;
  final String status; // completed / processing / failed

  PredictionRecord({
    required this.id,
    required this.uid,
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.smokingStatus,
    required this.medicalHistory,
    required this.surgeryType,
    required this.reconstructionMethod,
    required this.affectedRegion,
    this.surgeryDate,
    this.facialImageUrl,
    this.scanImageUrl,
    this.confidenceScore = 0,
    this.reliability = 'Medium',
    this.riskLevel = 'Low',
    this.softTissueMetrics = const {},
    this.aiSummary = '',
    this.recoveryEstimate = '6 Months',
    this.modelVersion = 'MaxilloAI-Gemini-v1',
    DateTime? createdAt,
    this.status = 'completed',
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'smokingStatus': smokingStatus,
      'medicalHistory': medicalHistory,
      'surgeryType': surgeryType,
      'reconstructionMethod': reconstructionMethod,
      'affectedRegion': affectedRegion,
      'surgeryDate':
          surgeryDate != null ? Timestamp.fromDate(surgeryDate!) : null,
      'facialImageUrl': facialImageUrl,
      'scanImageUrl': scanImageUrl,
      'confidenceScore': confidenceScore,
      'reliability': reliability,
      'riskLevel': riskLevel,
      'softTissueMetrics': softTissueMetrics,
      'aiSummary': aiSummary,
      'recoveryEstimate': recoveryEstimate,
      'modelVersion': modelVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  factory PredictionRecord.fromMap(Map<String, dynamic> map) {
    DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;
    return PredictionRecord(
      id: map['id'] as String,
      uid: map['uid'] as String,
      name: (map['name'] ?? '') as String,
      age: (map['age'] as num?)?.toInt() ?? 0,
      gender: (map['gender'] ?? '') as String,
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0,
      smokingStatus: (map['smokingStatus'] ?? '') as String,
      medicalHistory: (map['medicalHistory'] ?? '') as String,
      surgeryType: (map['surgeryType'] ?? '') as String,
      reconstructionMethod: (map['reconstructionMethod'] ?? '') as String,
      affectedRegion: (map['affectedRegion'] ?? '') as String,
      surgeryDate: _ts(map['surgeryDate']),
      facialImageUrl: map['facialImageUrl'] as String?,
      scanImageUrl: map['scanImageUrl'] as String?,
      confidenceScore: (map['confidenceScore'] as num?)?.toDouble() ?? 0,
      reliability: (map['reliability'] ?? 'Medium') as String,
      riskLevel: (map['riskLevel'] ?? 'Low') as String,
      softTissueMetrics:
          Map<String, dynamic>.from(map['softTissueMetrics'] ?? {}),
      aiSummary: (map['aiSummary'] ?? '') as String,
      recoveryEstimate: (map['recoveryEstimate'] ?? '6 Months') as String,
      modelVersion: (map['modelVersion'] ?? 'MaxilloAI-Gemini-v1') as String,
      createdAt: _ts(map['createdAt']) ?? DateTime.now(),
      status: (map['status'] ?? 'completed') as String,
    );
  }
}
