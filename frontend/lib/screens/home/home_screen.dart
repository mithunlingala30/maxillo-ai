import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/prediction_record.dart';
import '../../providers/app_state.dart';
import '../../services/prediction_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';
import '../notifications/notifications_screen.dart';
import 'insight_detail_screen.dart';
import 'main_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;
    final uid = state.authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.blueBg,
                          backgroundImage: profile?.photoUrl != null
                              ? NetworkImage(profile!.photoUrl!)
                              : null,
                          child: profile?.photoUrl == null
                              ? const Icon(Icons.person, color: AppColors.primaryBlue, size: 22)
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Patient Portal',
                                style: TextStyle(
                                  color: AppColors.subText,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.tealBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'AI Active',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.tealDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            profile?.fullName ?? 'MaxilloAI User',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.heading,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.notifications_none_rounded,
                                color: AppColors.heading, size: 19),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ));
                            },
                          ),
                          // Unread badge
                          Consumer<AppState>(
                            builder: (_, appState, __) {
                              final count = appState.unreadCount;
                              if (count == 0) return const SizedBox.shrink();
                              return Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Text(
                                      count > 9 ? '9+' : '$count',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Hero Telemetry Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: uid == null
                    ? const SizedBox.shrink()
                    : StreamBuilder<List<PredictionRecord>>(
                        stream: PredictionService().watchPredictions(uid),
                        builder: (context, snapshot) {
                          final records = snapshot.data ?? [];
                          final latest = records.isNotEmpty ? records.first : null;
                          return _HeroTelemetryCard(
                            latest: latest,
                            reportCount: records.length,
                          );
                        },
                      ),
              ),

              const SizedBox(height: 20),

              // Quick Actions Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                    Text(
                      '4 Modules',
                      style: TextStyle(fontSize: 11.5, color: AppColors.subText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.28,
                  children: [
                    ActionCard(
                      title: 'Start AI Prediction',
                      subtitle: '3D Scan Analysis',
                      icon: Icons.face_retouching_natural,
                      iconColor: AppColors.primaryBlue,
                      bgColor: AppColors.blueBg,
                      onTap: () => MainShellController.of(context)?.goTo(1),
                    ),
                    ActionCard(
                      title: 'Upload Scans',
                      subtitle: 'CT / Medical Images',
                      icon: Icons.document_scanner_outlined,
                      iconColor: AppColors.teal,
                      bgColor: AppColors.tealBg,
                      onTap: () => MainShellController.of(context)?.goTo(1),
                    ),
                    ActionCard(
                      title: 'My Reports',
                      subtitle: 'PDF Exports & History',
                      icon: Icons.picture_as_pdf_outlined,
                      iconColor: AppColors.purple,
                      bgColor: AppColors.purpleBg,
                      onTap: () => MainShellController.of(context)?.goTo(2),
                    ),
                    ActionCard(
                      title: 'Recovery Tracker',
                      subtitle: 'Timeline & Plan',
                      icon: Icons.timeline_rounded,
                      iconColor: AppColors.warning,
                      bgColor: AppColors.warningBg,
                      onTap: () => MainShellController.of(context)?.goTo(3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Recent Scans Feed Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => MainShellController.of(context)?.goTo(2),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: uid == null
                    ? const SizedBox.shrink()
                    : StreamBuilder<List<PredictionRecord>>(
                        stream: PredictionService().watchPredictions(uid),
                        builder: (context, snapshot) {
                          final records = snapshot.data ?? [];
                          if (records.isEmpty) {
                            return SoftCard(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.blueBg,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.analytics_outlined,
                                        color: AppColors.primaryBlue, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('No Recent Predictions',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600, fontSize: 13)),
                                        Text('Perform your first scan analysis to unlock tracking.',
                                            style: TextStyle(
                                                fontSize: 11, color: AppColors.subText)),
                                      ],
                                    ),
                                  ),
                                  SmallButton(
                                    label: 'Start',
                                    icon: Icons.play_arrow_rounded,
                                    onTap: () => MainShellController.of(context)?.goTo(1),
                                  ),
                                ],
                              ),
                            );
                          }
                          final latest = records.first;
                          return SoftCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.tealBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.check_circle_outline_rounded,
                                      color: AppColors.tealDark, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(latest.surgeryType,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600, fontSize: 13)),
                                      Text(
                                          'Confidence: ${latest.confidenceScore.toStringAsFixed(0)}% · ${latest.riskLevel} Risk',
                                          style: const TextStyle(
                                              fontSize: 11, color: AppColors.subText)),
                                    ],
                                  ),
                                ),
                                SmallButton(
                                  label: 'Report',
                                  icon: Icons.picture_as_pdf_rounded,
                                  isOutlined: true,
                                  onTap: () => MainShellController.of(context)?.goTo(2),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 22),

              // Educational Hub Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  'Maxillofacial Insights',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ..._educationalCards.map(
                (e) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: SoftCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InsightDetailScreen(
                            title: e.$1,
                            icon: e.$2,
                            bgColor: e.$3,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: e.$3,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(e.$2, color: AppColors.primaryBlue, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            e.$1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                              color: AppColors.heading,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppColors.placeholder, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static final _educationalCards = [
    ('Understanding Maxillofacial Reconstruction', Icons.school_outlined, AppColors.blueBg),
    ('Post-Operative Recovery Guidelines', Icons.tips_and_updates_outlined, AppColors.tealBg),
    ('AI Prediction & Accuracy FAQs', Icons.help_outline_rounded, AppColors.purpleBg),
    ('Microvascular Flap & Healing Steps', Icons.health_and_safety_outlined, AppColors.warningBg),
  ];
}

class _HeroTelemetryCard extends StatelessWidget {
  final PredictionRecord? latest;
  final int reportCount;

  const _HeroTelemetryCard({required this.latest, required this.reportCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 12),
                    SizedBox(width: 5),
                    Text(
                      'AI TELEMETRY LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (latest != null)
                Text(
                  '${latest!.confidenceScore.toStringAsFixed(0)}% Match',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            latest == null ? 'Maxillofacial Reconstruction AI' : latest!.surgeryType,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            latest == null
                ? 'No predictions yet — start your first AI analysis.'
                : 'Target: ${latest!.recoveryEstimate} · ${latest!.riskLevel} Risk Profile',
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.12), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryStat(
                  'AI Confidence',
                  latest == null ? '—' : '${latest!.confidenceScore.toStringAsFixed(0)}%',
                ),
              ),
              Container(width: 1, height: 28, color: Colors.white.withOpacity(0.15)),
              Expanded(
                child: _summaryStat(
                  'Risk Profile',
                  latest == null ? '—' : latest!.riskLevel,
                ),
              ),
              Container(width: 1, height: 28, color: Colors.white.withOpacity(0.15)),
              Expanded(
                child: _summaryStat('Scan Reports', '$reportCount'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SmallButton(
                label: 'New AI Scan',
                icon: Icons.add_a_photo_outlined,
                color: Colors.white,
                textColor: AppColors.navy,
                onTap: () => MainShellController.of(context)?.goTo(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 10),
        ),
      ],
    );
  }
}
