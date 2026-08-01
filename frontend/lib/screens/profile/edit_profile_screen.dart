import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  bool _saving = false;
  bool _initialized = false;

  late final _nameCtrl = TextEditingController();
  late final _ageCtrl = TextEditingController();
  late final _heightCtrl = TextEditingController();
  late final _weightCtrl = TextEditingController();
  late final _phoneCtrl = TextEditingController();
  late final _historyCtrl = TextEditingController();
  String _gender = 'Female';
  String _smokingStatus = 'Non-Smoker';
  bool _notifications = true;
  bool _privacySharing = false;

  void _hydrate(BuildContext context) {
    if (_initialized) return;
    final user = context.read<AppState>().profile;
    if (user != null) {
      _nameCtrl.text = user.fullName;
      _ageCtrl.text = user.age?.toString() ?? '';
      _heightCtrl.text = user.heightCm?.toString() ?? '';
      _weightCtrl.text = user.weightKg?.toString() ?? '';
      _phoneCtrl.text = user.phone ?? '';
      _historyCtrl.text = user.medicalHistory ?? '';
      _gender = user.gender ?? 'Female';
      _smokingStatus = user.smokingStatus ?? 'Non-Smoker';
      _notifications = user.notificationsEnabled;
      _privacySharing = user.privacyDataSharing;
    }
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();
    final user = appState.profile;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final updated = user.copyWith(
        fullName: _nameCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text.trim()),
        gender: _gender,
        heightCm: double.tryParse(_heightCtrl.text.trim()),
        weightKg: double.tryParse(_weightCtrl.text.trim()),
        smokingStatus: _smokingStatus,
        medicalHistory: _historyCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        notificationsEnabled: _notifications,
        privacyDataSharing: _privacySharing,
      );
      await _userService.updateUserProfile(updated);
      if (mounted) {
        Fluttertoast.showToast(msg: 'Profile updated');
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not save profile: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _phoneCtrl.dispose();
    _historyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _hydrate(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        titleTextStyle: const TextStyle(color: AppColors.heading, fontWeight: FontWeight.w700, fontSize: 17),
        iconTheme: const IconThemeData(color: AppColors.heading),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Full Name',
                controller: _nameCtrl,
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: AppTextField(
                    label: 'Age',
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'Gender',
                    value: _gender,
                    items: const ['Female', 'Male', 'Other'],
                    labelBuilder: (v) => v,
                    onChanged: (v) => setState(() => _gender = v ?? _gender),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: AppTextField(
                    label: 'Height (cm)',
                    controller: _heightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Weight (kg)',
                    controller: _weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Phone',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              ),
              const SizedBox(height: 14),
              AppDropdownField<String>(
                label: 'Smoking Status',
                value: _smokingStatus,
                items: const ['Non-Smoker', 'Former Smoker', 'Current Smoker'],
                labelBuilder: (v) => v,
                onChanged: (v) => setState(() => _smokingStatus = v ?? _smokingStatus),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Medical History',
                controller: _historyCtrl,
                maxLines: 4,
                hint: 'Conditions, allergies, prior surgeries...',
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
                activeColor: AppColors.primaryBlue,
                title: const Text('Enable Notifications', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                subtitle: const Text('Recovery reminders, report updates', style: TextStyle(fontSize: 11.5)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _privacySharing,
                onChanged: (v) => setState(() => _privacySharing = v),
                activeColor: AppColors.primaryBlue,
                title: const Text('Share Data for Research', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                subtitle: const Text('Optional, anonymised', style: TextStyle(fontSize: 11.5)),
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: 'Save Changes', loading: _saving, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
