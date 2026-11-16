import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'gangs_screens.dart';
import 'mansion_store.dart';
import 'models.dart';
import 'update_checker.dart';

void main() => runApp(const GrimGrindApp());

class GrimGrindApp extends StatefulWidget {
  const GrimGrindApp({super.key, this.store, this.updateService});

  final MansionStore? store;
  final DistributionUpdateService? updateService;

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
      home: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          if (!store.isReady) {
            return OnboardingFlow(store: store);
          }
          return MansionShell(
            store: store,
            updateService: widget.updateService,
          );
        },
      ),
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
      borderRadius: BorderRadius.all(Radius.circular(10)),
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

Color _difficultyColor(ChoreDifficulty difficulty) => switch (difficulty) {
  ChoreDifficulty.easy => const Color(0xFF66816A),
  ChoreDifficulty.medium => const Color(0xFFC6A15B),
  ChoreDifficulty.hard => const Color(0xFF9B3B48),
  ChoreDifficulty.special => const Color(0xFF846BA3),
};

Color _heatColor(HeatLevel heat) => switch (heat) {
  HeatLevel.coldAsh => const Color(0xFF625B53),
  HeatLevel.glowingEmbers => const Color(0xFFD97B29),
  HeatLevel.blazingForge => const Color(0xFFE5A435),
  HeatLevel.hellfire => const Color(0xFFE04826),
};

IconData _heatIcon(HeatLevel heat) => switch (heat) {
  HeatLevel.coldAsh => Icons.ac_unit_outlined,
  HeatLevel.glowingEmbers => Icons.local_fire_department_outlined,
  HeatLevel.blazingForge => Icons.local_fire_department,
  HeatLevel.hellfire => Icons.whatshot,
};

