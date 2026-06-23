import 'package:flutter/material.dart';

/// Premium dark-mode color palette for "Who is Impostor"
///
/// ## Background Layers (depth hierarchy)
/// | Token          | Hex       | Usage                          |
/// |----------------|-----------|--------------------------------|
/// | voidBlack      | #0A0A0F   | Deepest background             |
/// | abyss          | #12121A   | Scaffold / base surface        |
/// | surface        | #1A1A26   | Cards, elevated panels         |
/// | surfaceHigh    | #242433   | Hover / pressed states         |
///
/// ## Neon Accents
/// | Token          | Hex       | Usage                          |
/// |----------------|-----------|--------------------------------|
/// | mysticPurple   | #9B5DE5   | Primary CTA, brand glow        |
/// | mysticPurpleDim| #6B3FA0   | Secondary purple elements      |
/// | neonGreen      | #00F5A0   | Success, impostor reveal       |
/// | neonGreenDim   | #00C47E   | Green accents, badges          |
///
/// ## Text
/// | Token          | Hex       | Usage                          |
/// |----------------|-----------|--------------------------------|
/// | textPrimary    | #F0F0F5   | Headlines, primary copy        |
/// | textSecondary  | #9898B0   | Subtitles, hints               |
/// | textMuted      | #5C5C72   | Disabled, tertiary             |
///
/// ## Effects
/// | Token          | Value     | Usage                          |
/// |----------------|-----------|--------------------------------|
/// | glowPurple     | blur 24   | Primary button shadow          |
/// | glowGreen      | blur 20   | Accent highlights              |
/// | cardShadow     | blur 16   | Card elevation                 |
abstract final class AppColors {
  // Background layers
  static const voidBlack = Color(0xFF0A0A0F);
  static const abyss = Color(0xFF12121A);
  static const surface = Color(0xFF1A1A26);
  static const surfaceHigh = Color(0xFF242433);

  // Neon accents
  static const mysticPurple = Color(0xFF9B5DE5);
  static const mysticPurpleDim = Color(0xFF6B3FA0);
  static const mysticPurpleGlow = Color(0x669B5DE5);
  static const neonGreen = Color(0xFF00F5A0);
  static const neonGreenDim = Color(0xFF00C47E);
  static const neonGreenGlow = Color(0x6600F5A0);

  // Text
  static const textPrimary = Color(0xFFF0F0F5);
  static const textSecondary = Color(0xFF9898B0);
  static const textMuted = Color(0xFF5C5C72);

  // Borders & dividers
  static const borderSubtle = Color(0xFF2A2A3A);
  static const borderGlow = Color(0x339B5DE5);

  // Semantic
  static const danger = Color(0xFFFF4757);
  static const warning = Color(0xFFFFBE0B);

  // Gradients
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [voidBlack, abyss, Color(0xFF0F0F18)],
    stops: [0.0, 0.5, 1.0],
  );

  static const purpleGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mysticPurple, Color(0xFF7B2CBF)],
  );

  static const greenAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonGreen, neonGreenDim],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surface, Color(0xFF161622)],
  );
}
