import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;
  final BoxBorder? border;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: border,
            boxShadow: AppShadows.soft,
          ),
          child: child,
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;
  final String? subtitle;

  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.placeholder),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppColors.heading,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.subText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SmallButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final bool isOutlined;

  const SmallButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color = AppColors.primaryBlue,
    this.textColor = Colors.white,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOutlined ? Colors.transparent : color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: isOutlined ? Border.all(color: color, width: 1.2) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: isOutlined ? color : textColor),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOutlined ? color : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;
  final IconData icon;

  const StatPill({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.subText),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class RiskBadge extends StatelessWidget {
  final String level; // Low / Medium / High
  const RiskBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$level Risk',
        style: TextStyle(color: colors.$1, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }

  (Color, Color) _colorsFor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return (AppColors.risk, AppColors.riskBg);
      case 'medium':
        return (AppColors.warning, AppColors.warningBg);
      default:
        return (AppColors.success, AppColors.successBg);
    }
  }
}
