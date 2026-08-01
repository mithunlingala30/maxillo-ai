import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_item.dart';
import '../../models/prediction_record.dart';
import '../../providers/app_state.dart';
import '../../services/prediction_api_service.dart';
import '../../services/prediction_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import 'predict_draft.dart';
import 'steps/analyzing_step.dart';
import 'steps/patient_info_step.dart';
import 'steps/reconstruction_step.dart';
import 'steps/result_step.dart';
import 'steps/upload_step.dart';

enum _FlowStep { patient, reconstruction, upload, analyzing, result }

class PredictFlowScreen extends StatefulWidget {
  const PredictFlowScreen({super.key});

  @override
  State<PredictFlowScreen> createState() => _PredictFlowScreenState();
}

class _PredictFlowScreenState extends State<PredictFlowScreen> {
  _FlowStep _step = _FlowStep.patient;
  PredictionDraft _draft = PredictionDraft();
  double _progress = 0;
  String? _error;
  PredictionRecord? _result;

  static const _stepOrder = [
    _FlowStep.patient,
    _FlowStep.reconstruction,
    _FlowStep.upload,
    _FlowStep.analyzing,
    _FlowStep.result,
  ];

  void _goTo(_FlowStep step) => setState(() => _step = step);

  void _resetFlow() {
    setState(() {
      _draft = PredictionDraft();
      _result = null;
      _error = null;
      _progress = 0;
      _step = _FlowStep.patient;
    });
  }

  Future<void> _runAnalysis() async {
    setState(() {
      _step = _FlowStep.analyzing;
      _error = null;
      _progress = 0.05;
    });

    final appState = context.read<AppState>();
    final uid = appState.authService.currentUser?.uid;
    final user = appState.profile;

    if (uid == null || user == null) {
      setState(() => _error = 'You must be signed in to run a prediction.');
      return;
    }

    try {
      // Kick off image uploads (for record keeping) and the AI call
      // together; nudge the progress bar while we wait.
      setState(() => _progress = 0.2);

      final storage = StorageService();
      final uploadFutures = <Future<String?>>[
        if (_draft.facialImage != null)
          storage
              .uploadFile(uid: uid, file: _draft.facialImage!, folder: 'predictions')
              .catchError((_) => null)
        else
          Future.value(null),
        if (_draft.scanImage != null)
          storage
              .uploadFile(uid: uid, file: _draft.scanImage!, folder: 'predictions')
              .catchError((_) => null)
        else
          Future.value(null),
      ];

      setState(() => _progress = 0.45);

      final apiService = PredictionApiService();
      final apiResultFuture = apiService.predict(
        patientInfo: _draft.toPatientInfoMap(),
        reconstructionDetails: _draft.toReconstructionMap(),
        facialImage: _draft.facialImage,
        scanImage: _draft.scanImage,
      );

      // Increment progress smoothly while waiting for response
      final progressTimer = Stream.periodic(const Duration(milliseconds: 600)).listen((_) {
        if (mounted && _progress < 0.80) {
          setState(() => _progress = (_progress + 0.05).clamp(0.0, 0.80));
        }
      });

      final results = await Future.wait([
        apiResultFuture,
        Future.wait(uploadFutures),
      ]).timeout(const Duration(seconds: 6), onTimeout: () async {
        print('Analysis timed out; proceeding with AI prediction result.');
        final fallbackResult = await apiService.predict(
          patientInfo: _draft.toPatientInfoMap(),
          reconstructionDetails: _draft.toReconstructionMap(),
          facialImage: _draft.facialImage,
          scanImage: _draft.scanImage,
        );
        return [fallbackResult, [null, null]];
      }).whenComplete(() => progressTimer.cancel());

      setState(() => _progress = 0.85);

      final apiResult = results[0] as Map<String, dynamic>;
      final urls = results[1] as List<String?>;

      final predictionService = PredictionService();
      final record = PredictionRecord(
        id: predictionService.newId(),
        uid: uid,
        name: _draft.name.isEmpty ? user.fullName : _draft.name,
        age: _draft.age ?? user.age ?? 0,
        gender: _draft.gender,
        heightCm: _draft.heightCm ?? user.heightCm ?? 0,
        weightKg: _draft.weightKg ?? user.weightKg ?? 0,
        smokingStatus: _draft.smokingStatus,
        medicalHistory: _draft.medicalHistory,
        surgeryType: _draft.surgeryType,
        reconstructionMethod: _draft.reconstructionMethod,
        affectedRegion: _draft.affectedRegion,
        surgeryDate: _draft.surgeryDate,
        facialImageUrl: urls[0],
        scanImageUrl: urls[1],
        confidenceScore: (apiResult['confidenceScore'] as num).toDouble(),
        reliability: apiResult['reliability'] as String,
        riskLevel: apiResult['riskLevel'] as String,
        softTissueMetrics: Map<String, dynamic>.from(apiResult['softTissueMetrics'] as Map),
        aiSummary: apiResult['aiSummary'] as String,
        recoveryEstimate: apiResult['recoveryEstimate'] as String,
        modelVersion: apiResult['modelVersion'] as String,
      );

      await predictionService.savePrediction(record);

      // ── Fire in-app notification ──
      if (mounted) {
        context.read<AppState>().addNotification(
          type: NotificationType.predictionComplete,
          title: 'Prediction Completed',
          body: 'Your AI soft tissue prediction for ${record.name} is ready to view.',
        );
      }

      setState(() {
        _progress = 1;
        _result = record;
      });

      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) setState(() => _step = _FlowStep.result);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is PredictionApiException
            ? e.message
            : 'Something went wrong while analysing your images. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final stepIndex = _stepOrder.indexOf(_step);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(stepIndex: stepIndex),
            Expanded(child: _buildStep(appState)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(AppState appState) {
    switch (_step) {
      case _FlowStep.patient:
        return PatientInfoStep(draft: _draft, onNext: () => _goTo(_FlowStep.reconstruction));
      case _FlowStep.reconstruction:
        return ReconstructionStep(
          draft: _draft,
          onNext: () => _goTo(_FlowStep.upload),
          onBack: () => _goTo(_FlowStep.patient),
        );
      case _FlowStep.upload:
        return UploadStep(
          draft: _draft,
          onNext: _runAnalysis,
          onBack: () => _goTo(_FlowStep.reconstruction),
        );
      case _FlowStep.analyzing:
        return AnalyzingStep(
          progress: _progress,
          errorMessage: _error,
          onRetry: _runAnalysis,
        );
      case _FlowStep.result:
        if (_result == null || appState.profile == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ResultStep(
          user: appState.profile!,
          record: _result!,
          onNewPrediction: _resetFlow,
        );
    }
  }
}

class _Header extends StatelessWidget {
  final int stepIndex;
  const _Header({required this.stepIndex});

  static const _labels = ['Patient', 'Surgery', 'Upload', 'Analyse', 'Results'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI Prediction',
              style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('Step ${stepIndex + 1} of ${_labels.length} — ${_labels[stepIndex]}',
              style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
          const SizedBox(height: 14),
          Row(
            children: List.generate(_labels.length, (i) {
              final active = i <= stepIndex;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i == _labels.length - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
