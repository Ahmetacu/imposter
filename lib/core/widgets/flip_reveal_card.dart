import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

typedef FlipCardCallback = void Function(bool isRevealed);

/// 3D flip kart — basılı tut veya dokunarak kelime / impostor gösterir.
class FlipRevealCard extends StatefulWidget {
  const FlipRevealCard({
    super.key,
    required this.word,
    required this.category,
    required this.isImpostor,
    this.onRevealChanged,
    this.onRevealComplete,
  });

  final String word;
  final String category;
  final bool isImpostor;
  final FlipCardCallback? onRevealChanged;
  final VoidCallback? onRevealComplete;

  @override
  State<FlipRevealCard> createState() => FlipRevealCardState();
}

class FlipRevealCardState extends State<FlipRevealCard>
    with SingleTickerProviderStateMixin {
  static const _flipDuration = Duration(milliseconds: 520);
  static const _holdThreshold = Duration(milliseconds: 220);

  late final AnimationController _controller;
  late final Animation<double> _flipAnimation;

  bool _isRevealed = false;
  bool _isAnimating = false;
  bool _openedByTap = false;
  DateTime? _pointerDownTime;

  bool get isRevealed => _isRevealed;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _flipDuration);
    _flipAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.addStatusListener(_onFlipStatus);
  }

  void _onFlipStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _isRevealed = true;
        _isAnimating = false;
      });
      widget.onRevealChanged?.call(true);
      HapticFeedback.mediumImpact();
    } else if (status == AnimationStatus.dismissed) {
      setState(() {
        _isRevealed = false;
        _isAnimating = false;
        _openedByTap = false;
      });
      widget.onRevealChanged?.call(false);
    }
  }

  Future<void> reveal() async {
    if (_isRevealed || _isAnimating) return;
    setState(() => _isAnimating = true);
    await _controller.forward();
  }

  Future<void> hide() async {
    if (!_isRevealed || _isAnimating) return;
    setState(() => _isAnimating = true);
    await _controller.reverse();
  }

  Future<void> hideAndNotify() async {
    await hide();
    widget.onRevealComplete?.call();
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerDownTime = DateTime.now();
    if (!_isRevealed && !_isAnimating) {
      reveal();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_isRevealed || _isAnimating) return;

    final downTime = _pointerDownTime;
    if (downTime == null) return;

    final held = DateTime.now().difference(downTime) >= _holdThreshold;

    if (held) {
      hideAndNotify();
    } else {
      _openedByTap = true;
    }
    _pointerDownTime = null;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_isRevealed && !_isAnimating && !_openedByTap) {
      hideAndNotify();
    }
    _pointerDownTime = null;
  }

  void _onTap() {
    if (_isRevealed && _openedByTap && !_isAnimating) {
      hideAndNotify();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onFlipStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final angle = _flipAnimation.value * math.pi;
            final showFront = angle <= math.pi / 2;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle),
              child: showFront
                  ? _CardFront(isPressed: _isRevealed || _isAnimating)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: widget.isImpostor
                          ? const _ImpostorFace()
                          : _WordFace(
                              word: widget.word,
                              category: widget.category,
                            ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Kart yüzleri ────────────────────────────────────────────────────────────

class _CardFront extends StatelessWidget {
  const _CardFront({required this.isPressed});

  final bool isPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPressed
              ? AppColors.mysticPurple.withOpacity(0.5)
              : AppColors.borderSubtle.withOpacity(0.6),
          width: isPressed ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
          if (isPressed)
            const BoxShadow(
              color: AppColors.mysticPurpleGlow,
              blurRadius: 32,
              spreadRadius: -4,
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isPressed
                  ? AppColors.purpleGlowGradient
                  : const LinearGradient(
                      colors: [
                        AppColors.surfaceHigh,
                        AppColors.surface,
                      ],
                    ),
              boxShadow: isPressed
                  ? [
                      BoxShadow(
                        color: AppColors.mysticPurple.withOpacity(0.4),
                        blurRadius: 20,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isPressed ? Icons.visibility_rounded : Icons.touch_app_rounded,
              size: 36,
              color: isPressed ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isPressed ? 'Görüntüleniyor...' : 'Kartı Aç',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              isPressed
                  ? 'Elini çek veya tekrar dokun'
                  : 'Basılı tut veya dokunarak kelimeni gör',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _PulseHint(isActive: !isPressed),
        ],
      ),
    );
  }
}

class _PulseHint extends StatefulWidget {
  const _PulseHint({required this.isActive});

  final bool isActive;

  @override
  State<_PulseHint> createState() => _PulseHintState();
}

class _PulseHintState extends State<_PulseHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.isActive) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulseHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isActive) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Opacity(
          opacity: widget.isActive ? 0.5 + _pulse.value * 0.5 : 0.3,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swipe_vertical_rounded,
                size: 16,
                color: AppColors.mysticPurple.withOpacity(
                  0.6 + _pulse.value * 0.4,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Basılı tut',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.mysticPurple,
                      letterSpacing: 0.8,
                    ),
              ),
              Text(
                '  ·  ',
                style: TextStyle(color: AppColors.textMuted.withOpacity(0.5)),
              ),
              Text(
                'Dokun',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WordFace extends StatelessWidget {
  const _WordFace({required this.word, required this.category});

  final String word;
  final String category;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1E2E), Color(0xFF16162A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.neonGreen.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.neonGreenGlow,
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.neonGreen.withOpacity(0.25),
              ),
            ),
            child: Text(
              category.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            word,
            style: textTheme.displayMedium?.copyWith(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bu kelimeyi kimseye söyleme!',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpostorFace extends StatefulWidget {
  const _ImpostorFace();

  @override
  State<_ImpostorFace> createState() => _ImpostorFaceState();
}

class _ImpostorFaceState extends State<_ImpostorFace>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) {
        final glow = 0.25 + _shimmer.value * 0.25;

        return Container(
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF1A0A1E),
                  const Color(0xFF2D1040),
                  _shimmer.value,
                )!,
                const Color(0xFF0F0818),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.danger.withOpacity(0.4 + glow * 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withOpacity(glow),
                blurRadius: 32,
                spreadRadius: -8,
              ),
              BoxShadow(
                color: AppColors.mysticPurple.withOpacity(glow * 0.5),
                blurRadius: 24,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Arka plan deseni
              Positioned.fill(
                child: CustomPaint(
                  painter: _MysteryPatternPainter(
                    opacity: 0.04 + _shimmer.value * 0.03,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.psychology_alt_rounded,
                    size: 56,
                    color: AppColors.danger.withOpacity(0.85 + glow * 0.15),
                  ),
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppColors.danger,
                        Color.lerp(AppColors.danger, AppColors.mysticPurple, _shimmer.value)!,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'IMPOSTOR',
                      style: textTheme.displaySmall?.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Kelimeyi bilmiyorsun.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Saklan ve tahmin et.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MysteryPatternPainter extends CustomPainter {
  _MysteryPatternPainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mysticPurple.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 28.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_MysteryPatternPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
