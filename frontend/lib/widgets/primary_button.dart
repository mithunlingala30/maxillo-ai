import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Gradient? gradient;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.gradient,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: enabled ? (gradient ?? AppColors.primaryButtonGradient) : null,
        color: enabled ? null : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: enabled ? AppShadows.glow(AppColors.primaryBlue) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.button),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.darkText),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: const TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
