import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'mansion_store.dart';
import 'models.dart';

void main() => runApp(const GrimGrindApp());

class GrimGrindApp extends StatefulWidget {
  const GrimGrindApp({super.key, this.store});

  final MansionStore? store;

  @override
  State<GrimGrindApp> createState() => _GrimGrindAppState();
}

class _GrimGrindAppState extends State<GrimGrindApp> {
  late final MansionStore store = widget.store ?? MansionStore();

  @override
  void dispose() {
    if (widget.store == null) store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GrimGrind',
      theme: _theme,
      home: MansionShell(store: store),
    );
  }
}

final _theme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0B0B0D),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFC6A15B),
    secondary: Color(0xFF6E1830),
    surface: Color(0xFF17171A),
    onSurface: Color(0xFFE9E0D0),
  ),
  fontFamily: 'serif',
  dividerColor: const Color(0xFF3B3329),
  cardTheme: const CardThemeData(
    color: Color(0xFF17171A),
    elevation: 0,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Color(0xFF3B3329)),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Color(0xFF101012),
    indicatorColor: Color(0xFF41212B),
    labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12)),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF6E1830),
    contentTextStyle: TextStyle(color: Color(0xFFF7EEE0)),
  ),
);

class MansionShell extends StatefulWidget {
  const MansionShell({super.key, required this.store});

  final MansionStore store;

  @override
  State<MansionShell> createState() => _MansionShellState();
}

class _MansionShellState extends State<MansionShell> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pages = [
      HallPage(store: widget.store),
      ChroniclePage(store: widget.store),
      DeckPage(store: widget.store),
      TreasuryPage(store: widget.store),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GRIMGRIND', style: TextStyle(letterSpacing: 3, fontSize: 19)),
            Text(
              'SÍDLO POVINNOSTÍ',
              style: TextStyle(
                color: Color(0xFF8E8170),
                letterSpacing: 2,
                fontSize: 9,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(Icons.nightlight_round, color: Color(0xFFC6A15B)),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Karty',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Kronika',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: 'Balíček',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Pokladna',
          ),
        ],
      ),
    );
  }
}

class HallPage extends StatelessWidget {
  const HallPage({super.key, required this.store});
  final MansionStore store;

