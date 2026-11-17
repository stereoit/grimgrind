import 'dart:async';

import 'package:chore_cash/firebase_gang_repository.dart';
import 'package:chore_cash/mansion_store.dart';
import 'package:chore_cash/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUser extends Fake implements User {
  _FakeUser(this.uid);

  @override
  final String uid;

  @override
  bool get isAnonymous => false;

  @override
  String? get email => 'player@example.com';
}

class _FakeGangRepository extends FirebaseGangRepository {
  _FakeGangRepository(this.user);

  final User user;
  final membersController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final playedCardsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final exchangesController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final chronicleController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  PlayedCard? lastRecordedCard;
  ChronicleEntry? lastRecordedChronicle;

  @override
  bool get isFirebaseReady => true;

  @override
  User? get currentUser => user;

  @override
  Future<List<String>> fetchUserGangIds() async => ['gang-1'];

  @override
  Future<Map<String, dynamic>?> fetchGang(String gangId) async => {
    'id': gangId,
    'name': 'Shadow Mansion',
    'inviteCode': 'GRIM-42',
    'founderId': 'uid-1',
    'coinsPerCzk': 10,
  };

  @override
  Future<List<Map<String, dynamic>>> fetchGangMembers(String gangId) async => [
    {'id': 'uid-1', 'nickname': 'Player 1', 'isHand': true, 'sex': 'male'},
    {'id': 'uid-2', 'nickname': 'Player 2', 'isHand': false, 'sex': 'female'},
  ];

  @override
  Stream<List<Map<String, dynamic>>> watchGangMembers(String gangId) =>
      membersController.stream;

  @override
  Stream<List<Map<String, dynamic>>> watchPlayedCards(String gangId) =>
      playedCardsController.stream;

  @override
  Stream<List<Map<String, dynamic>>> watchExchanges(String gangId) =>
      exchangesController.stream;

  @override
  Stream<List<Map<String, dynamic>>> watchChronicle(String gangId) =>
      chronicleController.stream;

  @override
  Future<void> recordPlayedCard({
    required String gangId,
    required PlayedCard card,
    required MemberSex memberSex,
    required int heatPeakDays,
    required DateTime? lastActiveDay,
    required ChronicleEntry chronicleEntry,
  }) async {
    lastRecordedCard = card;
    lastRecordedChronicle = chronicleEntry;
  }

  void dispose() {
    membersController.close();
    playedCardsController.close();
    exchangesController.close();
    chronicleController.close();
  }
}

