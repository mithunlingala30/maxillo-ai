import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/primary_button.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _rememberMe = true;
  late final TapGestureRecognizer _switchModeRecognizer;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = 'Female';

  @override
  void initState() {
    super.initState();
    _switchModeRecognizer = TapGestureRecognizer()
      ..onTap = () => setState(() => _isLogin = !_isLogin);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _ageCtrl.dispose();
    _switchModeRecognizer.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await _authService.loginWithEmail(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
      } else {
        await _authService.registerWithEmail(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          age: int.tryParse(_ageCtrl.text.trim()),
          gender: _gender,
        );
      }
      // AuthGate reacts automatically to the auth state change.
    } catch (e) {
      _showError(AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      _showError(AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GradientHeader(
              topPadding: 56,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MaxilloLogo(),
                  const SizedBox(height: 24),
                  Center(
                    child: Icon(Icons.medical_information_outlined,
                        color: Colors.white.withOpacity(0.85), size: 64),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _tabButton('Sign In', _isLogin, () => setState(() => _isLogin = true)),
                    _tabButton('Create Account', !_isLogin, () => setState(() => _isLogin = false)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isLogin ? 'Welcome back' : 'Join MaxilloAI',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      _isLogin
                          ? 'Sign in to access your AI predictions'
                          : 'Start predicting your recovery outcomes',
                      style: const TextStyle(color: AppColors.subText, fontSize: 13.5),
                    ),
                    const SizedBox(height: 20),
                    if (!_isLogin) ...[
                      AppTextField(
                        label: 'Full Name',
                        controller: _nameCtrl,
                        hint: 'e.g. Sarah Johnson',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Age',
                              controller: _ageCtrl,
                              hint: '28',
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.cake_outlined, size: 20),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                final n = int.tryParse(v.trim());
                                if (n == null || n <= 0 || n > 120) return 'Invalid age';
                                return null;
                              },
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
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
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
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Password',
                      controller: _passwordCtrl,
                      hint: '••••••••',
                      obscureText: _obscurePass,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter a password';
                        if (v.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Confirm Password',
                        controller: _confirmCtrl,
                        hint: '••••••••',
                        obscureText: _obscureConfirm,
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        validator: (v) {
                          if (v != _passwordCtrl.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                    if (_isLogin) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                  activeColor: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('Remember me', style: TextStyle(fontSize: 12.5, color: AppColors.subText)),
                            ],
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            ),
                            child: const Text('Forgot password?',
                                style: TextStyle(color: AppColors.primaryBlue, fontSize: 12.5, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ] else
                      const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: _isLogin ? 'Sign In' : 'Create Account',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 18),
                    Row(children: const [
                      Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('or continue with', style: TextStyle(color: AppColors.placeholder, fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: AppColors.border)),
                    ]),
                    const SizedBox(height: 18),
                    SecondaryButton(
                      label: 'Continue with Google',
                      icon: Icons.g_mobiledata,
                      onPressed: _loading ? null : _googleSignIn,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: AppColors.placeholder, fontSize: 12.5),
                          children: [
                            TextSpan(text: _isLogin ? "Don't have an account? " : 'Already have an account? '),
                            TextSpan(
                              text: _isLogin ? 'Sign up' : 'Sign in',
                              style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w700),
                              recognizer: _switchModeRecognizer,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active ? AppShadows.soft : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: active ? AppColors.deepBlue : AppColors.subText,
            ),
          ),
        ),
      ),
    );
  }
}

