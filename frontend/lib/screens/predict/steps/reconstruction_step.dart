import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';
import '../predict_draft.dart';

class ReconstructionStep extends StatefulWidget {
  final PredictionDraft draft;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ReconstructionStep({
    super.key,
    required this.draft,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ReconstructionStep> createState() => _ReconstructionStepState();
}

class _ReconstructionStepState extends State<ReconstructionStep> {
  late final _methodCtrl = TextEditingController(text: widget.draft.reconstructionMethod);
  late final _regionCtrl = TextEditingController(text: widget.draft.affectedRegion);
  DateTime? _surgeryDate;

  @override
  void initState() {
    super.initState();
    _surgeryDate = widget.draft.surgeryDate;
  }

  @override
  void dispose() {
    _methodCtrl.dispose();
    _regionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _surgeryDate ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _surgeryDate = picked);
  }

  void _submit() {
    widget.draft
      ..reconstructionMethod = _methodCtrl.text.trim()
      ..affectedRegion = _regionCtrl.text.trim()
      ..surgeryDate = _surgeryDate;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Reconstruction Details', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('Select the surgery type and reconstruction specifics.',
              style: TextStyle(color: AppColors.subText, fontSize: 13)),
          const SizedBox(height: 20),
          const Text('Surgery Type',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: PredictionDraft.surgeryTypes.map((type) {
              final selected = widget.draft.surgeryType == type;
              return GestureDetector(
                onTap: () => setState(() => widget.draft.surgeryType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.blueBg : Colors.white,
                    border: Border.all(color: selected ? AppColors.primaryBlue : AppColors.border, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: selected ? AppColors.primaryBlue : AppColors.subText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Reconstruction Method',
            controller: _methodCtrl,
            hint: 'e.g. Bilateral Sagittal Split Osteotomy',
            prefixIcon: const Icon(Icons.healing_outlined, size: 20),
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Affected Facial Region',
            controller: _regionCtrl,
            hint: 'e.g. Mandible, left cheek, chin',
            prefixIcon: const Icon(Icons.face_outlined, size: 20),
          ),
          const SizedBox(height: 14),
          Text('Surgery Date',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          const SizedBox(height: 6),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.placeholder),
                  const SizedBox(width: 10),
                  Text(
                    _surgeryDate == null
                        ? 'Select surgery date'
                        : '${_surgeryDate!.day}/${_surgeryDate!.month}/${_surgeryDate!.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: _surgeryDate == null ? AppColors.placeholder : AppColors.heading,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(children: [
            Expanded(
              child: OutlinedButton(onPressed: widget.onBack, child: const Text('Back')),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(label: 'Continue', onPressed: _submit),
            ),
          ]),
        ],
      ),
    );
  }
}
