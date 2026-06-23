import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/data/word_pool.dart';
import '../../core/logic/game_engine.dart';
import '../../core/models/word_pack_id.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/premium_widgets.dart';
import '../reveal/word_reveal_screen.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int _playerCount = 4;
  WordPackId _selectedPack = WordPackId.generalCulture;
  late List<TextEditingController> _nameControllers;

  @override
  void initState() {
    super.initState();
    _nameControllers = _buildControllers(_playerCount);
  }

  List<TextEditingController> _buildControllers(int count) {
    return List.generate(
      count,
      (i) => TextEditingController(text: 'Oyuncu ${i + 1}'),
    );
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _setPlayerCount(int count) {
    if (count == _playerCount) return;

    final oldControllers = _nameControllers;
    setState(() {
      _playerCount = count;
      _nameControllers = _buildControllers(count);
      for (var i = 0; i < count && i < oldControllers.length; i++) {
        _nameControllers[i].text = oldControllers[i].text;
      }
    });

    for (final c in oldControllers) {
      if (!_nameControllers.contains(c)) c.dispose();
    }
  }

  void _startGame() {
    final names = _nameControllers.map((c) => c.text).toList();
    final session = GameEngine.createSession(
      playerNames: names,
      packId: _selectedPack,
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => WordRevealScreen(session: session),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pack = WordPool.packById(_selectedPack);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            const AmbientBackground(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: AppColors.textSecondary,
                        ),
                        Expanded(
                          child: Text(
                            'Oyun Kurulumu',
                            style: textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      children: [
                        _SectionTitle(
                          icon: Icons.groups_outlined,
                          title: 'Oyuncu Sayısı',
                          subtitle: 'En az ${WordPool.minPlayers} oyuncu',
                        ),
                        const SizedBox(height: 16),
                        _PlayerCountStepper(
                          value: _playerCount,
                          onChanged: _setPlayerCount,
                        ),
                        const SizedBox(height: 32),
                        _SectionTitle(
                          icon: Icons.category_outlined,
                          title: 'Kelime Paketi',
                          subtitle: '${pack.wordCount} kelime',
                        ),
                        const SizedBox(height: 16),
                        ...WordPackId.values.map(
                          (id) => _PackTile(
                            packId: id,
                            wordCount: WordPool.packById(id).wordCount,
                            isSelected: _selectedPack == id,
                            onTap: () => setState(() => _selectedPack = id),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _SectionTitle(
                          icon: Icons.badge_outlined,
                          title: 'Oyuncu İsimleri',
                          subtitle: 'Boş bırakılırsa varsayılan isim kullanılır',
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(_playerCount, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _PlayerNameField(
                              controller: _nameControllers[i],
                              index: i,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: GlowButton(
                      label: 'Oyunu Başlat',
                      icon: Icons.play_arrow_rounded,
                      onPressed: _startGame,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, color: AppColors.mysticPurple, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleMedium),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayerCountStepper extends StatelessWidget {
  const _PlayerCountStepper({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      glowColor: AppColors.mysticPurple,
      child: Row(
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            enabled: value > WordPool.minPlayers,
            onTap: () => onChanged(value - 1),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$value',
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.mysticPurple,
                  ),
                ),
                Text(
                  'oyuncu',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            enabled: value < WordPool.maxPlayers,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.surfaceHigh
                : AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? AppColors.borderSubtle : AppColors.borderSubtle.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            icon,
            color: enabled ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _PackTile extends StatelessWidget {
  const _PackTile({
    required this.packId,
    required this.wordCount,
    required this.isSelected,
    required this.onTap,
  });

  final WordPackId packId;
  final int wordCount;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon => switch (packId) {
        WordPackId.generalCulture => Icons.public_rounded,
        WordPackId.foods => Icons.restaurant_rounded,
        WordPackId.movies => Icons.movie_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.purpleGlowGradient : AppColors.cardGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.mysticPurple.withValues(alpha: 0.6)
                    : AppColors.borderSubtle.withValues(alpha: 0.6),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.mysticPurpleGlow,
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  _icon,
                  color: isSelected ? AppColors.textPrimary : AppColors.mysticPurple,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        packId.displayName,
                        style: textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$wordCount kelime',
                        style: textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? AppColors.textPrimary.withValues(alpha: 0.7)
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.neonGreen,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerNameField extends StatelessWidget {
  const _PlayerNameField({
    required this.controller,
    required this.index,
  });

  final TextEditingController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
      decoration: InputDecoration(
        hintText: 'Oyuncu ${index + 1}',
        hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6)),
        filled: true,
        fillColor: AppColors.surface.withValues(alpha: 0.8),
        prefixIcon: Icon(
          Icons.person_outline_rounded,
          color: AppColors.textMuted.withValues(alpha: 0.7),
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.borderSubtle.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.mysticPurple, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
