import 'package:flutter/material.dart';

import '../../app_strings.dart';
import '../../gangs_screens.dart';
import '../../mansion_store.dart';
import '../../sound_service.dart';
import '../../theme_package.dart';
import '../../update_checker.dart';
import '../chronicle/chronicle_page.dart';
import '../deck/deck_page.dart';
import '../leaderboard/leaderboard_page.dart';
import '../pouch/pouch_page.dart';
import 'mansion_page.dart';

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
  bool _isHandlingPendingEvents = false;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreChanged);
    _checkForUpdates();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingEvents());
  }

  @override
  void didUpdateWidget(covariant MansionShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store != widget.store) {
      oldWidget.store.removeListener(_onStoreChanged);
      widget.store.addListener(_onStoreChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingEvents());
    }
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (!mounted) return;
    if (widget.store.pendingWelcomeMansionName != null ||
        widget.store.pendingInviteCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingEvents());
    }
  }

  Future<void> _checkPendingEvents() async {
    if (!mounted || _isHandlingPendingEvents) return;
    _isHandlingPendingEvents = true;
    try {
      final welcomeName = widget.store.consumePendingWelcomeMansionName();
      if (welcomeName != null && mounted) {
        await _showWelcomeDialog(welcomeName);
      }

      final code = widget.store.pendingInviteCode;
      if (mounted && code != null) {
        widget.store.clearPendingInviteCode();
        await showAcceptInviteDialog(
          context,
          widget.store,
          initialCodeOrLink: code,
        );
      }
    } finally {
      _isHandlingPendingEvents = false;
    }
  }

  Future<void> _showWelcomeDialog(String mansionName) async {
    final s = AppStrings.of(context);
    final theme = ThemeScope.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.castle_outlined, color: theme.primaryAccent, size: 36),
        title: Text(s.welcomeToMansionTitle, textAlign: TextAlign.center),
        content: Text(
          s.welcomeToMansionBody(mansionName),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.welcomeToMansionConfirmBtn),
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    final result = await _updateService.checkForUpdate();
    if (!mounted || result == null || !result.isUpdateAvailable) return;
    setState(() {
      _pendingUpdate = result;
      _updateDismissed = false;
    });
  }

  void _openDeck() {
    SoundService.instance.playOpenDeck();
    final s = AppStrings.of(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(s.deckTitle)),
          body: SafeArea(child: DeckPage(store: widget.store)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final theme = ThemeScope.of(context);
    final s = AppStrings.of(context);
    final member = store.currentMember!;
    final level = store.monthlyLevelFor(member.id);
    final heat = store.heatLevelFor(member);
    final pendingCount = store.isCurrentUserHand
        ? store.pendingExchanges.length
        : 0;

    final pages = [
      ChroniclePage(
        store: store,
        onOpenDeck: _openDeck,
      ),
      PouchPage(store: store),
      LeaderboardPage(store: store),
      MansionPage(
        store: store,
        updateService: _updateService,
        pendingUpdate: _pendingUpdate,
      ),
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
              '${member.nickname} • ${s.monthlyLevelLabel(level, theme)} • ${s.heatLabel(heat, theme)}',
              style: const TextStyle(
                color: Color(0xFF968C80),
                fontSize: 11,
              ),
            ),
          ],
        ),
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
              onPressed: _openDeck,
              icon: const Icon(Icons.auto_stories),
              label: Text(s.playCardFab),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: withButtonSound1(
          (value) => setState(() => index = value),
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dynamic_feed_outlined),
            selectedIcon: const Icon(Icons.dynamic_feed),
            label: s.navChronicle,
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
            label: s.navPouch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events),
            label: s.navLeaderboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.castle_outlined),
            selectedIcon: const Icon(Icons.castle),
            label: s.navMansion,
          ),
        ],
      ),
    );
  }
}
