enum ChoreDifficulty { easy, medium, hard, special }

extension ChoreDifficultyLabel on ChoreDifficulty {
  String get label => switch (this) {
    ChoreDifficulty.easy => 'Pohoda',
    ChoreDifficulty.medium => 'Horší',
    ChoreDifficulty.hard => 'Těžké',
    ChoreDifficulty.special => 'Speciální',
  };
}

class ChoreDefinition {
  const ChoreDefinition({
    required this.id,
    required this.title,
    required this.baseCoins,
    required this.difficulty,
    required this.symbol,
    required this.minutes,
    this.note,
  });

  final String id;
  final String title;
  final int baseCoins;
  final ChoreDifficulty difficulty;
  final String symbol;
  final int minutes;
  final String? note;
}

/// Monthly player level inspired by Unreal Tournament streaks, reset 1st of month.
/// Never cools down during the month; depends on total cards played in the month.
enum MonthlyLevel {
  awakened,
  restlessSpirit,
  bloodthirsty,
  unstoppable,
  godlike,
}

extension MonthlyLevelData on MonthlyLevel {
  String get label => switch (this) {
    MonthlyLevel.awakened => 'Probuzený',
    MonthlyLevel.restlessSpirit => 'Nepokojný duch',
    MonthlyLevel.bloodthirsty => 'Krvežíznivý',
    MonthlyLevel.unstoppable => 'Nezastavitelný',
    MonthlyLevel.godlike => 'Nesmrtelný',
  };

  String get utCallout => switch (this) {
    MonthlyLevel.awakened => 'First Blood',
    MonthlyLevel.restlessSpirit => 'Killing Spree',
    MonthlyLevel.bloodthirsty => 'Rampage',
    MonthlyLevel.unstoppable => 'Unstoppable',
    MonthlyLevel.godlike => 'Godlike',
  };

  int get minCards => switch (this) {
    MonthlyLevel.awakened => 0,
    MonthlyLevel.restlessSpirit => 5,
    MonthlyLevel.bloodthirsty => 12,
    MonthlyLevel.unstoppable => 22,
    MonthlyLevel.godlike => 35,
  };

  double get bonusRate => switch (this) {
    MonthlyLevel.awakened => 0.0,
    MonthlyLevel.restlessSpirit => 0.10,
    MonthlyLevel.bloodthirsty => 0.20,
    MonthlyLevel.unstoppable => 0.30,
    MonthlyLevel.godlike => 0.50,
  };

  int get bonusPercent => (bonusRate * 100).round();

  static MonthlyLevel fromCardCount(int count) {
    if (count >= 35) return MonthlyLevel.godlike;
    if (count >= 22) return MonthlyLevel.unstoppable;
    if (count >= 12) return MonthlyLevel.bloodthirsty;
    if (count >= 5) return MonthlyLevel.restlessSpirit;
    return MonthlyLevel.awakened;
  }
}

/// Consistency heat / streak tier. Cools down on inactivity and drives card aura.
enum HeatLevel { coldAsh, glowingEmbers, blazingForge, hellfire }

extension HeatLevelData on HeatLevel {
  String get label => switch (this) {
    HeatLevel.coldAsh => 'Vychladlý popel',
    HeatLevel.glowingEmbers => 'Žhnoucí uhlíky',
    HeatLevel.blazingForge => 'Rozpálená výheň',
    HeatLevel.hellfire => 'Pekelný žár',
  };

  String get ruleSummary => switch (this) {
    HeatLevel.coldAsh => 'Výchozí stav nebo pauza 4+ dny',
    HeatLevel.glowingEmbers => 'Min. 2 dny aktivity • udržení: 1× za 3 dny',
    HeatLevel.blazingForge => 'Min. 4 dny aktivity • udržení: 1× za 3 dny',
    HeatLevel.hellfire => 'Min. 7 dní aktivity • udržení: každý den',
  };

  double get bonusRate => switch (this) {
    HeatLevel.coldAsh => 0.0,
    HeatLevel.glowingEmbers => 0.10,
    HeatLevel.blazingForge => 0.20,
    HeatLevel.hellfire => 0.30,
  };

  int get bonusPercent => (bonusRate * 100).round();
}

enum PlayedCardStatus { inBank, pendingExchange, exchanged, rejected }

class PlayedCard {
  PlayedCard({
    required this.id,
    required this.chore,
    required this.memberId,
    required this.memberNickname,
    required this.coinsAwarded,
    required this.playedAt,
    required this.monthKey,
    required this.levelAtPlay,
    required this.heatAtPlay,
    this.status = PlayedCardStatus.inBank,
    this.exchangeId,
    this.exchangedAt,
  });

  final String id;
  final ChoreDefinition chore;
  final String memberId;
  String memberNickname;
  final int coinsAwarded;
  final DateTime playedAt;
  final String monthKey;
  final MonthlyLevel levelAtPlay;
  final HeatLevel heatAtPlay;
  PlayedCardStatus status;
  String? exchangeId;
  DateTime? exchangedAt;
}

enum ExchangeStatus { pending, approved }

class ExchangeRequest {
  ExchangeRequest({
    required this.id,
    required this.memberId,
    required this.memberNickname,
    required this.cardIds,
    required this.totalCoins,
    required this.coinsPerCzk,
    required this.requestedAt,
    required this.monthKey,
    this.isAutoMonthEnd = false,
    this.status = ExchangeStatus.pending,
    this.approvedAt,
    this.approvedByNickname,
  });

