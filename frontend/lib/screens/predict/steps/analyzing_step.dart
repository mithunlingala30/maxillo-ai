import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class AnalyzingStep extends StatefulWidget {
  /// Real progress driven by the actual API call lifecycle, 0.0 - 1.0.
  final double progress;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const AnalyzingStep({
    super.key,
    required this.progress,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<AnalyzingStep> createState() => _AnalyzingStepState();
}

class _AnalyzingStepState extends State<AnalyzingStep> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  static const _steps = [
    'Image processing',
    'Tissue layer mapping',
    'Feature extraction',
    'Outcome generation',
  ];

  @override
  Widget build(BuildContext context) {
    final percent = (widget.progress.clamp(0, 1) * 100).round();
    final hasError = widget.errorMessage != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) => Transform.scale(
              scale: hasError ? 1 : 1 + (_pulse.value * 0.05),
              child: child,
            ),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppColors.blueBg, AppColors.tealBg]),
                border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
              ),
              child: Icon(
                hasError ? Icons.error_outline : Icons.psychology_alt_rounded,
                size: 56,
                color: hasError ? AppColors.risk : AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            hasError ? 'Analysis Failed' : 'Analysing...',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            hasError
                ? widget.errorMessage!
                : 'Our AI is processing your images and generating soft tissue predictions. '
                    'This can take up to a minute.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.subText, fontSize: 13.5),
          ),
          const SizedBox(height: 28),
          if (!hasError) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Processing', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                Text('$percent%',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: widget.progress,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.teal),
              ),
            ),
            const SizedBox(height: 20),
            ..._steps.asMap().entries.map((entry) {
              final threshold = (entry.key + 1) / _steps.length;
              final done = widget.progress >= threshold - 0.01;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: done ? AppColors.teal : AppColors.border,
                        shape: BoxShape.circle,
                      ),
                      child: done ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: done ? AppColors.heading : AppColors.placeholder,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: widget.onRetry, child: const Text('Try Again')),
            ),
          ],
        ],
      ),
    );
  }
}
