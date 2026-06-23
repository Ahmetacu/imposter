import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -80,
            right: -60,
            child: _GlowOrb(
              color: AppColors.mysticPurple,
              size: 280,
              opacity: 0.12,
            ),
          ),
          const Positioned(
            bottom: 120,
            left: -80,
            child: _GlowOrb(
              color: AppColors.neonGreen,
              size: 220,
              opacity: 0.08,
            ),
          ),
          Positioned(
            top: height * 0.35,
            left: width * 0.5 - 100,
            child: const _GlowOrb(
              color: AppColors.mysticPurpleDim,
              size: 160,
              opacity: 0.06,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
    required this.opacity,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