  final String id;
  final String memberId;
  String memberNickname;
  final List<String> cardIds;
  int totalCoins;
  final int coinsPerCzk;
  final DateTime requestedAt;
  final String monthKey;
  final bool isAutoMonthEnd;
  ExchangeStatus status;
  DateTime? approvedAt;
  String? approvedByNickname;

  int get czkAmount => (totalCoins / coinsPerCzk).round();
}

enum FeedEntryType { cardPlayed, exchangeApproved, monthProclamation }

class FeedEntry {
  const FeedEntry({
    required this.id,
    required this.type,
    required this.actorNickname,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.monthKey,
    this.choreId,
    this.symbol,
    this.coins,
    this.czkAmount,
    this.cardCount,
    this.winnerNickname,
    this.levelAtEvent,
    this.heatAtEvent,
  });

  final String id;
  final FeedEntryType type;
  final String actorNickname;
  final String title;
  final String message;
  final DateTime createdAt;
  final String monthKey;
  final String? choreId;
  final String? symbol;
  final int? coins;
  final int? czkAmount;
  final int? cardCount;
  final String? winnerNickname;
  final MonthlyLevel? levelAtEvent;
  final HeatLevel? heatAtEvent;
}

/// Grammatical sex/gender used for localized wording in Feed & notifications.
enum MemberSex { male, female, neutral }

extension MemberSexData on MemberSex {
  String get label => switch (this) {
    MemberSex.male => 'Muž',
    MemberSex.female => 'Žena',
    MemberSex.neutral => 'Neutrální',
  };

  String get playedVerb => switch (this) {
    MemberSex.male => 'zahrál',
    MemberSex.female => 'zahrála',
    MemberSex.neutral => 'zahráli',
  };

  String get storedVerb => switch (this) {
    MemberSex.male => 'uložil',
    MemberSex.female => 'uložila',
    MemberSex.neutral => 'uložili',
  };

  String get exchangedVerb => switch (this) {
    MemberSex.male => 'směnil',
    MemberSex.female => 'směnila',
    MemberSex.neutral => 'směnili',
  };

  String get winnerRole => switch (this) {
    MemberSex.male => 'Vládcem',
    MemberSex.female => 'Vládkyní',
    MemberSex.neutral => 'Vládcem',
  };

  String get becameVerb => switch (this) {
    MemberSex.male => 'se stal',
    MemberSex.female => 'se stala',
    MemberSex.neutral => 'se stali',
  };
}

class GangMember {
  GangMember({
    required this.id,
    required this.nickname,
    required this.isHand,
    this.sex = MemberSex.male,
    this.heatPeakDays = 0,
    this.lastActiveDay,
    Set<String>? favoriteChoreIds,
  }) : favoriteChoreIds = favoriteChoreIds ?? <String>{};

  final String id;
  String nickname;
  final bool isHand;
  MemberSex sex;

  /// Accumulated streak days used for heating up / cooling down.
  int heatPeakDays;
  DateTime? lastActiveDay;

  /// Chore IDs marked as favorite by this member.
  final Set<String> favoriteChoreIds;
}

class Gang {
  Gang({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.founderId,
    this.coinsPerCzk = 10,
    this.themeId = defaultThemeId,
  });

  static const String defaultThemeId = 'gothic_mansion';
  static const String inviteBaseUrl = 'https://grim-grind.web.app/join';

  final String id;
  String name;
  String inviteCode;
  final String founderId;

  /// How many Coins equal 1 CZK (editable by the Hand / founder).
  int coinsPerCzk;

  /// Active theme package ID for this Gang (defaults to Gothic Mansion).
  String themeId;

  String get inviteUrl => '$inviteBaseUrl?code=${Uri.encodeComponent(inviteCode)}';
}

enum LeaderboardSort { mostActive, mostHardWorking, byStreakLevel }

extension LeaderboardSortLabel on LeaderboardSort {
  String get label => switch (this) {
    LeaderboardSort.mostActive => 'Most Active',
    LeaderboardSort.mostHardWorking => 'Most Hard Working',
    LeaderboardSort.byStreakLevel => 'By Streak Level',
  };
}

enum LeaderboardPeriod { currentMonth, previousMonth, allTime }

extension LeaderboardPeriodLabel on LeaderboardPeriod {
  String get label => switch (this) {
    LeaderboardPeriod.currentMonth => 'Tento měsíc',
    LeaderboardPeriod.previousMonth => 'Minulý měsíc',
    LeaderboardPeriod.allTime => 'Síň slávy',
  };
}

class PlayerLeaderboardCardData {
  const PlayerLeaderboardCardData({
    required this.member,
    required this.monthlyLevel,
    required this.heatLevel,
    required this.streakDays,
    required this.approvedTaskCount,
    required this.approvedCoins,
    required this.approvedMinutes,
    required this.inBankCoins,
    required this.inBankCount,
  });

  final GangMember member;
  final MonthlyLevel monthlyLevel;
  final HeatLevel heatLevel;
  final int streakDays;
  final int approvedTaskCount;
  final int approvedCoins;
  final int approvedMinutes;
  final int inBankCoins;
  final int inBankCount;
}
