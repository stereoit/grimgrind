import 'package:chore_cash/mansion_store.dart';
import 'package:chore_cash/models.dart';
import 'package:flutter_test/flutter_test.dart';

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
    expect(store.feedEntries.first.type, FeedEntryType.cardPlayed);

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
    expect(store.feedEntries.first.type, FeedEntryType.exchangeApproved);

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
      store.feedEntries.first.type,
      FeedEntryType.monthProclamation,
    );
  });
}