  @override
  Widget build(BuildContext context) {
    final active = store.tableCards.toList();
    return CustomScrollView(
      key: const PageStorageKey('hall'),
      slivers: [
        const SliverToBoxAdapter(child: _HallHero()),
        if (active.isNotEmpty) ...[
          const SliverToBoxAdapter(child: _SectionTitle('PRÁVĚ VE HŘE')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
            sliver: SliverList.builder(
              itemCount: active.length,
              itemBuilder: (_, i) => _ActiveCard(
                store: store,
                card: active[i],
                canComplete: active[i].owner == store.nickname,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: _SectionTitle('KATALOG KARET')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisExtent: 292,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: store.availableCards.length,
            itemBuilder: (_, i) => ChoreCardView(
              card: store.availableCards.elementAt(i),
              onPressed: () => _showCardDetail(
                context,
                store,
                store.availableCards.elementAt(i),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HallHero extends StatelessWidget {
  const _HallHero();

  @override
  Widget build(BuildContext context) => Container(
    height: 310,
    margin: const EdgeInsets.fromLTRB(16, 18, 16, 18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF5A4931)),
      image: const DecorationImage(
        image: AssetImage('assets/art/card_bearer.png'),
        fit: BoxFit.cover,
      ),
    ),
  );
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({
    required this.store,
    required this.card,
    required this.canComplete,
  });
  final MansionStore store;
  final ChoreCard card;
  final bool canComplete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            'assets/cards/${card.chore.id}.png',
            width: 40,
            height: 52,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(card.chore.title),
        subtitle: Text('${card.owner} • ${card.chore.minutes} min'),
        trailing: canComplete
            ? FilledButton(
                onPressed: () => store.completeCard(card),
                child: const Text('Splněno'),
              )
            : const Chip(label: Text('Ve hře')),
      ),
    );
  }
}

class ChoreCardView extends StatelessWidget {
  const ChoreCardView({super.key, required this.card, this.onPressed});
  final ChoreCard card;
  final VoidCallback? onPressed;

  Color get accent => switch (card.chore.difficulty) {
    ChoreDifficulty.easy => const Color(0xFF66816A),
    ChoreDifficulty.medium => const Color(0xFFC6A15B),
    ChoreDifficulty.hard => const Color(0xFF9B3B48),
    ChoreDifficulty.special => const Color(0xFF846BA3),
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: accent, width: 3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card.chore.symbol,
                      style: TextStyle(fontSize: 25, color: accent),
                    ),
                    Text(
                      card.chore.difficulty.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/cards/${card.chore.id}.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  card.chore.title,
                  style: const TextStyle(fontSize: 19, height: 1.1),
                ),
                if (card.chore.note case final note?) ...[
                  const SizedBox(height: 7),
                  Text(
                    note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF968C80),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: accent),
                    const SizedBox(width: 5),
                    Text(
                      '${card.chore.minutes} min',
                      style: const TextStyle(fontSize: 11),
                    ),
                    const Spacer(),
                    ...List.generate(
                      3,
                      (index) => Container(
                        width: 14,
                        height: 4,
                        margin: const EdgeInsets.only(left: 3),
                        color: index < _difficultyBars(card.chore.difficulty)
                            ? accent
                            : const Color(0xFF3B3329),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${card.chore.reward} Kč',
                      style: const TextStyle(
                        color: Color(0xFFC6A15B),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      onPressed == null
                          ? Icons.verified_outlined
                          : Icons.zoom_in,
                      size: 18,
                      color: const Color(0xFF8E8170),
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

int _difficultyBars(ChoreDifficulty difficulty) => switch (difficulty) {
  ChoreDifficulty.easy => 1,
  ChoreDifficulty.medium => 2,
  ChoreDifficulty.hard || ChoreDifficulty.special => 3,
};

IconData _choreIcon(String id) => switch (id) {
  'trash' => Icons.delete_outline,
  'shopping' => Icons.shopping_bag_outlined,
  'dishwasher' => Icons.local_dining_outlined,
  'laundry' => Icons.checkroom_outlined,
  'stairs' => Icons.stairs_outlined,
  'queenie' => Icons.pets_outlined,
  'toilet' => Icons.cleaning_services_outlined,
  'dogs' => Icons.set_meal_outlined,
  'sport' => Icons.sports_basketball_outlined,
  'garden' => Icons.water_drop_outlined,
  'evening' => Icons.nightlight_outlined,
  'bathroom' => Icons.bathtub_outlined,
  'mop' => Icons.water_damage_outlined,
  'ironing' => Icons.iron_outlined,
  'cooking' => Icons.soup_kitchen_outlined,
  'school' => Icons.school_outlined,
  'room' => Icons.auto_awesome_outlined,
  _ => Icons.dark_mode_outlined,
};

Future<void> _showCardDetail(
  BuildContext context,
  MansionStore store,
  ChoreCard card,
) async {
  final taken = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF111114),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF5A5147),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/cards/${card.chore.id}.png',
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              card.chore.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 10),
            Text(
              card.chore.note ??
                  'Splň úkol poctivě a označ kartu jako hotovou.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF968C80), height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.schedule,
                    value: '${card.chore.minutes} min',
                    label: 'ODHAD',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Icons.speed,
                    value: card.chore.difficulty.label,
                    label: 'NÁROČNOST',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Icons.toll,
                    value: '${card.chore.reward} Kč',
                    label: 'ODMĚNA',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.front_hand_outlined),
                label: const Text('Vzít kartu'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (taken == true && context.mounted) {
    final accepted = store.takeCard(card);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          accepted
              ? 'Karta je teď tvoje. Hodně štěstí.'
              : 'Karta není dostupná.',
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF3B3329)),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Column(
      children: [
        Icon(icon, size: 19, color: const Color(0xFFC6A15B)),
        const SizedBox(height: 7),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            letterSpacing: 1.2,
            color: Color(0xFF776F66),
          ),
        ),
      ],
    ),
  );
}

class ChroniclePage extends StatelessWidget {
  const ChroniclePage({super.key, required this.store});
  final MansionStore store;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('chronicle'),
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        const _PageHeading(
          eyebrow: 'PAMĚŤ DOMU',
          title: 'Kronika sídla',
          subtitle: 'Každý čin zanechá ve zdech svou stopu.',
        ),
        ...store.events.map(
          (event) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                event.cardId == null
                    ? Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF5A4931)),
                        ),
                        child: Text(
                          event.symbol,
                          style: const TextStyle(
                            color: Color(0xFFC6A15B),
                            fontSize: 18,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          'assets/cards/${event.cardId}.png',
                          width: 42,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 25),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF272328)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.actor,
                          style: const TextStyle(
                            color: Color(0xFFC6A15B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.message,
                          style: const TextStyle(height: 1.4),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('d. M. • HH:mm').format(event.createdAt),
                          style: const TextStyle(
                            color: Color(0xFF776F66),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DeckPage extends StatelessWidget {
  const DeckPage({super.key, required this.store});
  final MansionStore store;

  @override
  Widget build(BuildContext context) {
    final cards = store.personalDeck.toList();
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: _PageHeading(
            eyebrow: 'SBÍRKA TROFEJÍ',
            title: 'Osobní balíček',
            subtitle: 'Dokončené trofeje. Klepnutím kartu otočíš.',
          ),
        ),
        if (store.awaitingApproval.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: FilledButton.icon(
                onPressed: () => _showAccounting(context, store),
                icon: const Icon(Icons.front_hand_outlined),
                label: Text(
                  'Požádat Ruku o zúčtování (${store.awaitingApproval.length})',
                ),
              ),
            ),
          ),
        if (cards.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.style_outlined,
              title: 'Balíček zeje prázdnotou',
              text: 'Dokonči kartu a požádej Ruku o zúčtování.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisExtent: 292,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: cards.length,
              itemBuilder: (_, i) => _FlipCard(card: cards[i]),
            ),
          ),
      ],
    );
  }
}

