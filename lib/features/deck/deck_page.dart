import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app_strings.dart';
import '../../mansion_store.dart';
import '../../models.dart';
import '../../shared/widgets/mansion_widgets.dart';
import '../../sound_service.dart';
import '../../theme_package.dart';

class DeckPage extends StatefulWidget {
  const DeckPage({super.key, required this.store});

  final MansionStore store;

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  ChoreDifficulty? _filter;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final theme = ThemeScope.of(context);
    final s = AppStrings.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final member = store.currentMember!;
        final level = store.monthlyLevelFor(member.id);
        final heat = store.heatLevelFor(member);
        final totalBonus = level.bonusPercent + heat.bonusPercent;

        final filtered = _filter == null
            ? store.deck
            : store.deck.where((c) => c.difficulty == _filter);
        final cards = [
          ...filtered.where((c) => store.isFavoriteChore(c.id)),
          ...filtered.where((c) => !store.isFavoriteChore(c.id)),
        ];

        return CustomScrollView(
          key: const PageStorageKey('deck'),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.deckEyebrow,
                      style: const TextStyle(
                        color: Color(0xFFC6A15B),
                        letterSpacing: 2,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.deckHeading,
                      style: const TextStyle(fontSize: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.deckBonusSummary(
                        s.monthlyLevelLabel(level, theme),
                        level.bonusPercent,
                        s.heatLabel(heat, theme),
                        heat.bonusPercent,
                        totalBonus,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF968C80),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: Text(s.deckAllFilter(store.deck.length)),
                            selected: _filter == null,
                            onSelected: withButtonSound1(
                              (_) => setState(() => _filter = null),
                            ),
                          ),
                          const SizedBox(width: 8),
                          for (final diff in ChoreDifficulty.values) ...[
                            FilterChip(
                              label: Text(s.difficultyLabel(diff, theme)),
                              selected: _filter == diff,
                              onSelected: withButtonSound1(
                                (_) => setState(() => _filter = diff),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  mainAxisExtent: 298,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: cards.length,
                itemBuilder: (context, i) {
                  final chore = cards[i];
                  final coins = store.effectiveCoinsFor(chore, member);
                  return _DeckCardTile(
                    key: ValueKey(chore.id),
                    chore: chore,
                    effectiveCoins: coins,
                    isFavorite: store.isFavoriteChore(chore.id),
                    onToggleFavorite: withButtonSound(
                      () => store.toggleFavoriteChore(chore.id),
                    )!,
                    onTap: withButtonSound(
                      () => _confirmPlayCard(context, store, chore, coins),
                    )!,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DeckCardTile extends StatelessWidget {
  const _DeckCardTile({
    super.key,
    required this.chore,
    required this.effectiveCoins,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  final ChoreDefinition chore;
  final int effectiveCoins;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);
    final accent = difficultyColor(context, chore.difficulty);
    final boosted = effectiveCoins > chore.baseCoins;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: accent, width: 3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      theme.choreSymbol(chore),
                      style: TextStyle(fontSize: 22, color: accent),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onToggleFavorite,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              if (animation.value < 0.5) {
                                return const SizedBox.shrink();
                              }
                              final angle = (1 - animation.value) * math.pi;
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.002)
                                  ..rotateY(angle),
                                child: child,
                              );
                            },
                            child: child,
                          );
                        },
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey<bool>(isFavorite),
                          size: 18,
                          color: isFavorite
                              ? const Color(0xFFC6A15B)
                              : const Color(0xFF968C80),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      visualDensity: VisualDensity.compact,
                      splashRadius: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      theme.cardAssetPath(chore.id),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.of(context).choreTitle(chore),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 17, height: 1.15),
                ),
                const SizedBox(height: 6),
                Text(
                  '${chore.minutes} min',
                  style: const TextStyle(
                    color: Color(0xFF968C80),
                    fontSize: 11,
                  ),
                ),
                const Divider(height: 16),
                Row(
                  children: [
                    CoinAmount(
                      amount: effectiveCoins,
                      fontSize: 17,
                      iconSize: 18,
                    ),
                    if (boosted) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${chore.baseCoins}',
                        style: const TextStyle(
                          color: Color(0xFF776F66),
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const Spacer(),
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFFE9E0D0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _confirmPlayCard(
  BuildContext context,
  MansionStore store,
  ChoreDefinition chore,
  int effectiveCoins,
) async {
  final s = AppStrings.of(context);
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF111114),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                ThemeScope.of(context).cardAssetPath(chore.id),
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              s.choreTitle(chore),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26),
            ),
            if (s.choreNote(chore) != null) ...[
              const SizedBox(height: 8),
              Text(
                s.choreNote(chore)!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF968C80)),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _DifficultyStatTile(
                    difficulty: chore.difficulty,
                    difficultyText: s.difficultyLabel(
                      chore.difficulty,
                      ThemeScope.of(context),
                    ),
                    label: s.difficultyStatLabel,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatTile(
                    icon: Icons.schedule,
                    value: '${chore.minutes} min',
                    label: s.estimateLabel,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatTile(
                    icon: Icons.toll,
                    value: '$effectiveCoins',
                    valueWidget: CoinAmount(
                      amount: effectiveCoins,
                      fontSize: 16,
                      iconSize: 16,
                      color: const Color(0xFFE9E0D0),
                    ),
                    label: s.pouchRewardLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.bolt),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s.playCardPrefix),
                    CoinAmount(
                      amount: effectiveCoins,
                      fontSize: 14,
                      iconSize: 15,
                      color: const Color(0xFFE9E0D0),
                    ),
                    const Text(')'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  if (confirmed == true && context.mounted) {
    final played = store.playCard(chore);
    if (played != null) {
      SoundService.instance.playCard();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.cardPlayedSnackbar(played.coinsAwarded)),
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}

/// Compact difficulty stat tile matching [StatTile] for the card details sheet.
class _DifficultyStatTile extends StatelessWidget {
  const _DifficultyStatTile({
    required this.difficulty,
    required this.difficultyText,
    required this.label,
  });

  final ChoreDifficulty difficulty;
  final String difficultyText;
  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = difficultyColor(context, difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF3B3329)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: _DifficultyScaleMeter(
              difficulty: difficulty,
              label: difficultyText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            difficultyText,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              letterSpacing: 1.4,
              color: Color(0xFF968C80),
            ),
          ),
        ],
      ),
    );
  }
}

/// 4-tier gothic faceted-diamond difficulty scale (Stitch-designed visual meter).
class _DifficultyScaleMeter extends StatelessWidget {
  const _DifficultyScaleMeter({
    required this.difficulty,
    required this.label,
  });

