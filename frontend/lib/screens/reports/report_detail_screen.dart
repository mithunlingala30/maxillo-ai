import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../models/prediction_record.dart';
import '../../providers/app_state.dart';
import '../../services/pdf_service.dart';
import '../../theme/app_theme.dart';
import '../predict/steps/result_step.dart';

/// Shows a saved prediction using the same rich result layout as the
/// live flow, plus a full in-app PDF preview (zoom / page nav / print /
/// share) powered by the `printing` package's PdfPreview widget.
class ReportDetailScreen extends StatelessWidget {
  final PredictionRecord record;
  const ReportDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().profile;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(record.surgeryType),
          titleTextStyle: const TextStyle(color: AppColors.heading, fontWeight: FontWeight.w700, fontSize: 16),
          iconTheme: const IconThemeData(color: AppColors.heading),
          bottom: const TabBar(
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.subText,
            indicatorColor: AppColors.primaryBlue,
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'PDF Report'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            user == null
                ? const Center(child: CircularProgressIndicator())
                : ResultStep(user: user, record: record, onNewPrediction: () => Navigator.pop(context)),
            user == null
                ? const Center(child: CircularProgressIndicator())
                : PdfPreview(
                    build: (format) =>
                        PdfService().generateReportBytes(user: user, record: record),
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    allowPrinting: true,
                    allowSharing: true,
                  ),
          ],
        ),
      ),
    );
  }
}
