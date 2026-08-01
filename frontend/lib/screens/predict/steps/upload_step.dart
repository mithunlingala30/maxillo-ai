import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/primary_button.dart';
import '../predict_draft.dart';

class UploadStep extends StatefulWidget {
  final PredictionDraft draft;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const UploadStep({super.key, required this.draft, required this.onNext, required this.onBack});

  @override
  State<UploadStep> createState() => _UploadStepState();
}

class _UploadStepState extends State<UploadStep> {
  final _picker = ImagePicker();

  bool get _canAnalyze => widget.draft.facialImage != null || widget.draft.scanImage != null;

  Future<void> _pick(bool isFacial) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take Photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;
    final xFile = await _picker.pickImage(source: source, imageQuality: 85);
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    setState(() {
      if (isFacial) {
        widget.draft.facialImage = bytes;
      } else {
        widget.draft.scanImage = bytes;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Upload Patient Images', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('Facial photograph, CT scan, MRI, or X-ray. At least one is required.',
              style: TextStyle(color: AppColors.subText, fontSize: 13)),
          const SizedBox(height: 20),
          _UploadZone(
            label: 'Facial Photograph',
            sublabel: 'Front-facing, neutral expression',
            icon: Icons.face_retouching_natural,
            accent: AppColors.primaryBlue,
            bg: AppColors.blueBg,
            bytes: widget.draft.facialImage,
            onTap: () => _pick(true),
            onClear: () => setState(() => widget.draft.facialImage = null),
          ),
          const SizedBox(height: 14),
          _UploadZone(
            label: 'Medical Scan',
            sublabel: 'DICOM, CBCT, CT, MRI or X-Ray export',
            icon: Icons.biotech_outlined,
            accent: AppColors.teal,
            bg: AppColors.tealBg,
            bytes: widget.draft.scanImage,
            onTap: () => _pick(false),
            onClear: () => setState(() => widget.draft.scanImage = null),
          ),
          const SizedBox(height: 28),
          Row(children: [
            Expanded(
              child: OutlinedButton(onPressed: widget.onBack, child: const Text('Back')),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                label: _canAnalyze ? 'Run AI Analysis' : 'Upload at least one image',
                onPressed: _canAnalyze ? widget.onNext : null,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _UploadZone extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color accent;
  final Color bg;
  final Uint8List? bytes;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _UploadZone({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.accent,
    required this.bg,
    required this.bytes,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final uploaded = bytes != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: uploaded ? bg : Colors.white,
          border: Border.all(
            color: uploaded ? accent : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            if (uploaded)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(bytes!, width: 52, height: 52, fit: BoxFit.cover),
              )
            else
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: accent, size: 24),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  Text(sublabel, style: const TextStyle(fontSize: 11.5, color: AppColors.placeholder)),
                  if (uploaded)
                    Text('Uploaded successfully',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: accent)),
                ],
              ),
            ),
            if (uploaded)
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.subText),
                onPressed: onClear,
              )
            else
              Icon(Icons.add_circle_outline, color: accent),
          ],
        ),
      ),
    );
  }
}
