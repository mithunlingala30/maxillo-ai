import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/recovery_log.dart';
import '../../providers/app_state.dart';
import '../../services/recovery_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_card.dart';

import '../../models/prediction_record.dart';
import '../../services/prediction_service.dart';

class RecoveryScreen extends StatelessWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AppState>().authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recovery Tracker', style: Theme.of(context).textTheme.headlineMedium),
                  if (uid != null)
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => _showAddLogSheet(context, uid),
                    ),
                ],
              ),
            ),
            Expanded(
              child: uid == null
                  ? const SizedBox.shrink()
                  : StreamBuilder<List<PredictionRecord>>(
                      stream: PredictionService().watchPredictions(uid),
                      builder: (context, predSnapshot) {
                        final predictions = predSnapshot.data ?? [];
                        final latestPrediction = predictions.isNotEmpty ? predictions.first : null;

                        return StreamBuilder<List<RecoveryLog>>(
                          stream: RecoveryService().watchLogs(uid),
                          builder: (context, logSnapshot) {
                            if (!logSnapshot.hasData && !predSnapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final logs = logSnapshot.data ?? [];

                            if (logs.isEmpty && latestPrediction == null) {
                              return _emptyState(context, uid);
                            }

                            return ListView(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                              children: [
                                if (latestPrediction != null) ...[
                                  _aiPredictionCard(latestPrediction),
                                  const SizedBox(height: 16),
                                ],
                                if (logs.isNotEmpty) ...[
                                  SoftCard(child: _chart(logs)),
                                  const SizedBox(height: 16),
                                ],
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Check-in History',
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                    TextButton.icon(
                                      onPressed: () => _showAddLogSheet(context, uid),
                                      icon: const Icon(Icons.add_circle_outline, size: 16),
                                      label: const Text('Add Log', style: TextStyle(fontSize: 12.5)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (logs.isEmpty)
                                  SoftCard(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.history_outlined, color: AppColors.subText, size: 28),
                                          const SizedBox(height: 6),
                                          const Text('No recovery logs recorded yet.',
                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          const Text(
                                              'Track your healing progress by adding check-in updates for pain, swelling & photos.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
                                          const SizedBox(height: 12),
                                          ElevatedButton.icon(
                                            onPressed: () => _showAddLogSheet(context, uid),
                                            icon: const Icon(Icons.add, size: 16),
                                            label: const Text('Add First Check-In'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ...logs.reversed.map((log) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _LogCard(log: log),
                                      )),
                              ],
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiPredictionCard(PredictionRecord record) {
    final surgery = record.surgeryType.toLowerCase();

    List<(String, String)> milestones;
    if (surgery.contains('jaw') || surgery.contains('orthognathic')) {
      milestones = [
        ('Day 1-3', 'Peak swelling & acute inflammatory response'),
        ('Week 1-2', 'Early osteotomy healing & splint adjustment'),
        ('Month 1', 'Masticatory muscle adaptation & soft tissue settling'),
        ('Month 3', 'Functional jaw alignment & contour improvement'),
        ('Month 6', 'Consolidated bone stability & final outcome'),
      ];
    } else if (surgery.contains('cheek') || surgery.contains('zygomat')) {
      milestones = [
        ('Day 1-3', 'Acute soft tissue edema monitoring'),
        ('Week 1', 'Flap revascularization & suture line stabilization'),
        ('Month 1', 'Zygomatic volume settling & initial contouring'),
        ('Month 3', 'Malar symmetry & nerve sensation recovery'),
        ('Month 6', 'Final cheek contour maturation'),
      ];
    } else if (surgery.contains('trauma') || surgery.contains('repair')) {
      milestones = [
        ('Day 1-3', 'Hemostasis & acute wound inflammation control'),
        ('Week 1-2', 'Primary scar tissue matrix formation'),
        ('Month 1', 'Deep dermal collagen remodeling & swelling resolution'),
        ('Month 3', 'Contour smoothing & tissue elasticity recovery'),
        ('Month 6', 'Final scar maturation & complete adaptation'),
      ];
    } else if (surgery.contains('tumour') || surgery.contains('tumor') || surgery.contains('flap')) {
      milestones = [
        ('Day 1-5', 'Microvascular perfusion & graft integration monitoring'),
        ('Week 2', 'Initial flap volume settling & wound closure'),
        ('Month 1-2', 'Lymphatic drainage recovery & donor site healing'),
        ('Month 4', 'Neovascularization & progressive soft tissue shaping'),
        ('Month 6-12', 'Long-term tissue integration & final outcome'),
      ];
    } else {
      milestones = [
        ('Day 1-3', 'Initial postsurgical swelling & tissue stabilization'),
        ('Week 1-2', 'Soft tissue tension release & suture line recovery'),
        ('Month 1', 'Facial symmetry adaptation & progressive settling'),
        ('Month 3', 'Structural tissue alignment & muscle adaptation'),
        ('Month 6', 'Expected final post-operative outcome'),
      ];
    }

    return SoftCard(
      color: const Color(0xFFF0FDF4),
      border: Border.all(color: const Color(0xFFBBF7D0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${record.surgeryType} Prediction Plan',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF14532D))),
                    Text(
                      'Target: ${record.recoveryEstimate} · ${record.confidenceScore.toStringAsFixed(0)}% AI Confidence',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF166534)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Text(
                  '${record.riskLevel} Risk',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('AI Recovery Roadmap', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF14532D))),
          const SizedBox(height: 8),
          ...milestones.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isCompleted = idx == 0; // First milestone active by default
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: isCompleted ? AppColors.teal : AppColors.placeholder,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: Text(item.$1,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: isCompleted ? AppColors.heading : AppColors.subText)),
                  ),
                  Expanded(
                    child: Text(item.$2,
                        style: TextStyle(
                            fontSize: 12,
                            color: isCompleted ? AppColors.heading : AppColors.subText)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, String uid) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.tealBg, shape: BoxShape.circle),
              child: const Icon(Icons.favorite_border, color: AppColors.teal, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Start tracking your recovery', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 6),
            const Text(
              'Log pain, swelling and progress photos at each milestone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.subText, fontSize: 12.5),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Add Check-In', onPressed: () => _showAddLogSheet(context, uid)),
          ],
        ),
      ),
    );
  }

  Widget _chart(List<RecoveryLog> logs) {
    final spots = logs
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.recoveryPercent.toDouble()))
        .toList();
    final swellingSpots = logs
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.swellingLevel.toDouble() * 10))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Healing Progress', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.teal,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: AppColors.tealBg),
                ),
                LineChartBarData(
                  spots: swellingSpots,
                  isCurved: true,
                  color: AppColors.warning,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  dashArray: [6, 4],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          _legendDot(AppColors.teal, 'Recovery %'),
          const SizedBox(width: 16),
          _legendDot(AppColors.warning, 'Swelling (x10)'),
        ]),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.subText)),
    ]);
  }

  void _showAddLogSheet(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _AddLogSheet(uid: uid),
    );
  }
}

