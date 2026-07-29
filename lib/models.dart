enum ChoreDifficulty { easy, medium, hard, special }

extension ChoreDifficultyLabel on ChoreDifficulty {
  String get label => switch (this) {
    ChoreDifficulty.easy => 'Pohoda',
    ChoreDifficulty.medium => 'Horší',
    ChoreDifficulty.hard => 'Těžké',
    ChoreDifficulty.special => 'Speciální',
  };
}

enum ChoreStatus { available, assigned, completed, approved, paid }

class ChoreDefinition {
  const ChoreDefinition({
    required this.id,
    required this.title,
    required this.reward,
    required this.difficulty,
    required this.symbol,
    required this.minutes,
    this.note,
    this.weeklyLimit,
  });

  final String id;
  final String title;
  final int reward;
  final ChoreDifficulty difficulty;
  final String symbol;
  final int minutes;
  final String? note;
  final int? weeklyLimit;
}

class ChoreCard {
  ChoreCard({
    required this.id,
    required this.chore,
    this.status = ChoreStatus.available,
    this.owner,
    this.takenAt,
    this.completedAt,
    this.accountedAt,
  });

  final String id;
  final ChoreDefinition chore;
  ChoreStatus status;
  String? owner;
  DateTime? takenAt;
  DateTime? completedAt;
  DateTime? accountedAt;
}

class ChronicleEvent {
  const ChronicleEvent({
    required this.actor,
    required this.message,
    required this.createdAt,
    required this.symbol,
    this.cardId,
    this.cardTitle,
  });

  final String actor;
  final String message;
  final DateTime createdAt;
  final String symbol;
  final String? cardId;
  final String? cardTitle;
}

enum PlayerLevel { bronze, silver, gold, platinum }

extension PlayerLevelData on PlayerLevel {
  String get label => switch (this) {
    PlayerLevel.bronze => 'Bronzový',
    PlayerLevel.silver => 'Stříbrný',
    PlayerLevel.gold => 'Zlatý',
    PlayerLevel.platinum => 'Platinový',
  };

  double get multiplier => switch (this) {
    PlayerLevel.bronze => 1,
    PlayerLevel.silver => 1.1,
    PlayerLevel.gold => 1.2,
    PlayerLevel.platinum => 1.3,
  };
}