class _FlipCard extends StatefulWidget {
  const _FlipCard({required this.card});
  final ChoreCard card;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard> {
  bool flipped = false;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: flipped ? 1 : 0),
    duration: const Duration(milliseconds: 520),
    curve: Curves.easeInOutCubic,
    builder: (context, value, _) {
      final showBack = value >= 0.5;
      return GestureDetector(
        onTap: () => setState(() => flipped = !flipped),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(value * math.pi),
          child: showBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: _CardBack(card: widget.card),
                )
              : ChoreCardView(card: widget.card),
        ),
      );
    },
  );
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.card});
  final ChoreCard card;

  @override
  Widget build(BuildContext context) => Card(
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC6A15B), width: 2),
        borderRadius: BorderRadius.circular(8),
        image: const DecorationImage(
          image: AssetImage('assets/branding/app_icon.png'),
          opacity: 0.06,
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'KRONIKA KARTY',
            style: TextStyle(
              color: Color(0xFFC6A15B),
              letterSpacing: 2,
              fontSize: 10,
            ),
          ),
          const Spacer(),
          Icon(
            _choreIcon(card.chore.id),
            size: 48,
            color: const Color(0xFFC6A15B),
          ),
          const SizedBox(height: 16),
          Text(
            card.chore.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Text(
            'Zahrál ${card.owner}',
            style: const TextStyle(color: Color(0xFF968C80)),
          ),
          const SizedBox(height: 5),
          Text(
            card.completedAt == null
                ? 'Čas dokončení neznámý'
                : DateFormat('d. M. yyyy • HH:mm').format(card.completedAt!),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFC6A15B)),
          ),
          const Spacer(),
          Text(
            card.status == ChoreStatus.completed ? 'ČEKÁ NA RUKU' : 'ZÚČTOVÁNO',
            style: const TextStyle(fontSize: 10, letterSpacing: 1.6),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showAccounting(BuildContext context, MansionStore store) async {
  final count = store.awaitingApproval.length;
  final total = store.awaitingReward;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.front_hand, size: 58, color: Color(0xFFC6A15B)),
      title: const Text('Ruka přepočítala balíček'),
      content: Text(
        '$count dokončených karet má hodnotu $total Kč.',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Ještě ne'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Požádat o zúčtování'),
        ),
      ],
    ),
  );
  if (confirmed == true) store.accountCompletedCards();
}

class TreasuryPage extends StatelessWidget {
  const TreasuryPage({super.key, required this.store});
  final MansionStore store;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        const _PageHeading(
          eyebrow: 'RUKA DOHLÍŽÍ',
          title: 'Měsíční pokladna',
          subtitle: 'Hotové karty přepočítá tajemná Ruka.',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF17171A),
              border: Border.all(color: const Color(0xFF5A4931)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  store.level.label.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFC6A15B),
                    letterSpacing: 2,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${store.monthReward} Kč',
                  style: const TextStyle(fontSize: 42),
                ),
                Text(
                  '${store.personalDeck.length} karet • násobič ${store.level.multiplier.toStringAsFixed(1)}×',
                  style: const TextStyle(color: Color(0xFF968C80)),
                ),
              ],
            ),
          ),
        ),
        const _SectionTitle('PROFIL'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(store.nickname),
              subtitle: Text('Úroveň: ${store.level.label}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _rename(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _rename(BuildContext context) async {
    final controller = TextEditingController(text: store.nickname);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temná přezdívka'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 24,
          decoration: const InputDecoration(hintText: 'Např. Shadow Master'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zrušit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Uložit'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null) store.setNickname(value);
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });
  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: Color(0xFFC6A15B),
            letterSpacing: 2.2,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 30, height: 1)),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF968C80), height: 1.4),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8E8170),
        letterSpacing: 1.8,
        fontSize: 10,
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: const Color(0xFF5A4931)),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF968C80)),
          ),
        ],
      ),
    ),
  );
}
