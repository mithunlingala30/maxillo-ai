import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/app_user.dart';
import '../../../models/notification_item.dart';
import '../../../models/prediction_record.dart';
import '../../../providers/app_state.dart';
import '../../../services/pdf_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/section_card.dart';
import 'package:maxilloai/screens/home/main_shell.dart';

class ResultStep extends StatefulWidget {
  final AppUser user;
  final PredictionRecord record;
  final VoidCallback onNewPrediction;

  const ResultStep({
    super.key,
    required this.user,
    required this.record,
    required this.onNewPrediction,
  });

  @override
  State<ResultStep> createState() => _ResultStepState();
}

class _ResultStepState extends State<ResultStep> {
  bool _generating = false;

  Future<void> _generateAndShare({bool shareOnly = false}) async {
    setState(() => _generating = true);
    try {
      final pdfBytes = await PdfService().generateReportBytes(user: widget.user, record: widget.record);
      if (!mounted) return;

      // Fire "Report Generated" in-app notification
      context.read<AppState>().addNotification(
        type: NotificationType.reportGenerated,
        title: 'Report Generated',
        body: 'Your PDF medical report for ${widget.record.name} has been generated.',
      );

      if (shareOnly) {
        if (kIsWeb) {
          await Printing.sharePdf(bytes: pdfBytes, filename: 'MaxilloAI_Report.pdf');
        } else {
          final file = await PdfService().generateReport(user: widget.user, record: widget.record);
          if (file != null) {
            await Share.shareXFiles([XFile(file.path)], text: 'MaxilloAI Prediction Report');
          }
        }
      } else {
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: 'MaxilloAI_Report.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate report: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final metrics = record.softTissueMetrics.entries.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              border: Border.all(color: const Color(0xFFBBF7D0)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Analysis Complete',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF14532D))),
                      Text(
                        '${record.confidenceScore.toStringAsFixed(0)}% confidence · ${record.surgeryType}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF166534)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SoftCard(
                  child: Column(
                    children: [
                      const Text('AI Confidence Score', style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
                      const SizedBox(height: 6),
                      Text('${record.confidenceScore.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SoftCard(
                  child: Column(
                    children: [
                      const Text('Reliability', style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
                      const SizedBox(height: 10),
                      Text(record.reliability,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.teal)),
                      const SizedBox(height: 6),
                      RiskBadge(level: record.riskLevel),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Soft Tissue Analysis', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
            children: metrics.map((e) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.softGrey, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_prettyLabel(e.key), style: const TextStyle(fontSize: 11, color: AppColors.subText)),
                    const SizedBox(height: 4),
                    Text('${e.value}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.heading)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Recovery Prediction Timeline', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 10),
          SoftCard(child: _timeline(record)),
          const SizedBox(height: 20),
          SoftCard(
            color: AppColors.blueBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.auto_awesome, size: 16, color: AppColors.primaryBlue),
                  SizedBox(width: 6),
                  Text('AI Insight', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ]),
                const SizedBox(height: 8),
                Text(record.aiSummary, style: const TextStyle(fontSize: 12.5, color: AppColors.darkText, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Generate PDF Report',
            icon: Icons.picture_as_pdf_outlined,
            loading: _generating,
            gradient: AppColors.tealButtonGradient,
            onPressed: () => _generateAndShare(shareOnly: false),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Share With Doctor',
            icon: Icons.ios_share,
            onPressed: _generating ? null : () => _generateAndShare(shareOnly: true),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Track Recovery Plan',
            icon: Icons.favorite_border,
            onPressed: () {
              MainShellController.of(context)?.goTo(3);
            },
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'New Prediction',
            icon: Icons.refresh,
            onPressed: widget.onNewPrediction,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(14)),
            child: const Text(
              'This AI prediction is for informational purposes only and does not '
              'replace professional medical advice.',
              style: TextStyle(fontSize: 11, color: Color(0xFF9A3412)),
            ),
          ),
        ],
      ),
    );
  }

  String _prettyLabel(String key) {
    final spaced = key.replaceAll('_', ' ');
    return spaced.isEmpty ? key : spaced[0].toUpperCase() + spaced.substring(1);
  }

  Widget _timeline(PredictionRecord record) {
    final surgery = record.surgeryType.toLowerCase();
    final est = record.recoveryEstimate;

    List<(String, String)> items;
    if (surgery.contains('jaw') || surgery.contains('orthognathic')) {
      items = [
        ('Day 1-3', 'Peak swelling & acute inflammatory response'),
        ('Week 1-2', 'Early osteotomy healing & splint adjustment'),
        ('Month 1', 'Masticatory muscle adaptation & soft tissue settling'),
        ('Month 3', 'Functional jaw alignment & contour improvement'),
        ('Month 6', 'Consolidated bone stability & final outcome ($est)'),
      ];
    } else if (surgery.contains('cheek') || surgery.contains('zygomat')) {
      items = [
        ('Day 1-3', 'Acute soft tissue edema monitoring'),
        ('Week 1', 'Flap revascularization & suture line stabilization'),
        ('Month 1', 'Zygomatic volume settling & initial contouring'),
        ('Month 3', 'Malar symmetry & nerve sensation recovery'),
        ('Month 6', 'Final cheek contour maturation ($est)'),
      ];
    } else if (surgery.contains('trauma') || surgery.contains('repair')) {
      items = [
        ('Day 1-3', 'Hemostasis & acute wound inflammation control'),
        ('Week 1-2', 'Primary scar tissue matrix formation'),
        ('Month 1', 'Deep dermal collagen remodeling & swelling resolution'),
        ('Month 3', 'Contour smoothing & tissue elasticity recovery'),
        ('Month 6', 'Final scar maturation & complete adaptation ($est)'),
      ];
    } else if (surgery.contains('tumour') || surgery.contains('tumor') || surgery.contains('flap')) {
      items = [
        ('Day 1-5', 'Microvascular perfusion & graft integration monitoring'),
        ('Week 2', 'Initial flap volume settling & wound closure'),
        ('Month 1-2', 'Lymphatic drainage recovery & donor site healing'),
        ('Month 4', 'Neovascularization & progressive soft tissue shaping'),
        ('Month 6-12', 'Long-term tissue integration & final outcome ($est)'),
      ];
    } else {
      items = [
        ('Day 1-3', 'Initial postsurgical swelling & tissue stabilization'),
        ('Week 1-2', 'Soft tissue tension release & suture line recovery'),
        ('Month 1', 'Facial symmetry adaptation & progressive settling'),
        ('Month 3', 'Structural tissue alignment & muscle adaptation'),
        ('Month 6', 'Expected final post-operative outcome ($est)'),
      ];
    }

    return Column(
      children: items
          .map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 72,
                      child: Text(e.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                    ),
                    Expanded(
                      child: Text(e.$2, style: const TextStyle(fontSize: 12.5, color: AppColors.subText)),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
