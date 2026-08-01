import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';
import '../predict_draft.dart';

class PatientInfoStep extends StatefulWidget {
  final PredictionDraft draft;
  final VoidCallback onNext;

  const PatientInfoStep({super.key, required this.draft, required this.onNext});

  @override
  State<PatientInfoStep> createState() => _PatientInfoStepState();
}

class _PatientInfoStepState extends State<PatientInfoStep> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.draft.name);
  late final _ageCtrl = TextEditingController(text: widget.draft.age?.toString() ?? '');
  late final _heightCtrl = TextEditingController(text: widget.draft.heightCm?.toString() ?? '');
  late final _weightCtrl = TextEditingController(text: widget.draft.weightKg?.toString() ?? '');
  late final _historyCtrl = TextEditingController(text: widget.draft.medicalHistory);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _historyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.draft
      ..name = _nameCtrl.text.trim()
      ..age = int.tryParse(_ageCtrl.text.trim())
      ..heightCm = double.tryParse(_heightCtrl.text.trim())
      ..weightKg = double.tryParse(_weightCtrl.text.trim())
      ..medicalHistory = _historyCtrl.text.trim();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Patient Information', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            const Text('Tell us about the patient for a personalised prediction.',
                style: TextStyle(color: AppColors.subText, fontSize: 13)),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Name',
              controller: _nameCtrl,
              hint: 'Patient full name',
              prefixIcon: const Icon(Icons.badge_outlined, size: 20),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: AppTextField(
                  label: 'Age',
                  controller: _ageCtrl,
                  hint: '32',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Invalid';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdownField<String>(
                  label: 'Gender',
                  value: widget.draft.gender,
                  items: const ['Female', 'Male', 'Other'],
                  labelBuilder: (v) => v,
                  onChanged: (v) => setState(() => widget.draft.gender = v ?? widget.draft.gender),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: AppTextField(
                  label: 'Height (cm)',
                  controller: _heightCtrl,
                  hint: '170',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => (double.tryParse(v ?? '') == null) ? 'Invalid' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Weight (kg)',
                  controller: _weightCtrl,
                  hint: '68',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => (double.tryParse(v ?? '') == null) ? 'Invalid' : null,
                ),
              ),
            ]),
            const SizedBox(height: 14),
            AppDropdownField<String>(
              label: 'Smoking Status',
              value: widget.draft.smokingStatus,
              items: const ['Non-Smoker', 'Former Smoker', 'Current Smoker'],
              labelBuilder: (v) => v,
              onChanged: (v) => setState(() => widget.draft.smokingStatus = v ?? widget.draft.smokingStatus),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Medical History',
              controller: _historyCtrl,
              hint: 'Relevant conditions, allergies, prior surgeries...',
              maxLines: 4,
            ),
            const SizedBox(height: 28),
            PrimaryButton(label: 'Continue', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
