import 'package:flutter/foundation.dart';

import 'models.dart';

class MansionStore extends ChangeNotifier {
  MansionStore({DateTime Function()? clock, bool seedDemo = false})
    : _clock = clock ?? DateTime.now {
    if (seedDemo) {
      _seedSampleMansion();
    }
  }

  final DateTime Function() _clock;
  int _idSeq = 100;

  bool hasSeenIntro = false;
  Gang? gang;
  String? currentMemberId;

  final List<GangMember> members = [];
  final List<PlayedCard> playedCards = [];
  final List<ExchangeRequest> exchangeRequests = [];
  final List<FeedEntry> feedEntries = [];

  List<ChoreDefinition> get deck => choreCatalog;

  bool get isReady => gang != null && currentMember != null;

  GangMember? get currentMember {
    final id = currentMemberId;
    if (id == null) return null;
    for (final member in members) {
      if (member.id == id) return member;
    }
    return null;
  }

  bool get isCurrentUserHand => currentMember?.isHand ?? false;

  String monthKeyFor(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}';

  String get currentMonthKey => monthKeyFor(_clock());

  String get previousMonthKey {
    final now = _clock();
    final prev = DateTime(now.year, now.month - 1, 1);
    return monthKeyFor(prev);
  }

  String _nextId(String prefix) => '$prefix-${++_idSeq}';

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // ---------------------------------------------------------------------------
  // Onboarding & Gang lifecycle
  // ---------------------------------------------------------------------------

  void completeIntro() {
    if (hasSeenIntro) return;
    hasSeenIntro = true;
    notifyListeners();
  }

  void createGang({
    required String gangName,
    required String founderNickname,
    int coinsPerCzk = 10,
    bool includeStarterFamily = false,
  }) {
    final cleanGang = gangName.trim().isEmpty
        ? 'Sídlo stínů'
        : gangName.trim();
    final cleanNick = founderNickname.trim().isEmpty
        ? 'Dark Lord'
        : founderNickname.trim();
    final now = _clock();
    final founder = GangMember(
      id: _nextId('member'),
      nickname: cleanNick,
      isHand: true,
    );

    members
      ..clear()
      ..add(founder);
    playedCards.clear();
    exchangeRequests.clear();
    feedEntries.clear();

    gang = Gang(
      id: _nextId('gang'),
      name: cleanGang,
      inviteCode: 'GRIM-${10 + (now.minute + now.second) % 89}',
      founderId: founder.id,
      coinsPerCzk: coinsPerCzk.clamp(1, 1000),
    );
    currentMemberId = founder.id;
    hasSeenIntro = true;

    if (includeStarterFamily) {
      _populateGangWithSampleHistory(founder);
    }
    notifyListeners();
  }

  bool joinGangByCode({
    required String inviteCode,
    required String nickname,
  }) {
    final cleanCode = inviteCode.trim().toUpperCase();
    final cleanNick = nickname.trim().isEmpty ? 'Shadow' : nickname.trim();
    if (cleanCode.isEmpty) return false;

    if (gang == null) {
      // Allow local/offline joining into a demo mansion when user enters a code.
      _seedSampleMansion(overrideInviteCode: cleanCode);
    } else if (gang!.inviteCode.toUpperCase() != cleanCode) {
      return false;
    }

    final existing = members.where(
      (m) => m.nickname.toLowerCase() == cleanNick.toLowerCase(),
    );
    if (existing.isNotEmpty) {
      currentMemberId = existing.first.id;
    } else {
      final newcomer = GangMember(
        id: _nextId('member'),
        nickname: cleanNick,
        isHand: false,
      );
      members.add(newcomer);
      currentMemberId = newcomer.id;
    }
    hasSeenIntro = true;
    notifyListeners();
    return true;
  }

  void startSampleMansion() {
    _seedSampleMansion();
    notifyListeners();
  }

