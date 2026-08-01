import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/prediction_record.dart';
import '../../providers/app_state.dart';
import '../../services/auth_service.dart';
import '../../services/prediction_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';
import '../notifications/notifications_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.profile;
    final uid = appState.authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.blueBg,
                        backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                        child: user?.photoUrl == null
                            ? const Icon(Icons.person, color: AppColors.primaryBlue, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.fullName ?? '—',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(user?.email ?? '', style: const TextStyle(color: AppColors.subText, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (uid != null)
                    StreamBuilder<List<PredictionRecord>>(
                      stream: PredictionService().watchPredictions(uid),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return Row(
                          children: [
                            Expanded(child: _stat('Predictions', '$count', AppColors.blueBg, AppColors.primaryBlue)),
                            const SizedBox(width: 10),
                            Expanded(child: _stat('Reports', '$count', AppColors.tealBg, AppColors.teal)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _stat('Age', user?.age != null ? '${user!.age}' : '—', AppColors.purpleBg, AppColors.purple),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _menuSection(context, 'Account', [
              _MenuItem(Icons.person_outline, 'Personal Information', 'Name, email, contact',
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
              _MenuItem(Icons.medical_information_outlined, 'Medical History', 'Conditions, allergies',
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
              _MenuItem(Icons.notifications_none_rounded, 'Notifications', 'Alerts & reminders',
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
            ]),
            const SizedBox(height: 16),
            _menuSection(context, 'About', [
              _MenuItem(Icons.description_outlined, 'Terms of Service', 'Usage agreement',
                  () => _showTermsOfService(context)),
              _MenuItem(Icons.shield_outlined, 'Privacy Policy', 'How we protect your data',
                  () => _showPrivacyPolicy(context)),
              _MenuItem(Icons.info_outline, 'About MaxilloAI', 'App version 1.0.0',
                  () => _showAboutApp(context)),
            ]),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout, color: AppColors.risk),
              label: const Text('Log Out', style: TextStyle(color: AppColors.risk, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFECACA))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.subText)),
        ],
      ),
    );
  }

  Widget _menuSection(BuildContext context, String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title.toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.placeholder, letterSpacing: 0.5)),
        ),
        SoftCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap,
                    leading: Icon(item.icon, color: item.danger ? AppColors.risk : AppColors.subText, size: 22),
                    title: Text(item.label,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: item.danger ? AppColors.risk : AppColors.heading)),
                    subtitle: item.sub.isEmpty ? null : Text(item.sub, style: const TextStyle(fontSize: 11.5)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.placeholder, size: 20),
                  ),
                  if (i != items.length - 1) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── About section handlers ────────────────────────────────────────────────

  void _showTermsOfService(BuildContext context) {
    _showInfoSheet(
      context,
      icon: Icons.description_outlined,
      iconColor: AppColors.primaryBlue,
      title: 'Terms of Service',
      sections: [
        _InfoSection('Acceptance of Terms',
            'By using MaxilloAI, you agree to these terms. MaxilloAI is intended for use by qualified maxillofacial surgeons and medical professionals to assist in planning soft tissue outcome predictions.'),
        _InfoSection('Medical Disclaimer',
            'MaxilloAI provides AI-assisted predictions for informational and planning purposes only. All outputs must be reviewed and validated by a licensed medical professional. This app does not constitute medical advice and should never replace clinical judgment.'),
        _InfoSection('Permitted Use',
            'You may use MaxilloAI solely for lawful medical or research purposes. Unauthorized commercial use, redistribution, or reverse engineering of the AI model is strictly prohibited.'),
        _InfoSection('Intellectual Property',
            'All content, models, algorithms, and interfaces within MaxilloAI are the intellectual property of the MaxilloAI development team. Reproduction without written consent is not allowed.'),
        _InfoSection('Limitation of Liability',
            'MaxilloAI and its developers are not liable for any clinical decisions made based on predictions generated by the app. Use of this tool is at the professional\'s own discretion and responsibility.'),
        _InfoSection('Updates & Changes',
            'These terms may be updated periodically. Continued use of the app after updates constitutes acceptance of the revised terms.'),
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    _showInfoSheet(
      context,
      icon: Icons.shield_outlined,
      iconColor: AppColors.teal,
      title: 'Privacy Policy',
      sections: [
        _InfoSection('Data We Collect',
            'MaxilloAI collects your name, email, professional profile, and prediction data (including patient details and uploaded medical images) to provide the AI prediction service.'),
        _InfoSection('How We Use Your Data',
            'Your data is used solely to generate soft tissue outcome predictions, store prediction history, and improve the AI model\'s accuracy. We do not sell or share your data with third parties.'),
        _InfoSection('Medical Image Security',
            'All uploaded images are encrypted in transit (TLS 1.3) and at rest (AES-256). Images are stored in Firebase Storage under your unique user ID and are accessible only to you.'),
        _InfoSection('AI Processing',
            'Patient data and images are processed by our Gemini-powered AI backend. Processing occurs on secured cloud servers. Raw images are not retained after prediction generation.'),
        _InfoSection('Data Retention',
            'Your prediction records are retained in Firestore as long as your account is active. You can delete your account and all associated data at any time from the app settings.'),
        _InfoSection('Your Rights',
            'You have the right to access, correct, or delete your personal data at any time. Contact our support team to exercise these rights. We comply with GDPR and applicable data protection regulations.'),
        _InfoSection('Cookies & Analytics',
            'MaxilloAI does not use advertising cookies. Anonymised, aggregated analytics may be collected to improve app performance.'),
      ],
    );
  }


  void _showAboutApp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AboutAppSheet(),
    );
  }

  // ── Generic info sheet ────────────────────────────────────────────────────

  void _showInfoSheet(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<_InfoSection> sections,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InfoSheetContent(
        icon: icon,
        iconColor: iconColor,
        title: title,
        sections: sections,
      ),
    );
  }

  // ── Auth dialogs ──────────────────────────────────────────────────────────

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of MaxilloAI?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AppState>().signOut();
            },
            child: const Text('Log Out', style: TextStyle(color: AppColors.risk)),
          ),
        ],
      ),
    );
  }
}

