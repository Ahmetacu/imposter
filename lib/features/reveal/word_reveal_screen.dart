import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/game_session.dart';
import '../../core/models/player.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/flip_reveal_card.dart';

class WordRevealScreen extends StatefulWidget {
  const WordRevealScreen({
    super.key,
    required this.session,
  });

  final GameSession session;

  @override
  State<WordRevealScreen> createState() => _WordRevealScreenState();
}

class _WordRevealScreenState extends State<WordRevealScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _turnController;
  late Animation<double> _turnFade;
  late Animation<Offset> _turnSlide;

  bool _allPlayersDone = false;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _turnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _turnFade = CurvedAnimation(
      parent: _turnController,
      curve: Curves.easeOut,
    );
    _turnSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _turnController,
      curve: Curves.easeOutCubic,
    ));
    _turnController.forward();
  }

  @override
  void dispose() {
    _turnController.dispose();
    super.dispose();
  }

  GameSession get session => widget.session;

  Player get _currentPlayer => session.playerAt(_currentIndex);

  Future<void> _advanceToNextPlayer() async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    await _turnController.reverse();

    if (!mounted) return;

    if (_currentIndex >= session.playerCount - 1) {
      setState(() => _allPlayersDone = true);
      HapticFeedback.heavyImpact();
    } else {
      setState(() => _currentIndex++);
      await _turnController.forward();
    }

    _isTransitioning = false;
  }

  void _onRevealComplete() {
    _advanceToNextPlayer();
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
            SafeArea(
              child: _allPlayersDone
                  ? _RoundCompleteView(
                      onContinue: () => Navigator.of(context).pop(),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _TopBar(
                            current: _currentIndex + 1,
                            total: session.playerCount,
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 32),

                          // Oyuncu sırası başlığı
                          FadeTransition(
                            opacity: _turnFade,
                            child: SlideTransition(
                              position: _turnSlide,
                              child: Column(
                                children: [
                                  Text(
                                    '${_currentPlayer.name} Oyuncusunun Sırası',
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Telefonu ${_currentPlayer.name}\'e ver',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // İlerleme çubuğu
                          FadeTransition(
                            opacity: _turnFade,
                            child: _ProgressBar(
                              current: _currentIndex + 1,
                              total: session.playerCount,
                            ),
                          ),

                          const Spacer(),

                          // Flip kart
                          FadeTransition(
                            opacity: _turnFade,
                            child: SlideTransition(
                              position: _turnSlide,
                              child: FlipRevealCard(
                                key: ValueKey(_currentIndex),
                                word: session.secretWord,
                                category: session.category,
                                isImpostor: _currentPlayer.isImpostor,
                                onRevealComplete: _onRevealComplete,
                              ),
                            ),
                          ),

                          const Spacer(),

                          Text(
                            'Kimseye bakma — sadece sen gör!',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 24),
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

// ─── Alt bileşenler ──────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.current,
    required this.total,
    required this.onBack,
  });

  final int current;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Text(
            '$current / $total',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        const Spacer(),
        const SizedBox(width: 44),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

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
            color: AppColors.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 22),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isDone = i < current - 1;
        final isActive = i == current - 1;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isDone
                  ? AppColors.neonGreen
                  : isActive
                      ? AppColors.mysticPurple
                      : AppColors.borderSubtle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.mysticPurple.withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

class _RoundCompleteView extends StatefulWidget {
  const _RoundCompleteView({required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<_RoundCompleteView> createState() => _RoundCompleteViewState();
}

class _RoundCompleteViewState extends State<_RoundCompleteView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    return FadeTransition(
      opacity: fade,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: scale,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.greenAccentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonGreenGlow,
                        blurRadius: 32,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: AppColors.voidBlack,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Herkes Hazır!',
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tüm oyuncular kelimelerini gördü.\nTartışma aşamasına geçilebilir.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onContinue,
                  child: const Text('Tamam'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
