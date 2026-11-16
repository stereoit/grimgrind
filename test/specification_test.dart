import 'package:chore_cash/mansion_store.dart';
import 'package:chore_cash/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Spec §1: Onboarding, Gang & Roles', () {
    test('founder becomes Hand with invite code and custom exchange rate', () {
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 14, 30));

      expect(store.isReady, isFalse);
      store.completeIntro();
      expect(store.hasSeenIntro, isTrue);

      store.createGang(
        gangName: 'Raven Manor',
        founderNickname: 'Hand Mom',
        coinsPerCzk: 20,
      );

      expect(store.isReady, isTrue);
      expect(store.gang!.name, 'Raven Manor');
      expect(store.gang!.inviteCode, startsWith('GRIM-'));
      expect(store.gang!.coinsPerCzk, 20);
      expect(store.currentMember!.nickname, 'Hand Mom');
      expect(store.isCurrentUserHand, isTrue);
    });

    test('joining by invite code creates non-Hand member and rejects wrong code', () {
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 14, 30));
      store.createGang(gangName: 'Manor', founderNickname: 'Hand');
      final validCode = store.gang!.inviteCode;

      expect(
        store.joinGangByCode(inviteCode: 'WRONG-99', nickname: 'Shadow'),
        isFalse,
      );
      expect(
        store.joinGangByCode(
          inviteCode: validCode.toLowerCase(),
          nickname: 'Shadow Master',
        ),
        isTrue,
      );
      expect(store.currentMember!.nickname, 'Shadow Master');
      expect(store.isCurrentUserHand, isFalse);

      // Re-joining with existing nickname selects existing member instead of duplicating.
      final countBefore = store.members.length;
      expect(
        store.joinGangByCode(inviteCode: validCode, nickname: 'shadow master'),
        isTrue,
      );
      expect(store.members.length, countBefore);
    });

    test('only the Hand can update rate, approve/reject exchanges, or close month', () {
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 10, 0));
      store.createGang(
        gangName: 'Manor',
        founderNickname: 'Hand',
        coinsPerCzk: 10,
      );
      store.addMember('Peter');
      final peter = store.members.last;

      store.switchActiveMember(peter.id);
      expect(store.isCurrentUserHand, isFalse);

      // Non-Hand cannot change exchange rate.
      store.updateCoinsPerCzk(50);
      expect(store.gang!.coinsPerCzk, 10);

      // Peter plays a card and requests exchange.
      final played = store.playCard(store.deck.first)!;
      final req = store.requestExchange()!;

      // Non-Hand cannot approve, reject, or close month.
      expect(store.approveExchange(req.id), isFalse);
      expect(store.rejectCardInRequest(req.id, played.id), isFalse);
      expect(store.closeMonth(), 0);
    });

    test('renameCurrentMember updates nickname on member, cards, and requests', () {
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 10, 0));
      store.createGang(gangName: 'Manor', founderNickname: 'Hand');
      store.playCard(store.deck.first);
      store.requestExchange();

      store.renameCurrentMember('New Hand');
      expect(store.currentMember!.nickname, 'New Hand');
      expect(store.playedCards.single.memberNickname, 'New Hand');
      expect(store.exchangeRequests.single.memberNickname, 'New Hand');
    });
  });

  group('Spec §2: Core Loop, No Cooldowns & Rejection', () {
    test('same card can be played repeatedly without daily limits or cooldowns', () {
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 10, 0));
      store.createGang(gangName: 'Sídlo', founderNickname: 'Ruka');
      final trash = store.deck.firstWhere((c) => c.id == 'trash');

      final first = store.playCard(trash);
      final second = store.playCard(trash);
      final third = store.playCard(trash);

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(third, isNotNull);
      expect(store.bankCardsFor(store.currentMember!.id), hasLength(3));
      expect(store.bankCoinsFor(store.currentMember!.id), 300);
    });

    test('requesting exchange fails when Bank is empty', () {
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 10, 0));
      store.createGang(gangName: 'Sídlo', founderNickname: 'Ruka');

      expect(store.requestExchange(), isNull);
    });

    test('Hand can reject individual cards from exchange request without counting to Leaderboard', () {
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 10, 0));
      store.createGang(gangName: 'Sídlo', founderNickname: 'Ruka');
      store.addMember('Karel');
      final karel = store.members.last;

      store.switchActiveMember(karel.id);
      final card1 = store.playCard(store.deck[0])!; // 100
      final card2 = store.playCard(store.deck[1])!; // 150
      final req = store.requestExchange()!;
      expect(req.totalCoins, 250);

      // Hand rejects card2.
      store.switchActiveMember(store.gang!.founderId);
      expect(store.rejectCardInRequest(req.id, card2.id), isTrue);
      expect(card2.status, PlayedCardStatus.rejected);
      expect(req.cardIds, [card1.id]);
      expect(req.totalCoins, 100);

      // Hand approves remaining card1.
      expect(store.approveExchange(req.id), isTrue);
      final board = store.buildLeaderboard(
        period: LeaderboardPeriod.currentMonth,
        sort: LeaderboardSort.mostActive,
      );
      final karelRow = board.firstWhere((e) => e.member.id == karel.id);
      expect(karelRow.approvedTaskCount, 1);
      expect(karelRow.approvedCoins, 100);
      // Rejected card does not count toward MonthlyLevel card count either.
      expect(store.playedCardCountInMonth(karel.id, store.currentMonthKey), 1);
    });

    test('rejecting the last card in an exchange removes the empty request', () {
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 10, 0));
      store.createGang(gangName: 'Sídlo', founderNickname: 'Ruka');
      final card = store.playCard(store.deck[0])!;
      final req = store.requestExchange()!;

      expect(store.rejectCardInRequest(req.id, card.id), isTrue);
      expect(store.pendingExchanges, isEmpty);
    });
  });

  group('Spec §3: Leaderboard Sorting & Periods', () {
    test('Leaderboard supports Most Active, Most Hard Working, By Streak Level and Periods', () {
      var now = DateTime(2026, 7, 15, 10, 0);
      final store = MansionStore(clock: () => now);
      store.createGang(gangName: 'Sídlo', founderNickname: 'Ruka');
      store.addMember('ActiveLowCoins');
      store.addMember('HardWorker');
      final activeMember = store.members[1];
      final hardWorker = store.members[2];

      // July: ActiveLowCoins plays 2 easy cards (2 * 100 = 200 coins).
      store.switchActiveMember(activeMember.id);
      store.playCard(store.deck.firstWhere((c) => c.id == 'trash')); // 100
      store.playCard(store.deck.firstWhere((c) => c.id == 'trash')); // 100
      final req1 = store.requestExchange()!;

      // July: HardWorker plays 1 special card (1000 coins).
      store.switchActiveMember(hardWorker.id);
      store.playCard(store.deck.firstWhere((c) => c.id == 'room')); // 1000
      final req2 = store.requestExchange()!;

      store.switchActiveMember(store.gang!.founderId);
      store.approveExchange(req1.id);
      store.approveExchange(req2.id);

      // Advance to August and build a streak for Founder.
      now = DateTime(2026, 8, 1, 10, 0);
      store.playCard(store.deck.first);
      now = DateTime(2026, 8, 2, 10, 0);
      store.playCard(store.deck.first);
      final req3 = store.requestExchange()!;
      store.approveExchange(req3.id);

      // In August (currentMonth): Founder has 2 approved cards; July players have 0.
      final augBoard = store.buildLeaderboard(
        period: LeaderboardPeriod.currentMonth,
        sort: LeaderboardSort.mostActive,
      );
      expect(augBoard.first.member.id, store.gang!.founderId);
      expect(
        augBoard.firstWhere((e) => e.member.id == hardWorker.id).approvedCoins,
        0,
      );

      // Previous month (July): Most Active -> ActiveLowCoins (2 tasks) > HardWorker (1 task).
      final julyActive = store.buildLeaderboard(
        period: LeaderboardPeriod.previousMonth,
        sort: LeaderboardSort.mostActive,
      );
      expect(julyActive.first.member.id, activeMember.id);

      // Previous month (July): Most Hard Working -> HardWorker (1000 coins) > ActiveLowCoins (200 coins).
      final julyHard = store.buildLeaderboard(
        period: LeaderboardPeriod.previousMonth,
        sort: LeaderboardSort.mostHardWorking,
      );
      expect(julyHard.first.member.id, hardWorker.id);

      // By Streak Level -> Founder has glowingEmbers (2 days) > others (coldAsh).
      final byStreak = store.buildLeaderboard(
        period: LeaderboardPeriod.allTime,
        sort: LeaderboardSort.byStreakLevel,
      );
      expect(byStreak.first.member.id, store.gang!.founderId);
      expect(byStreak.first.heatLevel, HeatLevel.glowingEmbers);
    });
  });

  group('Spec §4: Coin Economy, Monthly Levels & Cooling Heat', () {
    test('MonthlyLevel thresholds match spec (0-4, 5-11, 12-21, 22-34, 35+) and reset on new month', () {
      var now = DateTime(2026, 8, 1, 10, 0);
      final store = MansionStore(clock: () => now);
      store.createGang(gangName: 'Sídlo', founderNickname: 'Hero');
      final heroId = store.currentMember!.id;

      expect(store.monthlyLevelFor(heroId), MonthlyLevel.awakened);
      expect(MonthlyLevel.awakened.bonusPercent, 0);

      for (var i = 0; i < 4; i++) {
        store.playCard(store.deck.first);
      }
      expect(store.monthlyLevelFor(heroId), MonthlyLevel.awakened);

      store.playCard(store.deck.first); // 5th card
      expect(store.monthlyLevelFor(heroId), MonthlyLevel.restlessSpirit);
      expect(MonthlyLevel.restlessSpirit.bonusPercent, 10);

      for (var i = 5; i < 12; i++) {
        store.playCard(store.deck.first);
      }
      expect(store.monthlyLevelFor(heroId), MonthlyLevel.bloodthirsty);
      expect(MonthlyLevel.bloodthirsty.bonusPercent, 20);

      for (var i = 12; i < 22; i++) {
        store.playCard(store.deck.first);
      }
      expect(store.monthlyLevelFor(heroId), MonthlyLevel.unstoppable);
      expect(MonthlyLevel.unstoppable.bonusPercent, 30);

      for (var i = 22; i < 35; i++) {
        store.playCard(store.deck.first);
      }
      expect(store.monthlyLevelFor(heroId), MonthlyLevel.godlike);
      expect(MonthlyLevel.godlike.bonusPercent, 50);

      // Next month resets MonthlyLevel back to Awakened.
      now = DateTime(2026, 9, 1, 10, 0);
      expect(store.monthlyLevelFor(heroId), MonthlyLevel.awakened);
    });

    test('spec formula example: 200 baseCoins * (1 + 0.30 Level + 0.20 Heat) == 300', () {
      var now = DateTime(2026, 8, 1, 10, 0);
      final store = MansionStore(clock: () => now);
      store.createGang(gangName: 'Sídlo', founderNickname: 'Hero');
      final hero = store.currentMember!;

      // Play across 4 distinct days (22 cards total) -> Unstoppable (+30%) & BlazingForge (+20%).
      for (var day = 0; day < 4; day++) {
        now = DateTime(2026, 8, 1 + day, 10, 0);
        final cardsToday = day == 3 ? 19 : 1;
        for (var c = 0; c < cardsToday; c++) {
          store.playCard(store.deck.first);
        }
      }

      expect(store.monthlyLevelFor(hero.id), MonthlyLevel.unstoppable);
      expect(store.heatLevelFor(hero), HeatLevel.blazingForge);

      final laundry = store.deck.firstWhere((c) => c.id == 'laundry'); // 200 base
      expect(store.effectiveCoinsFor(laundry, hero), 300);
    });

    test('czkForCoins converts according to Gang coinsPerCzk', () {
      final store = MansionStore(clock: () => DateTime(2026, 8, 1, 10, 0));
      store.createGang(
        gangName: 'Sídlo',
        founderNickname: 'Ruka',
        coinsPerCzk: 10,
      );
      expect(store.czkForCoins(100), 10);
      expect(store.czkForCoins(155), 16);

      store.updateCoinsPerCzk(20);
      expect(store.czkForCoins(200), 10);
    });
  });

  group('Spec §5: Chore Catalog (17 cards)', () {
    test('deck contains exactly 17 cards with expected difficulty breakdown', () {
      expect(choreCatalog, hasLength(17));

      final easy = choreCatalog.where((c) => c.difficulty == ChoreDifficulty.easy);
      final medium = choreCatalog.where((c) => c.difficulty == ChoreDifficulty.medium);
      final hard = choreCatalog.where((c) => c.difficulty == ChoreDifficulty.hard);
      final special = choreCatalog.where((c) => c.difficulty == ChoreDifficulty.special);

      expect(easy, hasLength(5));
      expect(medium, hasLength(6));
      expect(hard, hasLength(5));
      expect(special, hasLength(1));
      expect(special.single.baseCoins, 1000);
      expect(special.single.title, 'Vygruntovat pokojíček');

      final ids = choreCatalog.map((c) => c.id).toSet();
      expect(ids, hasLength(17));
      for (final card in choreCatalog) {
        expect(card.title, isNotEmpty);
        expect(card.baseCoins, greaterThanOrEqualTo(100));
        expect(card.minutes, greaterThan(0));
        expect(card.symbol, isNotEmpty);
      }
    });
  });
}
