import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_strings.dart';
import '../../mansion_store.dart';
import '../../models.dart';
import '../../shared/widgets/mansion_widgets.dart';
import '../../theme_package.dart';

class ChroniclePage extends StatelessWidget {
  const ChroniclePage({
    super.key,
    required this.store,
    required this.onOpenDeck,
  });

  final MansionStore store;
  final VoidCallback onOpenDeck;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final entries = store.feedEntries;

    return CustomScrollView(
      key: const PageStorageKey('chronicle'),
      slivers: [
        if (entries.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.dynamic_feed_outlined,
              imageAsset: 'assets/branding/chronicle_empty.png',
              title: s.feedEmptyTitle,
              text: s.feedEmptyText,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            sliver: SliverList.separated(
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final entry = entries[i];
                return switch (entry.type) {
                  FeedEntryType.cardPlayed => _ChroniclePlayedCardPost(
                    entry: entry,
                  ),
                  FeedEntryType.exchangeApproved => _ChronicleExchangePost(
                    entry: entry,
                  ),
                  FeedEntryType.monthProclamation =>
                    _ChronicleMonthDividerCard(entry: entry),
                };
              },
            ),
          ),
      ],
    );
  }
}

class _ChroniclePlayedCardPost extends StatelessWidget {
  const _ChroniclePlayedCardPost({required this.entry});

  final FeedEntry entry;

  @override
  Widget build(BuildContext context) {
    final heat = entry.heatAtEvent ?? HeatLevel.coldAsh;
    final level = entry.levelAtEvent ?? MonthlyLevel.awakened;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: heatColor(context, heat).withValues(
                    alpha: 0.2,
                  ),
                  child: Icon(
                    heatIcon(context, heat),
                    size: 18,
                    color: heatColor(context, heat),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.actorNickname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE9E0D0),
                        ),
                      ),
                      Text(
                        '${level.label} • ${DateFormat('d. M. • HH:mm').format(entry.createdAt)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF968C80),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF282015),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC6A15B)),
                  ),
                  child: CoinAmount(
                    amount: entry.coins ?? 0,
                    prefix: '+',
                    fontSize: 12,
                    iconSize: 15,
                  ),
                ),
              ],
            ),
          ),
          if (entry.choreId != null)
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    ThemeScope.of(context).cardAssetPath(entry.choreId!),
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 24, 14, 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xE60B0B0D)],
                        ),
                      ),
                      child: Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFFE9E0D0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Text(
              '${entry.actorNickname} ${entry.message}',
              style: const TextStyle(color: Color(0xFFD5CCB8), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChronicleExchangePost extends StatelessWidget {
  const _ChronicleExchangePost({required this.entry});

  final FeedEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFC6A15B), width: 1.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  ThemeScope.of(context).exchangeArt,
                  fit: BoxFit.cover,
                ),
                Container(
                  color: const Color(0x880B0B0D),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SCHVÁLENÁ SMĚNA RUKOU',
                        style: TextStyle(
                          color: Color(0xFFC6A15B),
                          letterSpacing: 2,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CoinAmount(
                        amount: entry.coins ?? 0,
                        fontSize: 24,
                        iconSize: 24,
                        color: const Color(0xFFE9E0D0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.message,
                  style: const TextStyle(height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  'Započteno do měsíčního Leaderboardu • ${DateFormat('d. M. • HH:mm').format(entry.createdAt)}',
                  style: const TextStyle(
                    color: Color(0xFF968C80),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChronicleMonthDividerCard extends StatelessWidget {
  const _ChronicleMonthDividerCard({required this.entry});

  final FeedEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFC6A15B))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'UZÁVĚRKA OBDOBÍ • ${entry.monthKey}',
                style: const TextStyle(
                  color: Color(0xFFC6A15B),
                  letterSpacing: 2,
                  fontSize: 10,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFC6A15B))),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFC6A15B), width: 1.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      ThemeScope.of(context).monthTrophyArt,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xE60B0B0D)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 12,
                      child: Text(
                        entry.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFFC6A15B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  entry.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