  final ChoreDifficulty difficulty;
  final String label;

  @override
  Widget build(BuildContext context) {
    final width = difficulty == ChoreDifficulty.special ? 54.0 : 50.0;
    return Semantics(
      label: label,
      child: Tooltip(
        message: label,
        child: SizedBox(
          width: width,
          height: 15,
          child: CustomPaint(
            painter: _DifficultyScalePainter(difficulty),
          ),
        ),
      ),
    );
  }
}

class _DifficultyScalePainter extends CustomPainter {
  const _DifficultyScalePainter(this.difficulty);

  final ChoreDifficulty difficulty;

  @override
  void paint(Canvas canvas, Size size) {
    final activeCount = switch (difficulty) {
      ChoreDifficulty.easy => 1,
      ChoreDifficulty.medium => 2,
      ChoreDifficulty.hard => 3,
      ChoreDifficulty.special => 4,
    };

    final (fillColor, strokeColor, sparkColor) = switch (difficulty) {
      ChoreDifficulty.easy => (
        const Color(0xFF8EBA94),
        const Color(0xFF66816A),
        const Color(0xFFE9E0D0),
      ),
      ChoreDifficulty.medium => (
        const Color(0xFFE5C17B),
        const Color(0xFFC6A15B),
        const Color(0xFF0B0B0D),
      ),
      ChoreDifficulty.hard => (
        const Color(0xFFD9536F),
        const Color(0xFF6E1830),
        const Color(0xFFFFFFFF),
      ),
      ChoreDifficulty.special => (
        const Color(0xFFB799E3),
        const Color(0xFF846BA3),
        const Color(0xFFF3DEB2),
      ),
    };

    final unlitFill = Paint()
      ..color = const Color(0xFF141416).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    final unlitStroke = Paint()
      ..color = const Color(0xFF3B3329).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final litFill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final litStroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;
    final sparkPaint = Paint()
      ..color = sparkColor
      ..style = PaintingStyle.fill;

    final cy = size.height / 2;
    const centers = [6.5, 19.0, 31.5, 44.5];

    for (var i = 0; i < 4; i++) {
      final isLit = i < activeCount;
      final isBossGem = difficulty == ChoreDifficulty.special && i == 3;
      final cx = isBossGem ? 45.5 : centers[i];
      final rx = isBossGem ? 6.2 : (isLit ? 4.6 : 3.7);
      final ry = isBossGem ? 6.6 : (isLit ? 5.6 : 4.4);

      final diamond = Path()
        ..moveTo(cx, cy - ry)
        ..lineTo(cx + rx, cy)
        ..lineTo(cx, cy + ry)
        ..lineTo(cx - rx, cy)
        ..close();

      if (isBossGem) {
        final bossRect = Rect.fromCenter(
          center: Offset(cx, cy),
          width: rx * 2,
          height: ry * 2,
        );
        final bossFill = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB799E3), Color(0xFFE5C17B)],
          ).createShader(bossRect);
        final bossStroke = Paint()
          ..color = const Color(0xFFF3DEB2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.25;
        canvas.drawPath(diamond, bossFill);
        canvas.drawPath(diamond, bossStroke);
        canvas.drawCircle(Offset(cx, cy), 1.5, sparkPaint);
      } else if (isLit) {
        canvas.drawPath(diamond, litFill);
        canvas.drawPath(diamond, litStroke);
        canvas.drawCircle(Offset(cx, cy), 1.2, sparkPaint);
      } else {
        canvas.drawPath(diamond, unlitFill);
        canvas.drawPath(diamond, unlitStroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DifficultyScalePainter oldDelegate) =>
      oldDelegate.difficulty != difficulty;
}
