import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/prediction_record.dart';
import '../../providers/app_state.dart';
import '../../services/prediction_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _query = '';
  String _statusFilter = 'All';

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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Reports', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  const Text('History of all your AI predictions and PDF reports',
                      style: TextStyle(color: AppColors.subText, fontSize: 12.5)),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search by surgery type...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['All', 'Low', 'Medium', 'High'].map((f) {
                        final active = _statusFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: active,
                            onSelected: (_) => setState(() => _statusFilter = f),
                            selectedColor: AppColors.blueBg,
                            labelStyle: TextStyle(
                              color: active ? AppColors.primaryBlue : AppColors.subText,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: active ? AppColors.primaryBlue : AppColors.border),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: uid == null
                  ? const SizedBox.shrink()
                  : StreamBuilder<List<PredictionRecord>>(
                      stream: PredictionService().watchPredictions(uid),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        var records = snapshot.data!;
                        if (_query.isNotEmpty) {
                          records = records
                              .where((r) => r.surgeryType.toLowerCase().contains(_query.toLowerCase()))
                              .toList();
                        }
                        if (_statusFilter != 'All') {
                          records = records.where((r) => r.riskLevel == _statusFilter).toList();
                        }
                        if (records.isEmpty) {
                          return _emptyState();
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          itemCount: records.length,
                          itemBuilder: (context, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ReportCard(record: records[i]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.blueBg, shape: BoxShape.circle),
              child: const Icon(Icons.description_outlined, color: AppColors.primaryBlue, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('No reports yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 6),
            const Text(
              'Run your first AI prediction to generate a report here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.subText, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final PredictionRecord record;
  const _ReportCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');
    return SoftCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ReportDetailScreen(record: record)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: AppColors.tealBg, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.insert_drive_file_outlined, color: AppColors.teal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.surgeryType,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text('${dateFmt.format(record.createdAt)} · ${record.confidenceScore.toStringAsFixed(0)}% confidence',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.subText)),
              ],
            ),
          ),
          RiskBadge(level: record.riskLevel),
        ],
      ),
    );
  }
}
