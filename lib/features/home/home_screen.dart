import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/premium_widgets.dart';
import '../setup/game_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            const AmbientBackground(),

            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _IconButton(
                          icon: Icons.settings_outlined,
                          onTap: () {},
                        ),
                        _PassPlayBadge(),
                        _IconButton(
                          icon: Icons.help_outline_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // Logo & title
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return _LogoSection(
                          pulseValue: _pulseController.value,
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Pass & Play',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Tek telefon, elden ele.\nImpostor\'u bul!',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Feature cards
                    const Row(
                      children: [
                        Expanded(
                          child: _FeatureChip(
                            icon: Icons.groups_outlined,
                            label: '3–12 Oyuncu',
                            accent: AppColors.mysticPurple,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _FeatureChip(
                            icon: Icons.timer_outlined,
                            label: 'Hızlı Tur',
                            accent: AppColors.neonGreen,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // CTA buttons
                    GlowButton(
                      label: 'Oyunu Başlat',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                const GameSetupScreen(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.05),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: child,
                                ),
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 450),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    OutlinedButton(
                      onPressed: () {},
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Nasıl Oynanır'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Logo section ────────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  const _LogoSection({required this.pulseValue});

  final double pulseValue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final glowIntensity = 0.3 + pulseValue * 0.2;

    return Column(
      children: [
        // Impostor mask icon
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.purpleGlowGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.mysticPurple.withValues(alpha: glowIntensity),
                blurRadius: 32 + pulseValue * 8,
                spreadRadius: -4,
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology_outlined,
            size: 44,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 28),

        // Title
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.textPrimary, AppColors.mysticPurple],
          ).createShader(bounds),
          child: Text(
            'Who is',
            style: textTheme.displayMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),

        Text(
          'IMPOSTOR',
          style: textTheme.displayLarge?.copyWith(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 8),

        // Decorative line
        Container(
          width: 48,
          height: 3,
          decoration: BoxDecoration(
            gradient: AppColors.greenAccentGradient,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Small components ────────────────────────────────────────────────────────

class _PassPlayBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonGreen,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonGreenGlow,
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'PASS & PLAY',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 22),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      glowColor: accent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