class _LogCard extends StatelessWidget {
  final RecoveryLog log;
  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          if (log.photoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(log.photoUrl!, width: 48, height: 48, fit: BoxFit.cover),
            )
          else
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: AppColors.tealBg, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.favorite, color: AppColors.teal),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.milestone, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text('Pain ${log.painLevel}/10 · Swelling ${log.swellingLevel}/10',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.subText)),
              ],
            ),
          ),
          Text('${log.recoveryPercent}%',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.teal, fontSize: 15)),
        ],
      ),
    );
  }
}

class _AddLogSheet extends StatefulWidget {
  final String uid;
  const _AddLogSheet({required this.uid});

  @override
  State<_AddLogSheet> createState() => _AddLogSheetState();
}

class _AddLogSheetState extends State<_AddLogSheet> {
  String _milestone = 'Post-Op Day';
  double _pain = 3;
  double _swelling = 4;
  double _recovery = 30;
  Uint8List? _photo;
  bool _saving = false;

  static const _milestones = ['Post-Op Day', 'Week 1', 'Month 1', 'Month 3', 'Month 6'];

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _photo = bytes);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      String? photoUrl;
      if (_photo != null) {
        photoUrl = await StorageService().uploadFile(uid: widget.uid, file: _photo!, folder: 'recovery');
      }
      final service = RecoveryService();
      await service.addLog(RecoveryLog(
        id: service.newId(),
        uid: widget.uid,
        milestone: _milestone,
        painLevel: _pain.round(),
        swellingLevel: _swelling.round(),
        recoveryPercent: _recovery.round(),
        photoUrl: photoUrl,
      ));
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Add Recovery Check-In', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Milestone', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _milestones.map((m) {
                final active = _milestone == m;
                return ChoiceChip(
                  label: Text(m),
                  selected: active,
                  onSelected: (_) => setState(() => _milestone = m),
                  selectedColor: AppColors.blueBg,
                  labelStyle: TextStyle(
                      color: active ? AppColors.primaryBlue : AppColors.subText, fontSize: 12),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _sliderRow('Pain Level', _pain, (v) => setState(() => _pain = v)),
            _sliderRow('Swelling Level', _swelling, (v) => setState(() => _swelling = v)),
            const SizedBox(height: 8),
            const Text('Recovery Percent', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            Slider(
              value: _recovery,
              min: 0,
              max: 100,
              divisions: 20,
              label: '${_recovery.round()}%',
              activeColor: AppColors.teal,
              onChanged: (v) => setState(() => _recovery = v),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
              label: Text(_photo == null ? 'Add Progress Photo' : 'Photo Selected'),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Save Check-In', loading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }

  Widget _sliderRow(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.round()}/10', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: AppColors.primaryBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