// =============================================================================
// Onboarding: 3 Intro Cards + Create / Join Gang
// =============================================================================

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.store});

  final MansionStore store;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _introIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.store.hasSeenIntro) {
      return _buildIntroPages(context);
    }
    return _GangSetupScreen(store: widget.store);
  }

  Widget _buildIntroPages(BuildContext context) {
    const slides = [
      (
        eyebrow: 'PRAVIDLO I • KNIHA KARET',
        title: 'Sdílený Deck Sídla',
        text:
            'Celá domácnost vybírá ze stejné knihy 17 úkolů. Žádné zamykání ani čekání – jakmile úkol splníš, rovnou kartu zahraješ do společného Feedu.',
        image: 'assets/art/spellbook_deck.png',
      ),
      (
        eyebrow: 'PRAVIDLO II • COINY, LEVEL & HEAT',
        title: 'Žhavé Násobiče Odměn',
        text:
            'Během měsíce sbíráš karty a postupuješ od Probuzeného až k Nesmrtelnému. Pravidelným hraním navíc rozdmýcháš Heat, který chladne při lenošení.',
        image: 'assets/art/mansion.png',
      ),
      (
        eyebrow: 'PRAVIDLO III • RUKA & LEADERBOARD',
        title: 'Směň Bank a Ovládni Sídlo',
        text:
            'Coiny padají do tvého Banku. Kdykoliv požádej Ruku (Zakladatele) o směnu na skutečné peníze. Teprve schválené směny se počítají do Leaderboardu!',
        image: 'assets/art/the_hand_exchange.png',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GRIMGRIND',
                    style: TextStyle(
                      letterSpacing: 3,
                      fontSize: 16,
                      color: Color(0xFFC6A15B),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.store.completeIntro,
                    child: const Text('Přeskočit'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (value) => setState(() => _introIndex = value),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF5A4931),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                slide.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          slide.eyebrow,
                          style: const TextStyle(
                            color: Color(0xFFC6A15B),
                            letterSpacing: 2,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF968C80),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (i) => Container(
                        width: i == _introIndex ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: i == _introIndex
                              ? const Color(0xFFC6A15B)
                              : const Color(0xFF3B3329),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_introIndex < slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOut,
                          );
                        } else {
                          widget.store.completeIntro();
                        }
                      },
                      child: Text(
                        _introIndex < slides.length - 1
                            ? 'Další karta pravidel'
                            : 'Vstoupit do Sídla',
                      ),
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

class _GangSetupScreen extends StatefulWidget {
  const _GangSetupScreen({required this.store});

  final MansionStore store;

  @override
  State<_GangSetupScreen> createState() => _GangSetupScreenState();
}

class _GangSetupScreenState extends State<_GangSetupScreen> {
  bool _createMode = true;
  bool _includeStarterFamily = true;
  MemberSex _selectedSex = MemberSex.male;
  final _gangNameController = TextEditingController(text: 'Sídlo Addamsů');
  final _nicknameController = TextEditingController(text: 'Dark Lord');
  final _rateController = TextEditingController(text: '10');
  late final TextEditingController _inviteCodeController =
      TextEditingController(
        text: widget.store.pendingInviteCode ?? 'GRIM-42',
      );

  @override
  void initState() {
    super.initState();
    if (widget.store.pendingInviteCode != null) {
      _createMode = false;
    }
  }

  @override
  void dispose() {
    _gangNameController.dispose();
    _nicknameController.dispose();
    _rateController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/art/mansion.png',
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ZALOŽENÍ NEBO PŘIPOJENÍ',
              style: TextStyle(
                color: Color(0xFFC6A15B),
                letterSpacing: 2,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            const Text('Vstup do Gangu', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            const Text(
              'Zakládající člen získá roli Ruky (nastavuje kurz Coin → Kč a schvaluje směny) a pozve ostatní přes zvací kód.',
              style: TextStyle(color: Color(0xFF968C80), height: 1.4),
            ),
            const SizedBox(height: 20),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.front_hand_outlined),
                  label: Text('Založit Gang'),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.vpn_key_outlined),
                  label: Text('Mám zvací kód'),
                ),
              ],
              selected: {_createMode},
              onSelectionChanged: (s) => setState(() => _createMode = s.first),
            ),
            const SizedBox(height: 20),
            if (_createMode) ...[
              TextField(
                controller: _gangNameController,
                decoration: const InputDecoration(
                  labelText: 'Název Gangu / Sídla',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Tvoje přezdívka (Zakladatel = Ruka)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              MemberSexSelector(
                selected: _selectedSex,
                onChanged: (sex) => setState(() => _selectedSex = sex),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kurz: kolik Coinů = 1 Kč',
                  helperText: 'Např. 10 znamená, že 1 000 Coinů = 100 Kč',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _includeStarterFamily,
                onChanged: (v) => setState(() => _includeStarterFamily = v),
                title: const Text('Přidat ukázkové členy & historii'),
                subtitle: const Text(
                  'Ideální pro okamžité vyzkoušení Leaderboardu a schvalování směn',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  final rate = int.tryParse(_rateController.text) ?? 10;
                  widget.store.createGang(
                    gangName: _gangNameController.text,
                    founderNickname: _nicknameController.text,
                    founderSex: _selectedSex,
                    coinsPerCzk: rate,
                    includeStarterFamily: _includeStarterFamily,
                  );
                },
                icon: const Icon(Icons.castle_outlined),
                label: const Text('Založit Gang a stát se Rukou'),
              ),
            ] else ...[
              TextField(
                controller: _inviteCodeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Zvací kód Gangu',
                  hintText: 'Např. GRIM-42',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Tvoje temná přezdívka',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              MemberSexSelector(
                selected: _selectedSex,
                onChanged: (sex) => setState(() => _selectedSex = sex),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  final ok = widget.store.joinGangByCode(
                    inviteCode: _inviteCodeController.text,
                    nickname: _nicknameController.text,
                    sex: _selectedSex,
                  );
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Neplatný zvací kód Gangu.')),
                    );
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Připojit se ke Gangu'),
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.store.startSampleMansion,
              child: const Text('Rychlý start s ukázkovým Sídlem'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Main Shell
// =============================================================================

class MansionShell extends StatefulWidget {
  const MansionShell({super.key, required this.store, this.updateService});

  final MansionStore store;
  final DistributionUpdateService? updateService;

  @override
  State<MansionShell> createState() => _MansionShellState();
}

class _MansionShellState extends State<MansionShell> {
  int index = 0;
  late final DistributionUpdateService _updateService =
      widget.updateService ?? DistributionUpdateService();
  UpdateCheckResult? _pendingUpdate;
  bool _updateDismissed = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingInvite());
  }

  Future<void> _checkPendingInvite() async {
    final code = widget.store.pendingInviteCode;
    if (!mounted || code == null) return;
    widget.store.clearPendingInviteCode();
    await showAcceptInviteDialog(context, widget.store, initialCodeOrLink: code);
  }

  Future<void> _checkForUpdates() async {
    final result = await _updateService.checkForUpdate();
    if (!mounted || result == null || !result.isUpdateAvailable) return;
    setState(() {
      _pendingUpdate = result;
      _updateDismissed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final member = store.currentMember!;
    final level = store.monthlyLevelFor(member.id);
    final heat = store.heatLevelFor(member);
    final pendingCount = store.isCurrentUserHand
        ? store.pendingExchanges.length
        : 0;

    final pages = [
      FeedPage(
        store: store,
        onOpenDeck: () => setState(() => index = 1),
      ),
      DeckPage(store: store),
      BankPage(store: store),
      LeaderboardPage(store: store),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              store.gang!.name.toUpperCase(),
              style: const TextStyle(letterSpacing: 2.2, fontSize: 16),
            ),
            Text(
              '${member.nickname} • ${level.label} • ${heat.label}',
              style: const TextStyle(
                color: Color(0xFF968C80),
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sídlo & Přepínač člena',
            icon: Icon(
              member.isHand ? Icons.front_hand : Icons.person_outline,
              color: const Color(0xFFC6A15B),
            ),
            onPressed: () =>
                _showGangSheet(context, store, updateService: _updateService),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_pendingUpdate != null && !_updateDismissed)
              UpdateBanner(
                result: _pendingUpdate!,
                onUpdate: () =>
                    _updateService.openUpdateUrl(_pendingUpdate!.info),
                onDismiss: () => setState(() => _updateDismissed = true),
              ),
            Expanded(
              child: IndexedStack(index: index, children: pages),
            ),
          ],
        ),
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF6E1830),
              foregroundColor: const Color(0xFFF7EEE0),
              onPressed: () => setState(() => index = 1),
              icon: const Icon(Icons.auto_stories),
              label: const Text('Zahrát kartu'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dynamic_feed_outlined),
            selectedIcon: Icon(Icons.dynamic_feed),
            label: 'Feed',
          ),
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Deck',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.savings_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.savings),
            ),
            label: 'Bank',
          ),
          const NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Žebříček',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 1. Main Feed (Instagram-style stream with Month Proclamation Dividers)
// =============================================================================

class FeedPage extends StatelessWidget {
  const FeedPage({
    super.key,
    required this.store,
    required this.onOpenDeck,
  });

  final MansionStore store;
  final VoidCallback onOpenDeck;

  @override
  Widget build(BuildContext context) {
    final entries = store.feedEntries;
    final member = store.currentMember!;
    final level = store.monthlyLevelFor(member.id);
    final heat = store.heatLevelFor(member);
    final bankCoins = store.bankCoinsFor(member.id);

    return CustomScrollView(
      key: const PageStorageKey('feed'),
      slivers: [
        SliverToBoxAdapter(
          child: _FeedStatusStrip(
            member: member,
            level: level,
            heat: heat,
            bankCoins: bankCoins,
            czkValue: store.czkForCoins(bankCoins),
            onOpenDeck: onOpenDeck,
          ),
        ),
        if (entries.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.dynamic_feed_outlined,
              title: 'Kronika sídla mlčí',
              text: 'Otevři Deck a zahraj první kartu úkolu.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            sliver: SliverList.separated(
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final entry = entries[i];
                return switch (entry.type) {
                  FeedEntryType.cardPlayed => _FeedPlayedCardPost(entry: entry),
                  FeedEntryType.exchangeApproved => _FeedExchangePost(
                    entry: entry,
                  ),
                  FeedEntryType.monthProclamation => _FeedMonthDividerCard(
                    entry: entry,
                  ),
                };
              },
            ),
          ),
      ],
    );
  }
}

