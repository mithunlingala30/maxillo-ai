import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _authService.sendPasswordResetEmail(_emailCtrl.text.trim());
      setState(() => _sent = true);
    } catch (e) {
      Fluttertoast.showToast(msg: AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Password'),
        titleTextStyle: const TextStyle(color: AppColors.heading, fontWeight: FontWeight.w700, fontSize: 17),
        iconTheme: const IconThemeData(color: AppColors.heading),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _successView() : _formView(),
      ),
    );
  }

  Widget _formView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(color: AppColors.blueBg, shape: BoxShape.circle),
            child: const Icon(Icons.lock_reset, color: AppColors.primaryBlue, size: 34),
          ),
          const SizedBox(height: 20),
          const Text('Forgot your password?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.heading)),
          const SizedBox(height: 8),
          const Text(
            'Enter the email linked to your account and we will send you a link to reset your password.',
            style: TextStyle(color: AppColors.subText, fontSize: 13.5),
          ),
          const SizedBox(height: 24),
          AppTextField(
            label: 'Email Address',
            controller: _emailCtrl,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your email';
              if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Send Reset Link', loading: _loading, onPressed: _submit),
        ],
      ),
    );
  }

  Widget _successView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 40),
        ),
        const SizedBox(height: 20),
        const Text('Check your email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          'We sent a password reset link to ${_emailCtrl.text.trim()}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.subText, fontSize: 13.5),
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Back to Sign In', onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
