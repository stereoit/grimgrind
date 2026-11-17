import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_strings.dart';
import '../../mansion_store.dart';
import '../../models.dart';
import '../../shared/widgets/mansion_widgets.dart';
import '../../sound_service.dart';
import '../../theme_package.dart';

class PouchPage extends StatelessWidget {
  const PouchPage({super.key, required this.store});

  final MansionStore store;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final member = store.currentMember!;
    final bankCards = store.bankCardsFor(member.id);
    final pendingMine = store.pendingCardsFor(member.id);
    final bankCoins = store.bankCoinsFor(member.id);

    return ListView(
      key: const PageStorageKey('pouch'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(
          s.pouchEyebrow,
          style: const TextStyle(
            color: Color(0xFFC6A15B),
            letterSpacing: 2,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(s.pouchHeading, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF17171A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFC6A15B)),
          ),
          child: Column(
            children: [
              CoinAmount(
                amount: bankCoins,
                fontSize: 38,
                iconSize: 34,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: bankCards.isEmpty
                      ? null
                      : () {
                          final req = store.requestExchange();
                          if (req != null) {
                            SoundService.instance.playConvertCoins();
                          }
                          if (req != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  s.exchangeRequestedSnackbar(req.totalCoins),
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.front_hand_outlined),
                  label: Text(
                    bankCards.isEmpty
                        ? s.pouchEmpty
                        : s.requestExchangeBtn(bankCards.length),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (bankCards.isNotEmpty) ...[
          SectionTitle(s.playedCardsInPouchSection),
          ...bankCards.map(
            (card) => Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    ThemeScope.of(context).cardAssetPath(card.chore.id),
                    width: 40,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(s.choreTitle(card.chore)),
                subtitle: Text(
                  DateFormat('d. M. • HH:mm').format(card.playedAt),
                ),
                trailing: CoinAmount(
                  amount: card.coinsAwarded,
                  prefix: '+',
                  fontSize: 14,
                  iconSize: 16,
                ),
              ),
            ),
          ),
        ],
        if (pendingMine.isNotEmpty) ...[
          SectionTitle(s.pendingCardsSection),
          ...pendingMine.map(
            (card) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.hourglass_top,
                  color: Color(0xFFC6A15B),
                ),
                title: Text(s.choreTitle(card.chore)),
                trailing: CoinAmount(
                  amount: card.coinsAwarded,
                  fontSize: 13,
                  iconSize: 15,
                ),
              ),
            ),
          ),
        ],
        if (store.isCurrentUserHand) ...[
          const Divider(height: 36),
          SectionTitle(s.handManagementSection),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final created = store.closeMonth();
                    if (created > 0) {
                      SoundService.instance.playConvertCoins();
                    } else {
                      SoundService.instance.playButtonTap();
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(s.monthClosedSnackbar(created)),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.event_available),
                  label: Text(s.closeMonthBtn),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (store.pendingExchanges.isEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(s.noPendingExchanges),
              ),
            )
          else
            ...store.pendingExchanges.map(
              (req) => _PendingExchangeCard(store: store, req: req),
            ),
        ],
      ],
    );
  }
}

class _PendingExchangeCard extends StatelessWidget {
  const _PendingExchangeCard({required this.store, required this.req});

  final MansionStore store;
  final ExchangeRequest req;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cards = store.playedCards
        .where((c) => req.cardIds.contains(c.id))
        .toList();
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFC6A15B)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    req.memberNickname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CoinAmount(
                  amount: req.totalCoins,
                  fontSize: 16,
                  iconSize: 17,
                ),
              ],
            ),
            if (req.isAutoMonthEnd)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  s.autoMonthEndLabel,
                  style: const TextStyle(color: Color(0xFF968C80), fontSize: 11),
                ),
              ),
            const Divider(),
            ...cards.map(
              (c) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(s.choreTitle(c.chore)),
                subtitle: CoinAmount(
                  amount: c.coinsAwarded,
                  fontSize: 12,
                  iconSize: 13,
                  color: const Color(0xFF968C80),
                  fontWeight: FontWeight.normal,
                ),
                trailing: IconButton(
                  tooltip: s.rejectCardTooltip,
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: withButtonSound(
                    () => store.rejectCardInRequest(req.id, c.id),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  SoundService.instance.playConvertCoins();
                  store.approveExchange(req.id);
                },
                icon: const Icon(Icons.verified_outlined),
                label: Text(s.approveExchangeBtn(req.totalCoins)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
