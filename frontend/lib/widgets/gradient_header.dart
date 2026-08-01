import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GradientHeader extends StatelessWidget {
  final Widget child;
  final double topPadding;
  final EdgeInsets padding;

  const GradientHeader({
    super.key,
    required this.child,
    this.topPadding = 56,
    this.padding = const EdgeInsets.fromLTRB(20, 56, 20, 20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: child,
    );
  }
}

class MaxilloLogo extends StatelessWidget {
  final double size;
  final bool light;
  const MaxilloLogo({super.key, this.size = 30, this.light = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.primaryButtonGradient,
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          child: Icon(Icons.face_retouching_natural,
              color: Colors.white, size: size * 0.6),
        ),
        const SizedBox(width: 8),
        Text(
          'MaxilloAI',
          style: TextStyle(
            color: light ? Colors.white : AppColors.heading,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ],
    );
  }
}
