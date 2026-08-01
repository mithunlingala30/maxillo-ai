import 'dart:typed_data';

/// Mutable, in-memory holder for everything collected across the 5-step
/// prediction flow (Patient Details -> Reconstruction -> Images ->
/// Analysis -> Results) before it is sent to the AI backend and saved.
class PredictionDraft {
  // Step 1 - Patient Information
  String name;
  int? age;
  String gender;
  double? heightCm;
  double? weightKg;
  String smokingStatus;
  String medicalHistory;

  // Step 2 - Reconstruction Details
  String surgeryType;
  String reconstructionMethod;
  String affectedRegion;
  DateTime? surgeryDate;

  // Step 3 - Images (stored as bytes for cross-platform / web compatibility)
  Uint8List? facialImage;
  Uint8List? scanImage;

  PredictionDraft({
    this.name = '',
    this.age,
    this.gender = 'Female',
    this.heightCm,
    this.weightKg,
    this.smokingStatus = 'Non-Smoker',
    this.medicalHistory = '',
    this.surgeryType = 'Jaw Reconstruction',
    this.reconstructionMethod = '',
    this.affectedRegion = '',
    this.surgeryDate,
    this.facialImage,
    this.scanImage,
  });

  static const surgeryTypes = [
    'Jaw Reconstruction',
    'Cheek Reconstruction',
    'Facial Trauma',
    'Tumour Reconstruction',
    'Congenital Facial Defect',
  ];

  Map<String, dynamic> toPatientInfoMap() => {
        'name': name,
        'age': age,
        'gender': gender,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'smoking_status': smokingStatus,
        'medical_history': medicalHistory,
      };

  Map<String, dynamic> toReconstructionMap() => {
        'surgery_type': surgeryType,
        'reconstruction_method': reconstructionMethod,
        'affected_region': affectedRegion,
        'surgery_date': surgeryDate?.toIso8601String(),
      };
}
