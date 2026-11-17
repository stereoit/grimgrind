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
    final member = store.currentMember!;
    final level = store.monthlyLevelFor(member.id);
    final heat = store.heatLevelFor(member);
    final totalBonus = level.bonusPercent + heat.bonusPercent;

    final cards = _filter == null
        ? store.deck
        : store.deck.where((c) => c.difficulty == _filter).toList();

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
                chore: chore,
                effectiveCoins: coins,
                onTap: withButtonSound(
                  () => _confirmPlayCard(context, store, chore, coins),
                )!,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DeckCardTile extends StatelessWidget {
  const _DeckCardTile({
    required this.chore,
    required this.effectiveCoins,
    required this.onTap,
  });

  final ChoreDefinition chore;
  final int effectiveCoins;
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      theme.choreSymbol(chore),
                      style: TextStyle(fontSize: 22, color: accent),
                    ),
                    Text(
                      AppStrings.of(context)
                          .difficultyLabel(chore.difficulty, theme)
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        color: accent,
                      ),
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
                  chore.title,
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
              chore.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26),
            ),
            if (chore.note != null) ...[
              const SizedBox(height: 8),
              Text(
                chore.note!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF968C80)),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    icon: Icons.schedule,
                    value: '${chore.minutes} min',
                    label: s.estimateLabel,
                  ),
                ),
                const SizedBox(width: 10),
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