  void addMember(String nickname, {bool isHand = false}) {
    final clean = nickname.trim();
    if (clean.isEmpty || gang == null) return;
    members.add(
      GangMember(id: _nextId('member'), nickname: clean, isHand: isHand),
    );
    notifyListeners();
  }

  void switchActiveMember(String memberId) {
    if (!members.any((m) => m.id == memberId)) return;
    currentMemberId = memberId;
    notifyListeners();
  }

  void renameCurrentMember(String value) {
    final member = currentMember;
    final clean = value.trim();
    if (member == null || clean.isEmpty || clean == member.nickname) return;
    member.nickname = clean;
    for (final card in playedCards.where((c) => c.memberId == member.id)) {
      card.memberNickname = clean;
    }
    for (final req in exchangeRequests.where((r) => r.memberId == member.id)) {
      req.memberNickname = clean;
    }
    notifyListeners();
  }

  void updateCoinsPerCzk(int coinsPerCzk) {
    if (!isCurrentUserHand || gang == null) return;
    gang!.coinsPerCzk = coinsPerCzk.clamp(1, 1000);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Monthly Level & Cooling Heat calculations
  // ---------------------------------------------------------------------------

  int playedCardCountInMonth(String memberId, String monthKey) => playedCards
      .where(
        (c) =>
            c.memberId == memberId &&
            c.monthKey == monthKey &&
            c.status != PlayedCardStatus.rejected,
      )
      .length;

  MonthlyLevel monthlyLevelFor(String memberId, {String? monthKey}) {
    final key = monthKey ?? currentMonthKey;
    return MonthlyLevelData.fromCardCount(
      playedCardCountInMonth(memberId, key),
    );
  }

  HeatLevel heatLevelFor(GangMember member, {DateTime? at}) {
    final last = member.lastActiveDay;
    if (last == null || member.heatPeakDays <= 0) {
      return HeatLevel.coldAsh;
    }
    final nowDay = _dateOnly(at ?? _clock());
    final gap = nowDay.difference(_dateOnly(last)).inDays;

    HeatLevel rawHeat;
    if (member.heatPeakDays >= 7) {
      rawHeat = HeatLevel.hellfire;
    } else if (member.heatPeakDays >= 4) {
      rawHeat = HeatLevel.blazingForge;
    } else if (member.heatPeakDays >= 2) {
      rawHeat = HeatLevel.glowingEmbers;
    } else {
      rawHeat = HeatLevel.coldAsh;
    }

    if (gap <= 0) return rawHeat;

    if (rawHeat == HeatLevel.hellfire) {
      if (gap <= 1) return HeatLevel.hellfire;
      if (gap <= 3) return HeatLevel.blazingForge;
      return HeatLevel.coldAsh;
    }

    if (gap <= 3) return rawHeat;
    return HeatLevel.coldAsh;
  }

  int streakDaysFor(GangMember member, {DateTime? at}) {
    final heat = heatLevelFor(member, at: at);
    if (heat == HeatLevel.coldAsh) {
      final last = member.lastActiveDay;
      if (last == null) return 0;
      final gap = _dateOnly(at ?? _clock()).difference(_dateOnly(last)).inDays;
      return gap <= 3 ? member.heatPeakDays : 0;
    }
    return member.heatPeakDays;
  }

  int effectiveCoinsFor(ChoreDefinition chore, GangMember member) {
    final level = monthlyLevelFor(member.id);
    final heat = heatLevelFor(member);
    final multiplier = 1.0 + level.bonusRate + heat.bonusRate;
    return (chore.baseCoins * multiplier).round();
  }

  int czkForCoins(int coins) {
    final rate = gang?.coinsPerCzk ?? 10;
    return (coins / rate).round();
  }

  // ---------------------------------------------------------------------------
  // Playing Cards, Bank, Exchange Requests & Month Closing
  // ---------------------------------------------------------------------------

  PlayedCard? playCard(ChoreDefinition chore) {
    final member = currentMember;
    if (member == null || gang == null) return null;

    final now = _clock();
    final coins = effectiveCoinsFor(chore, member);
    final level = monthlyLevelFor(member.id);
    final heat = heatLevelFor(member, at: now);

    final played = PlayedCard(
      id: _nextId('card'),
      chore: chore,
      memberId: member.id,
      memberNickname: member.nickname,
      coinsAwarded: coins,
      playedAt: now,
      monthKey: monthKeyFor(now),
      levelAtPlay: level,
      heatAtPlay: heat,
      status: PlayedCardStatus.inBank,
    );
    playedCards.add(played);
    _recordActivityForHeat(member, now);

    feedEntries.insert(
      0,
      FeedEntry(
        id: _nextId('feed'),
        type: FeedEntryType.cardPlayed,
        actorNickname: member.nickname,
        title: chore.title,
        message: 'zahrál kartu „${chore.title}“ a uložil $coins Coinů do Banku.',
        createdAt: now,
        monthKey: played.monthKey,
        choreId: chore.id,
        symbol: chore.symbol,
        coins: coins,
        levelAtEvent: monthlyLevelFor(member.id),
        heatAtEvent: heatLevelFor(member, at: now),
      ),
    );

    notifyListeners();
    return played;
  }

  void _recordActivityForHeat(GangMember member, DateTime at) {
    final today = _dateOnly(at);
    final last = member.lastActiveDay;
    if (last == null) {
      member
        ..heatPeakDays = 1
        ..lastActiveDay = today;
      return;
    }

    final gap = today.difference(_dateOnly(last)).inDays;
    if (gap <= 0) {
      return;
    }

    final currentHeat = heatLevelFor(member, at: at);
    if (currentHeat == HeatLevel.coldAsh) {
      member.heatPeakDays = gap <= 3 ? member.heatPeakDays + 1 : 1;
    } else if (member.heatPeakDays >= 7 && gap >= 2 && gap <= 3) {
      // Dropped from Hellfire to Blazing Forge; resume progression from Forge tier.
      member.heatPeakDays = 5;
    } else {
      member.heatPeakDays += 1;
    }
    member.lastActiveDay = today;
  }

  List<PlayedCard> bankCardsFor(String memberId) => playedCards
      .where(
        (c) => c.memberId == memberId && c.status == PlayedCardStatus.inBank,
      )
      .toList();

  List<PlayedCard> pendingCardsFor(String memberId) => playedCards
      .where(
        (c) =>
            c.memberId == memberId &&
            c.status == PlayedCardStatus.pendingExchange,
      )
      .toList();

  int bankCoinsFor(String memberId) =>
      bankCardsFor(memberId).fold(0, (sum, c) => sum + c.coinsAwarded);

  List<ExchangeRequest> get pendingExchanges =>
      exchangeRequests
          .where((r) => r.status == ExchangeStatus.pending)
          .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

  ExchangeRequest? requestExchange({
    String? memberId,
    bool isAutoMonthEnd = false,
  }) {
    final targetId = memberId ?? currentMemberId;
    if (targetId == null || gang == null) return null;

    GangMember? targetMember;
    for (final m in members) {
      if (m.id == targetId) {
        targetMember = m;
        break;
      }
    }
    if (targetMember == null) return null;

    final cards = bankCardsFor(targetId);
    if (cards.isEmpty) return null;

    final now = _clock();
    final totalCoins = cards.fold(0, (sum, c) => sum + c.coinsAwarded);
    final req = ExchangeRequest(
      id: _nextId('ex'),
      memberId: targetMember.id,
      memberNickname: targetMember.nickname,
      cardIds: cards.map((c) => c.id).toList(),
      totalCoins: totalCoins,
      coinsPerCzk: gang!.coinsPerCzk,
      requestedAt: now,
      monthKey: cards.first.monthKey,
      isAutoMonthEnd: isAutoMonthEnd,
    );

    for (final c in cards) {
      c
        ..status = PlayedCardStatus.pendingExchange
        ..exchangeId = req.id;
    }
    exchangeRequests.add(req);
    notifyListeners();
    return req;
  }

  bool rejectCardInRequest(String requestId, String cardId) {
    if (!isCurrentUserHand) return false;
    final reqIndex = exchangeRequests.indexWhere((r) => r.id == requestId);
    if (reqIndex < 0) return false;
    final req = exchangeRequests[reqIndex];
    if (req.status != ExchangeStatus.pending) return false;

    final cardIndex = playedCards.indexWhere((c) => c.id == cardId);
    if (cardIndex < 0) return false;
    final card = playedCards[cardIndex];
    if (card.exchangeId != req.id) return false;

    card.status = PlayedCardStatus.rejected;
    req.cardIds.remove(cardId);
    req.totalCoins = req.cardIds.fold(0, (sum, id) {
      final found = playedCards.firstWhere((c) => c.id == id);
      return sum + found.coinsAwarded;
    });

    if (req.cardIds.isEmpty) {
      exchangeRequests.removeAt(reqIndex);
    }
    notifyListeners();
    return true;
  }

  bool approveExchange(String requestId) {
    final hand = currentMember;
    if (hand == null || !hand.isHand) return false;

    ExchangeRequest? req;
    for (final r in exchangeRequests) {
      if (r.id == requestId) {
        req = r;
        break;
      }
    }
    if (req == null || req.status != ExchangeStatus.pending) return false;

    final now = _clock();
    final approvedCards = playedCards
        .where(
          (c) =>
              req!.cardIds.contains(c.id) &&
              c.status == PlayedCardStatus.pendingExchange,
        )
        .toList();

    for (final c in approvedCards) {
      c
        ..status = PlayedCardStatus.exchanged
        ..exchangedAt = now;
    }

    req
      ..status = ExchangeStatus.approved
      ..approvedAt = now
      ..approvedByNickname = hand.nickname
      ..totalCoins = approvedCards.fold(0, (sum, c) => sum + c.coinsAwarded);

    feedEntries.insert(
      0,
      FeedEntry(
        id: _nextId('feed'),
        type: FeedEntryType.exchangeApproved,
        actorNickname: req.memberNickname,
        title: 'Směna schválena Rukou',
        message:
            '${req.memberNickname} směnili ${approvedCards.length} karet za ${req.totalCoins} Coinů (${req.czkAmount} Kč).',
        createdAt: now,
        monthKey: req.monthKey,
        symbol: '☞',
        coins: req.totalCoins,
        czkAmount: req.czkAmount,
        cardCount: approvedCards.length,
      ),
    );

    notifyListeners();
    return true;
  }

  /// Closes the specified (or current) month:
  /// 1. Automatically converts all remaining Bank cards into pending exchange requests.
  /// 2. Inserts a visual Month Proclamation divider card into the Feed.
  /// 3. Monthly levels reset naturally because they are computed per monthKey.
  int closeMonth({String? monthKey}) {
    if (!isCurrentUserHand) return 0;
    final key = monthKey ?? currentMonthKey;
    final now = _clock();

    var createdRequests = 0;
    for (final member in members) {
      final hasBankInMonth = playedCards.any(
        (c) =>
            c.memberId == member.id &&
            c.monthKey == key &&
            c.status == PlayedCardStatus.inBank,
      );
      if (hasBankInMonth) {
        final req = requestExchange(memberId: member.id, isAutoMonthEnd: true);
        if (req != null) createdRequests++;
      }
    }

    final board = buildLeaderboard(
      period: LeaderboardPeriod.allTime,
      sort: LeaderboardSort.mostHardWorking,
      explicitMonthKey: key,
    );
    final winner = board.isNotEmpty && board.first.approvedCoins > 0
        ? board.first
        : null;

    feedEntries.insert(
      0,
      FeedEntry(
        id: _nextId('feed'),
        type: FeedEntryType.monthProclamation,
        actorNickname: 'Ruka sídla',
        title: 'Měsíční vyhlášení • $key',
        message: winner == null
            ? 'Měsíc $key byl uzavřen. Levely se s novým měsícem resetují na Probuzený.'
            : 'Vládcem měsíce $key se stává ${winner.member.nickname} (${winner.approvedCoins} Coinů, ${winner.approvedTaskCount} úkolů).',
        createdAt: now,
        monthKey: key,
        symbol: '♛',
        coins: winner?.approvedCoins,
        cardCount: winner?.approvedTaskCount,
        winnerNickname: winner?.member.nickname,
      ),
    );

    notifyListeners();
    return createdRequests;
  }

  // ---------------------------------------------------------------------------
  // Leaderboard (Approved exchanges only!)
  // ---------------------------------------------------------------------------

  List<PlayerLeaderboardCardData> buildLeaderboard({
    required LeaderboardPeriod period,
    required LeaderboardSort sort,
    String? explicitMonthKey,
  }) {
    final targetMonth = switch (period) {
      LeaderboardPeriod.currentMonth => explicitMonthKey ?? currentMonthKey,
      LeaderboardPeriod.previousMonth => previousMonthKey,
      LeaderboardPeriod.allTime => explicitMonthKey,
    };

    final now = _clock();
    final list = members.map((member) {
      final approved = playedCards.where((c) {
        if (c.memberId != member.id) return false;
        if (c.status != PlayedCardStatus.exchanged) return false;
        if (targetMonth != null && c.monthKey != targetMonth) return false;
        return true;
      }).toList();

      final inBank = bankCardsFor(member.id);

      return PlayerLeaderboardCardData(
        member: member,
        monthlyLevel: monthlyLevelFor(
          member.id,
          monthKey: targetMonth ?? currentMonthKey,
        ),
        heatLevel: heatLevelFor(member, at: now),
        streakDays: streakDaysFor(member, at: now),
        approvedTaskCount: approved.length,
        approvedCoins: approved.fold(0, (sum, c) => sum + c.coinsAwarded),
        approvedMinutes: approved.fold(0, (sum, c) => sum + c.chore.minutes),
        inBankCoins: inBank.fold(0, (sum, c) => sum + c.coinsAwarded),
        inBankCount: inBank.length,
      );
    }).toList();

    list.sort((a, b) {
      final cmp = switch (sort) {
        LeaderboardSort.mostActive => b.approvedTaskCount.compareTo(
          a.approvedTaskCount,
        ),
        LeaderboardSort.mostHardWorking => b.approvedCoins.compareTo(
          a.approvedCoins,
        ),
        LeaderboardSort.byStreakLevel => _compareByHeat(a, b),
      };
      if (cmp != 0) return cmp;
      return b.approvedCoins.compareTo(a.approvedCoins);
    });
    return list;
  }

  int _compareByHeat(PlayerLeaderboardCardData a, PlayerLeaderboardCardData b) {
    final heatCmp = b.heatLevel.index.compareTo(a.heatLevel.index);
    if (heatCmp != 0) return heatCmp;
    return b.streakDays.compareTo(a.streakDays);
  }

  // ---------------------------------------------------------------------------
  // Sample Mansion Seeding
  // ---------------------------------------------------------------------------

  void _seedSampleMansion({String? overrideInviteCode}) {
    final now = _clock();
    final founder = GangMember(
      id: 'member-1',
      nickname: 'Dark Lord',
      isHand: true,
    );
    members
      ..clear()
      ..add(founder);
    playedCards.clear();
    exchangeRequests.clear();
    feedEntries.clear();

    gang = Gang(
      id: 'gang-demo',
      name: 'Sídlo Addamsů',
      inviteCode: overrideInviteCode ?? 'GRIM-42',
      founderId: founder.id,
      coinsPerCzk: 10,
    );
    currentMemberId = founder.id;
    hasSeenIntro = true;

    _populateGangWithSampleHistory(founder, referenceNow: now);
  }

  void _populateGangWithSampleHistory(
    GangMember founder, {
    DateTime? referenceNow,
  }) {
    final now = referenceNow ?? _clock();
    final prevMonth = DateTime(now.year, now.month - 1, 20, 18, 0);
    final prevKey = monthKeyFor(prevMonth);
    final currKey = monthKeyFor(now);

    final queen = GangMember(
      id: _nextId('member'),
      nickname: 'Královna sídla',
      isHand: false,
      heatPeakDays: 7,
      lastActiveDay: _dateOnly(now),
    );
    final shadow = GangMember(
      id: _nextId('member'),
      nickname: 'Shadow Master',
      isHand: false,
      heatPeakDays: 3,
      lastActiveDay: _dateOnly(now.subtract(const Duration(days: 1))),
    );
    founder
      ..heatPeakDays = 4
      ..lastActiveDay = _dateOnly(now);

    members.addAll([queen, shadow]);

    // Previous month approved records + Month Proclamation divider
    final prevCard1 = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[16], // room 1000
      memberId: queen.id,
      memberNickname: queen.nickname,
      coinsAwarded: 1200,
      playedAt: prevMonth,
      monthKey: prevKey,
      levelAtPlay: MonthlyLevel.restlessSpirit,
      heatAtPlay: HeatLevel.glowingEmbers,
      status: PlayedCardStatus.exchanged,
      exchangedAt: prevMonth.add(const Duration(days: 2)),
    );
    final prevCard2 = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[14], // cooking 700
      memberId: founder.id,
      memberNickname: founder.nickname,
      coinsAwarded: 770,
      playedAt: prevMonth.add(const Duration(hours: 3)),
      monthKey: prevKey,
      levelAtPlay: MonthlyLevel.awakened,
      heatAtPlay: HeatLevel.glowingEmbers,
      status: PlayedCardStatus.exchanged,
      exchangedAt: prevMonth.add(const Duration(days: 2)),
    );
    playedCards.addAll([prevCard1, prevCard2]);

