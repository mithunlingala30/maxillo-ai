import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../auth/auth_gate.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 2200), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final state = context.read<AppState>();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => state.hasSeenOnboarding
            ? const AuthGate()
            : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 + (0.06 * _controller.value),
                    child: child,
                  );
                },
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: const Icon(Icons.face_retouching_natural,
                      color: Colors.white, size: 52),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'MaxilloAI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Predict Your Recovery With AI',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'AI-powered prediction of soft tissue outcomes after '
                  'maxillofacial reconstruction',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.5),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 160,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
