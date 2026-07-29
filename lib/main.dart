import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'mansion_store.dart';
import 'models.dart';

void main() => runApp(const ChoreCashApp());

class ChoreCashApp extends StatefulWidget {
  const ChoreCashApp({super.key, this.store});

  final MansionStore? store;

  @override
  State<ChoreCashApp> createState() => _ChoreCashAppState();
}

class _ChoreCashAppState extends State<ChoreCashApp> {
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
      title: 'ChoreCash',
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
            Text('CHORECASH', style: TextStyle(letterSpacing: 3, fontSize: 19)),
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
        actions: [
          PopupMenuButton<MansionRole>(
            tooltip: 'Změnit roli',
            initialValue: widget.store.role,
            onSelected: widget.store.setRole,
            itemBuilder: (_) => MansionRole.values
                .map(
                  (role) => PopupMenuItem(value: role, child: Text(role.label)),
                )
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 19),
                  const SizedBox(width: 8),
                  Text(widget.store.role.label),
                ],
              ),
            ),
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
    final isServant = store.role == MansionRole.servant;
    final active = isServant
        ? store.pendingRequests.toList()
        : store.assignedCards.toList();
    return CustomScrollView(
      key: const PageStorageKey('hall'),
      slivers: [
        SliverToBoxAdapter(
          child: _PageHeading(
            eyebrow: isServant ? 'SLUŽEBNICKÁ KOMNATA' : 'VELKÝ SÁL',
            title: isServant ? 'Žádosti o vydání' : 'Vyber si svůj osud',
            subtitle: isServant
                ? 'Schval karty, které si hráči vyžádali.'
                : 'Požádej Služebníka o kartu a získej odměnu.',
          ),
        ),
        if (active.isNotEmpty) ...[
          const SliverToBoxAdapter(child: _SectionTitle('PRÁVĚ VE HŘE')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
            sliver: SliverList.builder(
              itemCount: active.length,
              itemBuilder: (_, i) => _ActiveCard(store: store, card: active[i]),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: _SectionTitle('KATALOG KARET')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisExtent: 252,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: store.availableCards.length,
            itemBuilder: (_, i) => ChoreCardView(
              card: store.availableCards.elementAt(i),
              onPressed: store.role == MansionRole.player
                  ? () {
                      final accepted = store.requestCard(
                        store.availableCards.elementAt(i),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            accepted
                                ? 'Žádost byla odeslána Služebníkovi.'
                                : 'Tato karta zatím není dostupná.',
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.store, required this.card});
  final MansionStore store;
  final ChoreCard card;

  @override
  Widget build(BuildContext context) {
    final servant = store.role == MansionRole.servant;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Text(
          card.chore.symbol,
          style: const TextStyle(color: Color(0xFFC6A15B), fontSize: 28),
        ),
        title: Text(card.chore.title),
        subtitle: Text(
          servant
              ? 'Žádá ${card.owner}'
              : '${card.chore.reward} Kč čeká na dokončení',
        ),
        trailing: FilledButton(
          onPressed: () =>
              servant ? store.issueCard(card) : store.completeCard(card),
          child: Text(servant ? 'Vydat' : 'Splněno'),
        ),
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
                          ? Icons.lock_outline
                          : Icons.arrow_forward,
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
                Container(
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
            subtitle: 'Schválené karty a odměny tohoto měsíce.',
          ),
        ),
        if (cards.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.style_outlined,
              title: 'Balíček zeje prázdnotou',
              text: 'Dokonči kartu a nech ji schválit Rukou.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisExtent: 252,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: cards.length,
              itemBuilder: (_, i) => ChoreCardView(card: cards[i]),
            ),
          ),
      ],
    );
  }
}

class TreasuryPage extends StatelessWidget {
  const TreasuryPage({super.key, required this.store});
  final MansionStore store;

  @override
  Widget build(BuildContext context) {
    final awaiting = store.awaitingApproval.toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        const _PageHeading(
          eyebrow: 'RUKA DOHLÍŽÍ',
          title: 'Měsíční pokladna',
          subtitle: 'Odměna roste s každou schválenou kartou.',
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
                if (store.role == MansionRole.hand &&
                    store.personalDeck.any(
                      (card) => card.status == ChoreStatus.approved,
                    )) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: store.payMonth,
                      icon: const Icon(Icons.draw_outlined),
                      label: const Text('Podepsat šek'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (awaiting.isNotEmpty) ...[
          const _SectionTitle('ČEKÁ NA RUKU'),
          ...awaiting.map(
            (card) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Card(
                child: ListTile(
                  title: Text(card.chore.title),
                  subtitle: Text('${card.owner} • ${card.chore.reward} Kč'),
                  trailing: store.role == MansionRole.hand
                      ? FilledButton(
                          onPressed: () => store.approveCard(card),
                          child: const Text('Schválit'),
                        )
                      : const Icon(Icons.hourglass_top),
                ),
              ),
            ),
          ),
        ],
        const _SectionTitle('PROFIL'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(store.nickname),
              subtitle: Text('Role: ${store.role.label}'),
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