class _FeedStatusStrip extends StatelessWidget {
  const _FeedStatusStrip({
    required this.member,
    required this.level,
    required this.heat,
    required this.bankCoins,
    required this.czkValue,
    required this.onOpenDeck,
  });

  final GangMember member;
  final MonthlyLevel level;
  final HeatLevel heat;
  final int bankCoins;
  final int czkValue;
  final VoidCallback onOpenDeck;

  @override
  Widget build(BuildContext context) {
    final totalBonus = level.bonusPercent + heat.bonusPercent;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF17171A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _heatColor(heat).withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: [
          Icon(_heatIcon(heat), color: _heatColor(heat), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${level.label} (${level.utCallout}) • +$totalBonus %',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC6A15B),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'V Banku: $bankCoins Coinů (~$czkValue Kč)',
                  style: const TextStyle(
                    color: Color(0xFF968C80),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onOpenDeck,
            child: const Text('Deck'),
          ),
        ],
      ),
    );
  }
}

class _FeedPlayedCardPost extends StatelessWidget {
  const _FeedPlayedCardPost({required this.entry});

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
                  backgroundColor: _heatColor(heat).withValues(alpha: 0.2),
                  child: Icon(
                    _heatIcon(heat),
                    size: 18,
                    color: _heatColor(heat),
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
                  child: Text(
                    '+${entry.coins ?? 0} Coinů',
                    style: const TextStyle(
                      color: Color(0xFFC6A15B),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
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
                    'assets/cards/${entry.choreId}.png',
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

class _FeedExchangePost extends StatelessWidget {
  const _FeedExchangePost({required this.entry});

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
                  'assets/art/the_hand_exchange.png',
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
                      Text(
                        '${entry.coins ?? 0} Coinů → ${entry.czkAmount ?? 0} Kč',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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

class _FeedMonthDividerCard extends StatelessWidget {
  const _FeedMonthDividerCard({required this.entry});

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
                      'assets/art/month_trophy.png',
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

// =============================================================================
// 2. Deck View (Shared Spellbook of 17 Cards with Live Coin Values)
// =============================================================================

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
                const Text(
                  'KNIHA KARET SÍDLA',
                  style: TextStyle(
                    color: Color(0xFFC6A15B),
                    letterSpacing: 2,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Vyber splněnou kartu',
                  style: TextStyle(fontSize: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  'Level ${level.label} (+${level.bonusPercent} %) • ${heat.label} (+${heat.bonusPercent} %) = celkem +$totalBonus % Coinů.',
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
                        label: const Text('Všechny (17)'),
                        selected: _filter == null,
                        onSelected: (_) => setState(() => _filter = null),
                      ),
                      const SizedBox(width: 8),
                      for (final diff in ChoreDifficulty.values) ...[
                        FilterChip(
                          label: Text(diff.label),
                          selected: _filter == diff,
                          onSelected: (_) => setState(() => _filter = diff),
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
                onTap: () => _confirmPlayCard(context, store, chore, coins),
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
    final accent = _difficultyColor(chore.difficulty);
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
                      chore.symbol,
                      style: TextStyle(fontSize: 22, color: accent),
                    ),
                    Text(
                      chore.difficulty.label.toUpperCase(),
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
                      'assets/cards/${chore.id}.png',
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
                    const Icon(
                      Icons.toll,
                      size: 16,
                      color: Color(0xFFC6A15B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$effectiveCoins C',
                      style: const TextStyle(
                        color: Color(0xFFC6A15B),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
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
                'assets/cards/${chore.id}.png',
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
                  child: _StatTile(
                    icon: Icons.schedule,
                    value: '${chore.minutes} min',
                    label: 'ODHAD',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Icons.toll,
                    value: '$effectiveCoins Coinů',
                    label: 'ZISK DO BANKU',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Icons.payments_outlined,
                    value: '~${store.czkForCoins(effectiveCoins)} Kč',
                    label: 'ORIENTAČNĚ',
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
                label: Text('Zahrát kartu (+$effectiveCoins Coinů)'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Zahráno! +${played.coinsAwarded} Coinů připsáno do tvého Banku.',
          ),
        ),
      );
    }
  }
}

// =============================================================================
// 3. Bank & Hand Exchange Approval View
// =============================================================================

class BankPage extends StatelessWidget {
  const BankPage({super.key, required this.store});

  final MansionStore store;

  @override
  Widget build(BuildContext context) {
    final member = store.currentMember!;
    final bankCards = store.bankCardsFor(member.id);
    final pendingMine = store.pendingCardsFor(member.id);
    final bankCoins = store.bankCoinsFor(member.id);
    final czk = store.czkForCoins(bankCoins);
    final gang = store.gang!;

    return ListView(
      key: const PageStorageKey('bank'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        const Text(
          'TVŮJ POKLAD',
          style: TextStyle(
            color: Color(0xFFC6A15B),
            letterSpacing: 2,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        const Text('Bank & Směna u Ruky', style: TextStyle(fontSize: 26)),
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
              Text(
                '$bankCoins Coinů',
                style: const TextStyle(
                  fontSize: 38,
                  color: Color(0xFFC6A15B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '≈ $czk Kč (kurz ${gang.coinsPerCzk} Coinů = 1 Kč)',
                style: const TextStyle(color: Color(0xFF968C80)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: bankCards.isEmpty
                      ? null
                      : () {
                          final req = store.requestExchange();
                          if (req != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Žádost o směnu ${req.totalCoins} Coinů (${req.czkAmount} Kč) odeslána Ruce.',
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.front_hand_outlined),
                  label: Text(
                    bankCards.isEmpty
                        ? 'Bank je prázdný'
                        : 'Požádat Ruku o směnu (${bankCards.length})',
                  ),
                ),
              ),
            ],
          ),
        ),
        if (bankCards.isNotEmpty) ...[
          const _SectionTitle('ZAHRANÉ KARTY V BANKU'),
          ...bankCards.map(
            (card) => Card(
              child: ListTile(
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
                subtitle: Text(
                  DateFormat('d. M. • HH:mm').format(card.playedAt),
                ),
                trailing: Text(
                  '+${card.coinsAwarded} C',
                  style: const TextStyle(
                    color: Color(0xFFC6A15B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
        if (pendingMine.isNotEmpty) ...[
          const _SectionTitle('MOJE KARTY ČEKAJÍCÍ NA POTVRZENÍ RUKOU'),
          ...pendingMine.map(
            (card) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.hourglass_top,
                  color: Color(0xFFC6A15B),
                ),
                title: Text(card.chore.title),
                trailing: Text('${card.coinsAwarded} C'),
              ),
            ),
          ),
        ],
        if (store.isCurrentUserHand) ...[
          const Divider(height: 36),
          const _SectionTitle('SPRÁVA RUKY (ZAKLADATEL)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Aktuální směnný kurz',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('${gang.coinsPerCzk} Coinů = 1 Kč'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final rate in [5, 10, 20, 50])
                        ChoiceChip(
                          label: Text('$rate C / 1 Kč'),
                          selected: gang.coinsPerCzk == rate,
                          onSelected: (_) => store.updateCoinsPerCzk(rate),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final created = store.closeMonth();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Měsíc uzavřen! Vygenerováno $created automatických žádostí o směnu.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.event_available),
                      label: const Text('Uzavřít měsíc (Auto-směna & Výherce)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (store.pendingExchanges.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text('Žádné čekající žádosti o směnu'),
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
                Text(
                  '${req.totalCoins} C → ${req.czkAmount} Kč',
                  style: const TextStyle(
                    color: Color(0xFFC6A15B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (req.isAutoMonthEnd)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Automatická uzávěrka měsíce',
                  style: TextStyle(color: Color(0xFF968C80), fontSize: 11),
                ),
              ),
            const Divider(),
            ...cards.map(
              (c) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(c.chore.title),
                subtitle: Text('${c.coinsAwarded} Coinů'),
                trailing: IconButton(
                  tooltip: 'Neuznat kartu',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => store.rejectCardInRequest(req.id, c.id),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => store.approveExchange(req.id),
                icon: const Icon(Icons.verified_outlined),
                label: Text('Schválit směnu (${req.czkAmount} Kč)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 4. Leaderboard (Collectible Player Cards with Heat Aura)
// =============================================================================

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
    final rows = widget.store.buildLeaderboard(period: _period, sort: _sort);
    return ListView(
      key: const PageStorageKey('leaderboard'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        const Text(
          'SÍŇ HRDINŮ SÍDLA',
          style: TextStyle(
            color: Color(0xFFC6A15B),
            letterSpacing: 2,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        const Text('Leaderboard Hráčů', style: TextStyle(fontSize: 26)),
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
    final auraColor = _heatColor(data.heatLevel);
    final auraGlow = switch (data.heatLevel) {
      HeatLevel.coldAsh => 0.0,
      HeatLevel.glowingEmbers => 12.0,
      HeatLevel.blazingForge => 20.0,
      HeatLevel.hellfire => 28.0,
    };

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
                  _heatIcon(data.heatLevel),
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
            Text(
              'V Banku čeká na směnu: ${data.inBankCount} karet (${data.inBankCoins} Coinů)',
              style: const TextStyle(color: Color(0xFF968C80), fontSize: 11),
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

// =============================================================================
// Gang & Profile Sheet (Switch active member, invite code, rename)
// =============================================================================

Future<void> _showGangSheet(
  BuildContext context,
  MansionStore store, {
  DistributionUpdateService? updateService,
}) async {
  final renameController = TextEditingController(
    text: store.currentMember?.nickname ?? '',
  );
  final addController = TextEditingController();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF111114),
    builder: (context) => SafeArea(
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final gang = store.gang!;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gang.name,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Zvací kód pro členy Gangu: ${gang.inviteCode}',
                    style: const TextStyle(color: Color(0xFFC6A15B)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => MyGangsPage(store: store),
                              ),
                            );
                          },
                          icon: const Icon(Icons.groups_outlined),
                          label: const Text('Moje Gangy'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ManageGangPage(
                                  store: store,
                                  gangId: gang.id,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Pozvat / Správa'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PŘEPNOUT ČLENA (TEST / DOMÁCNOST)',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.6,
                      color: Color(0xFF968C80),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...store.members.map(
                    (m) {
                      final selected = m.id == store.currentMemberId;
                      return ListTile(
                        leading: Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? const Color(0xFFC6A15B)
                              : const Color(0xFF968C80),
                        ),
                        title: Text(m.nickname),
                        subtitle: Text(
                          m.isHand ? 'Zakladatel • Ruka' : 'Člen Gangu',
                        ),
                        onTap: () {
                          store.switchActiveMember(m.id);
                          renameController.text =
                              store.currentMember?.nickname ?? '';
                        },
                      );
                    },
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: renameController,
                          decoration: const InputDecoration(
                            labelText: 'Změnit moji přezdívku',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () =>
                            store.renameCurrentMember(renameController.text),
                        child: const Text('Uložit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: addController,
                          decoration: const InputDecoration(
                            labelText: 'Pozvat / přidat nového člena',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          store.addMember(addController.text);
                          addController.clear();
                        },
                        child: const Text('Přidat'),
                      ),
                    ],
                  ),
                  if (updateService != null) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.system_update_alt,
                        color: Color(0xFFC6A15B),
                      ),
                      title: const Text('Aktualizace aplikace'),
                      subtitle: FutureBuilder<({String version, int buildNumber})>(
                        future: updateService.currentAppVersion(),
                        builder: (context, snapshot) {
                          final v = snapshot.data;
                          return Text(
                            v == null
                                ? 'Zkontrolovat novou verzi'
                                : 'Aktuální verze ${v.version} (#${v.buildNumber})',
                          );
                        },
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final nav = Navigator.of(context);
                        final result = await updateService.checkForUpdate();
                        if (result != null && result.isUpdateAvailable) {
                          nav.pop();
                          await updateService.openUpdateUrl(result.info);
                        } else {
                          nav.pop();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Máš nejnovější dostupnou verzi.'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  renameController.dispose();
  addController.dispose();
}

// =============================================================================
// Shared Widgets
// =============================================================================

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
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF3B3329)),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Column(
      children: [
        Icon(icon, size: 19, color: const Color(0xFFC6A15B)),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 3),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
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
