import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/app_user.dart';
import '../models/prediction_record.dart';

/// Builds a professional, hospital-quality PDF for a saved prediction,
/// following the structure from the design spec: cover page, patient
/// info, AI prediction summary, facial analysis, soft tissue outcome
/// analysis, recovery timeline, AI recommendations, and a verification
/// footer with report ID / timestamp.
class PdfService {
  static const PdfColor blue = PdfColor.fromInt(0xFF2563EB);
  static const PdfColor teal = PdfColor.fromInt(0xFF14B8A6);
  static const PdfColor navy = PdfColor.fromInt(0xFF0F172A);
  static const PdfColor grey = PdfColor.fromInt(0xFF64748B);
  static const PdfColor lightGrey = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor border = PdfColor.fromInt(0xFFE2E8F0);
  static const PdfColor green = PdfColor.fromInt(0xFF16A34A);

  /// Generates the raw PDF bytes (Web & Native compatible)
  Future<Uint8List> generateReportBytes({
    required AppUser user,
    required PredictionRecord record,
  }) async {
    final doc = pw.Document();
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
    final reportId = 'MXA-${record.id.substring(0, 8).toUpperCase()}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => _header(),
        footer: (context) => _footer(context, reportId),
        build: (context) => [
          _coverSection(user, record, reportId, dateFmt),
          pw.SizedBox(height: 18),
          _sectionTitle('Patient Information'),
          _patientInfoTable(user, record),
          pw.SizedBox(height: 18),
          _sectionTitle('AI Prediction Summary'),
          _predictionSummaryRow(record),
          pw.SizedBox(height: 18),
          _sectionTitle('Soft Tissue Outcome Analysis'),
          _metricsGrid(record),
          pw.SizedBox(height: 10),
          _aiInsightBox(record),
          pw.SizedBox(height: 18),
          _sectionTitle('Recovery Timeline'),
          _recoveryTimeline(record),
          pw.SizedBox(height: 18),
          _sectionTitle('AI Recommendations'),
          _recommendations(record),
          pw.SizedBox(height: 18),
          _sectionTitle('Doctor Review'),
          _doctorReviewBox(),
          pw.SizedBox(height: 18),
          _disclaimer(),
        ],
      ),
    );

    return await doc.save();
  }

  /// Generates a local PDF file on native platforms (Android/iOS/Desktop).
  /// Returns null on Flutter Web.
  Future<File?> generateReport({
    required AppUser user,
    required PredictionRecord record,
  }) async {
    final bytes = await generateReportBytes(user: user, record: record);
    if (kIsWeb) return null;

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/MaxilloAI_Report_${record.id.substring(0, 8)}.pdf',
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  pw.Widget _header() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: border, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(children: [
            pw.Container(
              width: 20,
              height: 20,
              decoration: pw.BoxDecoration(
                color: blue,
                borderRadius: pw.BorderRadius.circular(5),
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Text('MaxilloAI',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          ]),
          pw.Text('AI-Based Soft Tissue Outcome Prediction Report',
              style: const pw.TextStyle(fontSize: 9, color: grey)),
        ],
      ),
    );
  }

  pw.Widget _footer(pw.Context context, String reportId) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: border, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Report ID: $reportId  ·  Secure AI-Generated Document',
              style: const pw.TextStyle(fontSize: 8, color: grey)),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: grey)),
        ],
      ),
    );
  }

  pw.Widget _coverSection(AppUser user, PredictionRecord record,
      String reportId, DateFormat dateFmt) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: navy,
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('AI-Based Soft Tissue',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text('Outcome Prediction Report',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Patient: ${user.fullName}',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                pw.Text('Report ID: $reportId',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                pw.Text('Generated: ${dateFmt.format(record.createdAt)}',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                pw.Text('AI Model Version: ${record.modelVersion}',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: 'MAXILLOAI-REPORT-$reportId',
              width: 60,
              height: 60,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionTitle(String title) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(title,
            style: pw.TextStyle(
                fontSize: 13, fontWeight: pw.FontWeight.bold, color: navy)),
      );

  pw.Widget _patientInfoTable(AppUser user, PredictionRecord record) {
    final rows = <List<String>>[
      ['Patient Name', record.name],
      ['Age', '${record.age}'],
      ['Gender', record.gender],
      ['Email', user.email],
      ['Surgery Type', record.surgeryType],
      ['Reconstruction Area', record.affectedRegion],
      ['Reconstruction Method', record.reconstructionMethod],
      [
        'Surgery Date',
        record.surgeryDate != null
            ? DateFormat('dd MMM yyyy').format(record.surgeryDate!)
            : 'Not specified'
      ],
    ];
    return pw.Table(
      border: pw.TableBorder.all(color: border, width: 0.6),
      columnWidths: {0: const pw.FlexColumnWidth(1.2), 1: const pw.FlexColumnWidth(2)},
      children: rows
          .map((r) => pw.TableRow(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(r[0],
                      style: pw.TextStyle(fontSize: 9, color: grey, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(r[1], style: const pw.TextStyle(fontSize: 9, color: navy)),
                ),
              ]))
          .toList(),
    );
  }

  pw.Widget _predictionSummaryRow(PredictionRecord record) {
    pw.Widget card(String label, String value, PdfColor color) => pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 4),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: lightGrey,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: grey)),
                pw.SizedBox(height: 4),
                pw.Text(value,
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
              ],
            ),
          ),
        );

    return pw.Row(children: [
      card('Confidence Score', '${record.confidenceScore.toStringAsFixed(0)}%', blue),
      card('Recovery Prediction', record.riskLevel == 'Low' ? 'Positive' : record.riskLevel, green),
      card('Estimated Recovery', record.recoveryEstimate, teal),
    ]);
  }

  pw.Widget _metricsGrid(PredictionRecord record) {
    final entries = record.softTissueMetrics.entries.toList();
    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entries.map((e) {
        return pw.Container(
          width: 150,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: lightGrey,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(_prettyLabel(e.key), style: const pw.TextStyle(fontSize: 8, color: grey)),
              pw.SizedBox(height: 2),
              pw.Text('${e.value}',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: navy)),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _prettyLabel(String key) {
    final spaced = key.replaceAll('_', ' ');
    if (spaced.isEmpty) return spaced;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  pw.Widget _aiInsightBox(PredictionRecord record) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFEFF6FF),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFDBEAFE)),
      ),
      child: pw.Text(record.aiSummary, style: const pw.TextStyle(fontSize: 9, color: navy)),
    );
  }

  pw.Widget _recoveryTimeline(PredictionRecord record) {
    final surgery = record.surgeryType.toLowerCase();
    final est = record.recoveryEstimate;

    List<List<String>> steps;
    if (surgery.contains('jaw') || surgery.contains('orthognathic')) {
      steps = [
        ['Day 1-3', 'Peak swelling & acute inflammatory response'],
        ['Week 1-2', 'Early osteotomy healing & splint adjustment'],
        ['Month 1', 'Masticatory muscle adaptation & soft tissue settling'],
        ['Month 3', 'Functional jaw alignment & contour improvement'],
        ['Month 6', 'Consolidated bone stability & final outcome ($est)'],
      ];
    } else if (surgery.contains('cheek') || surgery.contains('zygomat')) {
      steps = [
        ['Day 1-3', 'Acute soft tissue edema monitoring'],
        ['Week 1', 'Flap revascularization & suture line stabilization'],
        ['Month 1', 'Zygomatic volume settling & initial contouring'],
        ['Month 3', 'Malar symmetry & nerve sensation recovery'],
        ['Month 6', 'Final cheek contour maturation ($est)'],
      ];
    } else if (surgery.contains('trauma') || surgery.contains('repair')) {
      steps = [
        ['Day 1-3', 'Hemostasis & acute wound inflammation control'],
        ['Week 1-2', 'Primary scar tissue matrix formation'],
        ['Month 1', 'Deep dermal collagen remodeling & swelling resolution'],
        ['Month 3', 'Contour smoothing & tissue elasticity recovery'],
        ['Month 6', 'Final scar maturation & complete adaptation ($est)'],
      ];
    } else if (surgery.contains('tumour') || surgery.contains('tumor') || surgery.contains('flap')) {
      steps = [
        ['Day 1-5', 'Microvascular perfusion & graft integration monitoring'],
        ['Week 2', 'Initial flap volume settling & wound closure'],
        ['Month 1-2', 'Lymphatic drainage recovery & donor site healing'],
        ['Month 4', 'Neovascularization & progressive soft tissue shaping'],
        ['Month 6-12', 'Long-term tissue integration & final outcome ($est)'],
      ];
    } else {
      steps = [
        ['Day 1-3', 'Initial postsurgical swelling & tissue stabilization'],
        ['Week 1-2', 'Soft tissue tension release & suture line recovery'],
        ['Month 1', 'Facial symmetry adaptation & progressive settling'],
        ['Month 3', 'Structural tissue alignment & muscle adaptation'],
        ['Month 6', 'Expected final post-operative outcome ($est)'],
      ];
    }

    return pw.Column(
      children: steps
          .map((s) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(children: [
                  pw.Container(
                    width: 8,
                    height: 8,
                    decoration: const pw.BoxDecoration(color: teal, shape: pw.BoxShape.circle),
                  ),
                  pw.SizedBox(width: 8),
                  pw.SizedBox(
                      width: 65,
                      child: pw.Text(s[0],
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: navy))),
                  pw.Expanded(
                      child: pw.Text(s[1], style: const pw.TextStyle(fontSize: 9, color: grey))),
                ]),
              ))
          .toList(),
    );
  }

  pw.Widget _recommendations(PredictionRecord record) {
    final items = [
      'Follow prescribed medication and wound-care instructions closely.',
      'Attend all scheduled post-operative follow-up appointments.',
      'Avoid strenuous activity and direct facial pressure for the first 2 weeks.',
      'Maintain a soft diet and good oral hygiene during early recovery.',
      'Contact your surgical team immediately if you notice unusual swelling, fever, or pain.',
    ];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items
          .map((t) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('•  ', style: const pw.TextStyle(color: teal, fontSize: 9)),
                    pw.Expanded(child: pw.Text(t, style: const pw.TextStyle(fontSize: 9, color: navy))),
                  ],
                ),
              ))
          .toList(),
    );
  }

  pw.Widget _doctorReviewBox() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: border),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Doctor Notes: ______________________________________________',
              style: const pw.TextStyle(fontSize: 9, color: grey)),
          pw.SizedBox(height: 14),
          pw.Text('Specialist Comments: ________________________________________',
              style: const pw.TextStyle(fontSize: 9, color: grey)),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Digital Signature: ____________________',
                  style: const pw.TextStyle(fontSize: 9, color: grey)),
              pw.Text('Hospital Stamp', style: const pw.TextStyle(fontSize: 9, color: grey)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _disclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFFF7ED),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Text(
        'This AI prediction is for informational purposes only and does not '
        'replace professional medical advice. Please consult your surgeon or '
        'physician for a clinical diagnosis and treatment plan.',
        style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF9A3412)),
      ),
    );
  }
}