void main() {
  test('founder becomes the Hand, plays card into Bank and approves exchange for Leaderboard', () {
    var now = DateTime(2026, 7, 10, 10, 0);
    final store = MansionStore(clock: () => now);

    store.createGang(
      gangName: 'Rodina Novákových',
      founderNickname: 'Ruka Táta',
      coinsPerCzk: 10,
    );
    expect(store.isReady, isTrue);
    expect(store.isCurrentUserHand, isTrue);

    store.addMember('Petr');
    final petr = store.members.last;
    store.switchActiveMember(petr.id);
    expect(store.isCurrentUserHand, isFalse);

    final trash = store.deck.first; // 100 baseCoins
    final played = store.playCard(trash);
    expect(played, isNotNull);
    expect(played!.coinsAwarded, 100);
    expect(store.bankCoinsFor(petr.id), 100);
    expect(store.chronicleEntries.first.type, ChronicleEntryType.cardPlayed);

    // Unexchanged cards must NOT count into Leaderboard yet.
    var board = store.buildLeaderboard(
      period: LeaderboardPeriod.currentMonth,
      sort: LeaderboardSort.mostActive,
    );
    expect(board.firstWhere((e) => e.member.id == petr.id).approvedTaskCount, 0);

    // Petr requests exchange.
    final req = store.requestExchange();
    expect(req, isNotNull);
    expect(store.bankCoinsFor(petr.id), 0);
    expect(store.pendingExchanges, hasLength(1));

    // Founder (Hand) approves exchange -> appears in Feed & Leaderboard.
    store.switchActiveMember(store.gang!.founderId);
    expect(store.approveExchange(req!.id), isTrue);
    expect(
      store.chronicleEntries.first.type,
      ChronicleEntryType.exchangeApproved,
    );

    board = store.buildLeaderboard(
      period: LeaderboardPeriod.currentMonth,
      sort: LeaderboardSort.mostActive,
    );
    final petrRow = board.firstWhere((e) => e.member.id == petr.id);
    expect(petrRow.approvedTaskCount, 1);
    expect(petrRow.approvedCoins, 100);
  });

  test('MonthlyLevel and cooling Heat multiply card Coins properly', () {
    var now = DateTime(2026, 7, 1, 9, 0);
    final store = MansionStore(clock: () => now);
    store.createGang(gangName: 'Test', founderNickname: 'Hero');
    final hero = store.currentMember!;

    // Play 5 cards over 4 consecutive days -> MonthlyLevel = restlessSpirit (+10%),
    // Heat = blazingForge (+20%), total bonus = +30%.
    for (var day = 0; day < 4; day++) {
      now = DateTime(2026, 7, 1 + day, 9, 0);
      store.playCard(store.deck.first);
    }
    store.playCard(store.deck.first); // 5th card on day 4

    expect(store.monthlyLevelFor(hero.id), MonthlyLevel.restlessSpirit);
    expect(store.heatLevelFor(hero), HeatLevel.blazingForge);
    // Base 100 * (1 + 0.10 + 0.20) = 130
    expect(store.effectiveCoinsFor(store.deck.first, hero), 130);

    // Reach Hellfire (7 active days) -> +30% Heat.
    for (var day = 4; day < 7; day++) {
      now = DateTime(2026, 7, 1 + day, 9, 0);
      store.playCard(store.deck.first);
    }
    expect(store.heatLevelFor(hero), HeatLevel.hellfire);

    // Missing 1 day (gap == 2 days) drops Hellfire down by one tier to blazingForge.
    now = now.add(const Duration(days: 2));
    expect(store.heatLevelFor(hero), HeatLevel.blazingForge);

    // Missing 4+ days cools Heat all the way down to coldAsh (+0%).
    now = now.add(const Duration(days: 3));
    expect(store.heatLevelFor(hero), HeatLevel.coldAsh);
  });

  test('closeMonth creates auto-exchanges and adds month proclamation divider', () {
    var now = DateTime(2026, 7, 31, 20, 0);
    final store = MansionStore(clock: () => now);
    store.createGang(gangName: 'Sídlo', founderNickname: 'Ruka');
    store.playCard(store.deck.first);

    final created = store.closeMonth();
    expect(created, 1);
    expect(store.pendingExchanges.single.isAutoMonthEnd, isTrue);
    expect(
      store.chronicleEntries.first.type,
      ChronicleEntryType.monthProclamation,
    );
  });

  test('syncFromFirebase attaches real-time streams and persists played cards', () async {
    final repo = _FakeGangRepository(_FakeUser('uid-1'));
    addTearDown(repo.dispose);

    final store = MansionStore(
      clock: () => DateTime(2026, 11, 17, 21, 30),
      gangRepository: repo,
    );
    addTearDown(store.dispose);

    await store.syncFromFirebase();
    expect(store.gang?.id, 'gang-1');
    expect(store.chronicleEntries, isEmpty);

    // Play a card locally -> persisted to repository.
    final played = store.playCard(store.deck.first);
    expect(played, isNotNull);
    expect(repo.lastRecordedCard?.id, played!.id);
    expect(repo.lastRecordedChronicle?.id, 'card_${played.id}');

    // Remote player plays a card -> arrives via played_cards stream.
    repo.playedCardsController.add([
      {
        'id': 'remote-card-1',
        'choreId': store.deck.first.id,
        'choreTitle': store.deck.first.title,
        'choreSymbol': store.deck.first.symbol,
        'choreBaseCoins': store.deck.first.baseCoins,
        'memberId': 'uid-2',
        'memberNickname': 'Player 2',
        'coinsAwarded': 50,
        'playedAt': DateTime(2026, 11, 17, 21, 31).toIso8601String(),
        'monthKey': '2026-11',
        'levelAtPlay': 'awakened',
        'heatAtPlay': 'coldAsh',
        'status': 'inBank',
      },
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(store.playedCards.any((c) => c.id == 'remote-card-1'), isTrue);
    expect(
      store.chronicleEntries.any((e) => e.id == 'card_remote-card-1'),
      isTrue,
    );

    // Chronicle stream arrives with same deterministic ID -> no duplicates.
    repo.chronicleController.add([
      {
        'id': 'card_remote-card-1',
        'type': 'cardPlayed',
        'actorNickname': 'Player 2',
        'title': store.deck.first.title,
        'message': 'zahrála kartu',
        'createdAt': DateTime(2026, 11, 17, 21, 31).toIso8601String(),
        'monthKey': '2026-11',
        'choreId': store.deck.first.id,
        'symbol': store.deck.first.symbol,
        'coins': 50,
      },
    ]);
    await Future<void>.delayed(Duration.zero);

    final matching = store.chronicleEntries
        .where((e) => e.id == 'card_remote-card-1')
        .toList();
    expect(matching.length, 1);
  });
}