    // Current month approved records (count into Leaderboard!)
    final currApproved1 = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[11], // bathroom 600
      memberId: queen.id,
      memberNickname: queen.nickname,
      coinsAwarded: 780,
      playedAt: now.subtract(const Duration(days: 2, hours: 3)),
      monthKey: currKey,
      levelAtPlay: MonthlyLevel.awakened,
      heatAtPlay: HeatLevel.hellfire,
      status: PlayedCardStatus.exchanged,
      exchangedAt: now.subtract(const Duration(days: 1, hours: 5)),
    );
    final currApproved2 = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[5], // queenie 300
      memberId: queen.id,
      memberNickname: queen.nickname,
      coinsAwarded: 390,
      playedAt: now.subtract(const Duration(days: 2)),
      monthKey: currKey,
      levelAtPlay: MonthlyLevel.awakened,
      heatAtPlay: HeatLevel.hellfire,
      status: PlayedCardStatus.exchanged,
      exchangedAt: now.subtract(const Duration(days: 1, hours: 5)),
    );
    final currApproved3 = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[10], // evening 450
      memberId: shadow.id,
      memberNickname: shadow.nickname,
      coinsAwarded: 495,
      playedAt: now.subtract(const Duration(days: 1, hours: 8)),
      monthKey: currKey,
      levelAtPlay: MonthlyLevel.awakened,
      heatAtPlay: HeatLevel.glowingEmbers,
      status: PlayedCardStatus.exchanged,
      exchangedAt: now.subtract(const Duration(hours: 20)),
    );

    // Pending exchange request from Shadow Master for the Hand to approve
    final pendingCard = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[12], // mop 500
      memberId: shadow.id,
      memberNickname: shadow.nickname,
      coinsAwarded: 550,
      playedAt: now.subtract(const Duration(hours: 6)),
      monthKey: currKey,
      levelAtPlay: MonthlyLevel.awakened,
      heatAtPlay: HeatLevel.glowingEmbers,
      status: PlayedCardStatus.pendingExchange,
    );
    final pendingReq = ExchangeRequest(
      id: _nextId('ex'),
      memberId: shadow.id,
      memberNickname: shadow.nickname,
      cardIds: [pendingCard.id],
      totalCoins: pendingCard.coinsAwarded,
      coinsPerCzk: gang!.coinsPerCzk,
      requestedAt: now.subtract(const Duration(hours: 4)),
      monthKey: currKey,
    );
    pendingCard.exchangeId = pendingReq.id;
    exchangeRequests.add(pendingReq);

    // Founder's own card waiting in Bank
    final founderBankCard = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[0], // trash 100
      memberId: founder.id,
      memberNickname: founder.nickname,
      coinsAwarded: 120,
      playedAt: now.subtract(const Duration(hours: 2)),
      monthKey: currKey,
      levelAtPlay: MonthlyLevel.awakened,
      heatAtPlay: HeatLevel.blazingForge,
      status: PlayedCardStatus.inBank,
    );

    playedCards.addAll([
      currApproved1,
      currApproved2,
      currApproved3,
      pendingCard,
      founderBankCard,
    ]);

    // Chronological Feed (newest first) with Month Proclamation divider!
    feedEntries.addAll([
      FeedEntry(
        id: _nextId('feed'),
        type: FeedEntryType.cardPlayed,
        actorNickname: founder.nickname,
        title: founderBankCard.chore.title,
        message:
            'zahrál kartu „${founderBankCard.chore.title}“ a uložil ${founderBankCard.coinsAwarded} Coinů do Banku.',
        createdAt: founderBankCard.playedAt,
        monthKey: currKey,
        choreId: founderBankCard.chore.id,
        symbol: founderBankCard.chore.symbol,
        coins: founderBankCard.coinsAwarded,
        levelAtEvent: MonthlyLevel.awakened,
        heatAtEvent: HeatLevel.blazingForge,
      ),
      FeedEntry(
        id: _nextId('feed'),
        type: FeedEntryType.cardPlayed,
        actorNickname: shadow.nickname,
        title: pendingCard.chore.title,
        message:
            'zahrál kartu „${pendingCard.chore.title}“ a uložil ${pendingCard.coinsAwarded} Coinů do Banku.',
        createdAt: pendingCard.playedAt,
        monthKey: currKey,
        choreId: pendingCard.chore.id,
        symbol: pendingCard.chore.symbol,
        coins: pendingCard.coinsAwarded,
        levelAtEvent: MonthlyLevel.awakened,
        heatAtEvent: HeatLevel.glowingEmbers,
      ),
      FeedEntry(
        id: _nextId('feed'),
        type: FeedEntryType.exchangeApproved,
        actorNickname: queen.nickname,
        title: 'Směna schválena Rukou',
        message: '${queen.nickname} směnila 2 karty za 1 170 Coinů (117 Kč).',
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
        monthKey: currKey,
        symbol: '☞',
        coins: 1170,
        czkAmount: 117,
        cardCount: 2,
      ),
      FeedEntry(
        id: _nextId('feed'),
        type: FeedEntryType.cardPlayed,
        actorNickname: queen.nickname,
        title: currApproved1.chore.title,
        message:
            'zahrála kartu „${currApproved1.chore.title}“ a uložila ${currApproved1.coinsAwarded} Coinů do Banku.',
        createdAt: currApproved1.playedAt,
        monthKey: currKey,
        choreId: currApproved1.chore.id,
        symbol: currApproved1.chore.symbol,
        coins: currApproved1.coinsAwarded,
        levelAtEvent: MonthlyLevel.awakened,
        heatAtEvent: HeatLevel.hellfire,
      ),
      FeedEntry(
        id: _nextId('feed'),
        type: FeedEntryType.monthProclamation,
        actorNickname: 'Ruka sídla',
        title: 'Měsíční vyhlášení • $prevKey',
        message:
            'Vládkyní minulého měsíce se stala ${queen.nickname} (1 200 Coinů). Levely se resetovaly na Probuzený.',
        createdAt: DateTime(now.year, now.month, 1, 0, 1),
        monthKey: prevKey,
        symbol: '♛',
        coins: 1200,
        cardCount: 1,
        winnerNickname: queen.nickname,
      ),
      FeedEntry(
        id: _nextId('feed'),
        type: FeedEntryType.cardPlayed,
        actorNickname: queen.nickname,
        title: prevCard1.chore.title,
        message:
            'zahrála kartu „${prevCard1.chore.title}“ a uložila ${prevCard1.coinsAwarded} Coinů do Banku.',
        createdAt: prevCard1.playedAt,
        monthKey: prevKey,
        choreId: prevCard1.chore.id,
        symbol: prevCard1.chore.symbol,
        coins: prevCard1.coinsAwarded,
        levelAtEvent: MonthlyLevel.restlessSpirit,
        heatAtEvent: HeatLevel.glowingEmbers,
      ),
    ]);
  }
}