// ── Data classes ─────────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final bool danger;
  _MenuItem(this.icon, this.label, this.sub, this.onTap, {this.danger = false});
}

class _InfoSection {
  final String heading;
  final String body;
  const _InfoSection(this.heading, this.body);
}

// ── Bottom sheet widgets ──────────────────────────────────────────────────────

class _InfoSheetContent extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<_InfoSection> sections;

  const _InfoSheetContent({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.heading)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(),
            ),
            // Content
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: sections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (_, i) {
                  final s = sections[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.heading,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.heading)),
                      const SizedBox(height: 6),
                      Text(s.body,
                          style: const TextStyle(fontSize: 13, color: AppColors.subText, height: 1.6)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _AboutAppSheet extends StatelessWidget {
  const _AboutAppSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 20),
          // App logo / branding block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.biotech_rounded, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 12),
                const Text('MaxilloAI',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('AI-Powered Maxillofacial Outcome Prediction',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12.5)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Info rows
          _AboutRow(Icons.tag_rounded, 'Version', '1.0.0 (Build 1)'),
          _AboutRow(Icons.auto_awesome, 'AI Engine', 'Gemini Pro Vision'),
          _AboutRow(Icons.cloud_outlined, 'Backend', 'Firebase + Render.com'),
          _AboutRow(Icons.medical_services_outlined, 'Speciality', 'Maxillofacial Surgery'),
          _AboutRow(Icons.verified_outlined, 'Status', 'Research Preview'),
          _AboutRow(Icons.calendar_today_outlined, 'Release', 'August 2026'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.blueBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.primaryBlue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'MaxilloAI uses a Gemini-powered AI model to predict post-surgical soft tissue outcomes for maxillofacial reconstruction procedures. It is designed to assist qualified surgeons in pre-operative planning.',
                    style: TextStyle(fontSize: 12, color: AppColors.darkText, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('© 2026 MaxilloAI. All rights reserved.',
              style: TextStyle(fontSize: 11, color: AppColors.placeholder)),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _AboutRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.subText),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.subText)),
          const Spacer(),
          Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.heading)),
        ],
      ),
    );
  }
}
