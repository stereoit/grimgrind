import 'package:flutter/foundation.dart';

import 'models.dart';

class MansionStore extends ChangeNotifier {
  MansionStore({DateTime Function()? clock}) : _clock = clock ?? DateTime.now {
    cards = choreCatalog
        .map((chore) => ChoreCard(id: chore.id, chore: chore))
        .toList();
    events = [
      ChronicleEvent(
        actor: 'Sídlo',
        message: 'Karty byly rozloženy. Sídlo čeká na první tah.',
        createdAt: _clock().subtract(const Duration(hours: 2)),
        symbol: '♜',
      ),
    ];
  }

  final DateTime Function() _clock;
  String nickname = 'Dark Lord';
  PlayerLevel level = PlayerLevel.bronze;
  late final List<ChoreCard> cards;
  late final List<ChronicleEvent> events;

  Iterable<ChoreCard> get availableCards =>
      cards.where((card) => card.status == ChoreStatus.available);

  Iterable<ChoreCard> get tableCards =>
      cards.where((card) => card.status == ChoreStatus.assigned);

  Iterable<ChoreCard> get myActiveCards =>
      tableCards.where((card) => card.owner == nickname);

  Iterable<ChoreCard> get awaitingApproval => cards.where(
    (card) => card.owner == nickname && card.status == ChoreStatus.completed,
  );

  int get awaitingBaseReward =>
      awaitingApproval.fold(0, (total, card) => total + card.chore.reward);

  int get awaitingReward => (awaitingBaseReward * level.multiplier).round();

  Iterable<ChoreCard> get personalDeck => cards.where(
    (card) =>
        card.owner == nickname &&
        (card.status == ChoreStatus.completed ||
            card.status == ChoreStatus.approved ||
            card.status == ChoreStatus.paid),
  );

  int get monthBaseReward =>
      personalDeck.fold(0, (total, card) => total + card.chore.reward);

  int get monthReward => (monthBaseReward * level.multiplier).round();

  void setNickname(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == nickname) return;
    final oldNickname = nickname;
    nickname = trimmed;
    for (final card in cards.where((card) => card.owner == oldNickname)) {
      card.owner = nickname;
    }
    _record('změnil své jméno v kronice.', '✦');
  }

  bool takeCard(ChoreCard card) {
    if (card.status != ChoreStatus.available || !_withinWeeklyLimit(card)) {
      return false;
    }
    card
      ..status = ChoreStatus.assigned
      ..owner = nickname
      ..takenAt = _clock();
    _record(
      'rozehrál kartu „${card.chore.title}“ na společný stůl.',
      '♠',
      card: card,
    );
    return true;
  }

  void completeCard(ChoreCard card) {
    if (card.status != ChoreStatus.assigned) return;
    card
      ..status = ChoreStatus.completed
      ..completedAt = _clock();
    _record(
      'zahrál kartu „${card.chore.title}“ a dokončil úkol!',
      card.chore.symbol,
      card: card,
    );
  }

  int accountCompletedCards() {
    final completed = awaitingApproval.toList();
    if (completed.isEmpty) return 0;
    final reward = awaitingReward;
    for (final card in completed) {
      card
        ..status = ChoreStatus.approved
        ..accountedAt = _clock();
    }
    _record(
      'požádal Ruku o zúčtování ${completed.length} karet za $reward Kč.',
      '☞',
    );
    return reward;
  }

  void payMonth() {
    final payable = cards.where((card) => card.status == ChoreStatus.approved);
    if (payable.isEmpty) return;
    final paidCount = payable.length;
    for (final card in payable) {
      card
        ..status = ChoreStatus.paid
        ..accountedAt = _clock();
    }
    _record('podepsal šek na $monthReward Kč za $paidCount karet.', '☞');
  }

  bool _withinWeeklyLimit(ChoreCard card) {
    final limit = card.chore.weeklyLimit;
    if (limit == null) return true;
    final weekAgo = _clock().subtract(const Duration(days: 7));
    return cards
            .where(
              (other) =>
                  other.chore.id == card.chore.id &&
                  (other.takenAt ?? other.completedAt)?.isAfter(weekAgo) ==
                      true &&
                  other.status != ChoreStatus.available,
            )
            .length <
        limit;
  }

  void _record(String message, String symbol, {ChoreCard? card}) {
    events.insert(
      0,
      ChronicleEvent(
        actor: nickname,
        message: message,
        createdAt: _clock(),
        symbol: symbol,
        cardId: card?.chore.id,
        cardTitle: card?.chore.title,
      ),
    );
    notifyListeners();
  }
}

const choreCatalog = <ChoreDefinition>[
  ChoreDefinition(
    id: 'trash',
    title: 'Vynést koš',
    reward: 10,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 5,
  ),
  ChoreDefinition(
    id: 'shopping',
    title: 'Vyklidit nákup',
    reward: 15,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 10,
  ),
  ChoreDefinition(
    id: 'dishwasher',
    title: 'Vyklidit myčku',
    reward: 15,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 10,
  ),
  ChoreDefinition(
    id: 'laundry',
    title: 'Uklidit si prádlo',
    reward: 20,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 15,
  ),
  ChoreDefinition(
    id: 'stairs',
    title: 'Vysát schodiště',
    reward: 20,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 15,
  ),
  ChoreDefinition(
    id: 'queenie',
    title: 'Vyčesat Queenie',
    reward: 30,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 20,
  ),
  ChoreDefinition(
    id: 'toilet',
    title: 'Umýt toaletu',
    reward: 40,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 20,
  ),
  ChoreDefinition(
    id: 'dogs',
    title: 'Příprava krmení pro psy',
    reward: 35,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 20,
    note: 'Včetně nakrmení',
  ),
  ChoreDefinition(
    id: 'sport',
    title: 'Sportovní aktivita',
    reward: 35,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 30,
  ),
  ChoreDefinition(
    id: 'garden',
    title: 'Zalít zahradu',
    reward: 30,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 20,
    note: 'Lze plnit denně',
  ),
  ChoreDefinition(
    id: 'evening',
    title: 'Večerní úklid',
    reward: 45,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 35,
    note: 'Kuchyň, předsíň a obývák',
  ),
  ChoreDefinition(
    id: 'bathroom',
    title: 'Umýt koupelnu',
    reward: 60,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 40,
    note: 'Cena za jednu koupelnu',
  ),
  ChoreDefinition(
    id: 'mop',
    title: 'Vytřít parním mopem',
    reward: 50,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 35,
  ),
  ChoreDefinition(
    id: 'ironing',
    title: 'Vyžehlit',
    reward: 70,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 45,
  ),
  ChoreDefinition(
    id: 'cooking',
    title: 'Uvařit jídlo',
    reward: 70,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 60,
  ),
  ChoreDefinition(
    id: 'school',
    title: 'Učení / Škola',
    reward: 60,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 45,
  ),
  ChoreDefinition(
    id: 'room',
    title: 'Vygruntovat pokojíček',
    reward: 100,
    difficulty: ChoreDifficulty.special,
    symbol: '★',
    minutes: 90,
    note: 'Dostupné jednou týdně',
    weeklyLimit: 1,
  ),
];