const choreCatalog = <ChoreDefinition>[
  ChoreDefinition(
    id: 'trash',
    title: 'Vynést koš',
    baseCoins: 100,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 5,
  ),
  ChoreDefinition(
    id: 'shopping',
    title: 'Vyklidit nákup',
    baseCoins: 150,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 10,
  ),
  ChoreDefinition(
    id: 'dishwasher',
    title: 'Vyklidit myčku',
    baseCoins: 150,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 10,
  ),
  ChoreDefinition(
    id: 'laundry',
    title: 'Uklidit si prádlo',
    baseCoins: 200,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 15,
  ),
  ChoreDefinition(
    id: 'stairs',
    title: 'Vysát schodiště',
    baseCoins: 200,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 15,
  ),
  ChoreDefinition(
    id: 'queenie',
    title: 'Vyčesat Queenie',
    baseCoins: 300,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 20,
  ),
  ChoreDefinition(
    id: 'toilet',
    title: 'Umýt toaletu',
    baseCoins: 400,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 20,
  ),
  ChoreDefinition(
    id: 'dogs',
    title: 'Příprava krmení pro psy',
    baseCoins: 350,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 20,
    note: 'Včetně nakrmení',
  ),
  ChoreDefinition(
    id: 'sport',
    title: 'Sportovní aktivita',
    baseCoins: 350,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 30,
  ),
  ChoreDefinition(
    id: 'garden',
    title: 'Zalít zahradu',
    baseCoins: 300,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 20,
    note: 'Péče o zeleň i masožravky',
  ),
  ChoreDefinition(
    id: 'evening',
    title: 'Večerní úklid',
    baseCoins: 450,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 35,
    note: 'Kuchyň, předsíň a obývák',
  ),
  ChoreDefinition(
    id: 'bathroom',
    title: 'Umýt koupelnu',
    baseCoins: 600,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 40,
    note: 'Cena za jednu koupelnu',
  ),
  ChoreDefinition(
    id: 'mop',
    title: 'Vytřít parním mopem',
    baseCoins: 500,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 35,
  ),
  ChoreDefinition(
    id: 'ironing',
    title: 'Vyžehlit',
    baseCoins: 700,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 45,
  ),
  ChoreDefinition(
    id: 'cooking',
    title: 'Uvařit jídlo',
    baseCoins: 700,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 60,
  ),
  ChoreDefinition(
    id: 'school',
    title: 'Učení / Škola',
    baseCoins: 600,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 45,
  ),
  ChoreDefinition(
    id: 'room',
    title: 'Vygruntovat pokojíček',
    baseCoins: 1000,
    difficulty: ChoreDifficulty.special,
    symbol: '★',
    minutes: 90,
    note: 'Velký hloubkový úklid',
  ),
];
