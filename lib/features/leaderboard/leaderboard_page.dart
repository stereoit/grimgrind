import 'package:flutter/material.dart';

import '../../app_strings.dart';
import '../../mansion_store.dart';
import '../../models.dart';
import '../../shared/widgets/mansion_widgets.dart';
import '../../theme_package.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key, required this.store});

  final MansionStore store;

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  LeaderboardSort _sort = LeaderboardSort.mostActive;
  LeaderboardPeriod _period = LeaderboardPeriod.currentMonth;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final rows = widget.store.buildLeaderboard(period: _period, sort: _sort);
    return ListView(
      key: const PageStorageKey('leaderboard'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(
          s.leaderboardEyebrow,
          style: const TextStyle(
            color: Color(0xFFC6A15B),
            letterSpacing: 2,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(s.leaderboardHeading, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        const Text(
          'Počítají se výhradně karty potvrzené směnou u Ruky.',
          style: TextStyle(color: Color(0xFF968C80), fontSize: 12),
        ),
        const SizedBox(height: 14),
        SegmentedButton<LeaderboardPeriod>(
          segments: [
            for (final p in LeaderboardPeriod.values)
              ButtonSegment(value: p, label: Text(p.label)),
          ],
          selected: {_period},
          onSelectionChanged: (s) => setState(() => _period = s.first),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final s in LeaderboardSort.values) ...[
                ChoiceChip(
                  label: Text(s.label),
                  selected: _sort == s,
                  onSelected: (_) => setState(() => _sort = s),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          rows.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _PlayerLeaderboardCard(rank: i + 1, data: rows[i]),
          ),
        ),
      ],
    );
  }
}

class _PlayerLeaderboardCard extends StatelessWidget {
  const _PlayerLeaderboardCard({required this.rank, required this.data});

  final int rank;
  final PlayerLeaderboardCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);
    final auraColor = heatColor(context, data.heatLevel);
    final auraGlow = theme.heatGlowRadius(data.heatLevel);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17171A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: auraColor,
          width: data.heatLevel == HeatLevel.coldAsh ? 1 : 2,
        ),
        boxShadow: auraGlow > 0
            ? [
                BoxShadow(
                  color: auraColor.withValues(alpha: 0.45),
                  blurRadius: auraGlow,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: auraColor.withValues(alpha: 0.2),
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: auraColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            data.member.nickname,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (data.member.isHand) ...[
                          const SizedBox(width: 6),
                          const Tooltip(
                            message: 'Zakladatel = Ruka',
                            child: Icon(
                              Icons.front_hand,
                              size: 16,
                              color: Color(0xFFC6A15B),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${data.monthlyLevel.label} (${data.monthlyLevel.utCallout})',
                      style: const TextStyle(
                        color: Color(0xFFC6A15B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                avatar: Icon(
                  heatIcon(context, data.heatLevel),
                  size: 16,
                  color: auraColor,
                ),
                label: Text(
                  '${data.heatLevel.label} (+${data.heatLevel.bonusPercent} %)',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'ÚKOLY',
                  value: '${data.approvedTaskCount}',
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'COINY',
                  value: '${data.approvedCoins}',
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'STREAK',
                  value: '${data.streakDays} d',
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'ČAS',
                  value: '${data.approvedMinutes} m',
                ),
              ),
            ],
          ),
          if (data.inBankCount > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'V Mešci čeká: ${data.inBankCount} karet (',
                  style: const TextStyle(color: Color(0xFF968C80), fontSize: 11),
                ),
                CoinAmount(
                  amount: data.inBankCoins,
                  fontSize: 11,
                  iconSize: 12,
                  color: const Color(0xFF968C80),
                  fontWeight: FontWeight.normal,
                ),
                const Text(
                  ')',
                  style: TextStyle(color: Color(0xFF968C80), fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 1.2,
            color: Color(0xFF968C80),
          ),
        ),
      ],
    );
  }
}
