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
        message: 'Karty byly rozloženy. Dům čeká na své služebníky.',
        createdAt: _clock().subtract(const Duration(hours: 2)),
        symbol: '♜',
      ),
    ];
  }

  final DateTime Function() _clock;
  String nickname = 'Dark Lord';
  MansionRole role = MansionRole.player;
  PlayerLevel level = PlayerLevel.bronze;
  late final List<ChoreCard> cards;
  late final List<ChronicleEvent> events;

  Iterable<ChoreCard> get availableCards =>
      cards.where((card) => card.status == ChoreStatus.available);

  Iterable<ChoreCard> get pendingRequests =>
      cards.where((card) => card.status == ChoreStatus.requested);

  Iterable<ChoreCard> get assignedCards => cards.where(
    (card) => card.owner == nickname && card.status == ChoreStatus.assigned,
  );

  Iterable<ChoreCard> get awaitingApproval =>
      cards.where((card) => card.status == ChoreStatus.completed);

  Iterable<ChoreCard> get personalDeck => cards.where(
    (card) =>
        card.owner == nickname &&
        (card.status == ChoreStatus.approved ||
            card.status == ChoreStatus.paid),
  );

  int get monthBaseReward =>
      personalDeck.fold(0, (total, card) => total + card.chore.reward);

  int get monthReward => (monthBaseReward * level.multiplier).round();

  void setRole(MansionRole value) {
    role = value;
    notifyListeners();
  }

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

  bool requestCard(ChoreCard card) {
    if (card.status != ChoreStatus.available || !_withinWeeklyLimit(card)) {
      return false;
    }
    card
      ..status = ChoreStatus.requested
      ..owner = nickname
      ..updatedAt = _clock();
    _record('požádal o kartu „${card.chore.title}“.', '♠');
    return true;
  }

  void issueCard(ChoreCard card) {
    if (card.status != ChoreStatus.requested) return;
    card
      ..status = ChoreStatus.assigned
      ..updatedAt = _clock();
    _record('vydal kartu „${card.chore.title}“ hráči ${card.owner}.', '♟');
  }

  void completeCard(ChoreCard card) {
    if (card.status != ChoreStatus.assigned) return;
    card
      ..status = ChoreStatus.completed
      ..updatedAt = _clock();
    _record('dokončil úkol „${card.chore.title}“!', card.chore.symbol);
  }

  void approveCard(ChoreCard card) {
    if (card.status != ChoreStatus.completed) return;
    card
      ..status = ChoreStatus.approved
      ..updatedAt = _clock();
    _record(
      'schválil kartu „${card.chore.title}“ pro hráče ${card.owner}.',
      '☞',
    );
  }

  void payMonth() {
    final payable = cards.where((card) => card.status == ChoreStatus.approved);
    if (payable.isEmpty) return;
    final paidCount = payable.length;
    for (final card in payable) {
      card
        ..status = ChoreStatus.paid
        ..updatedAt = _clock();
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
                  other.updatedAt?.isAfter(weekAgo) == true &&
                  other.status != ChoreStatus.available,
            )
            .length <
        limit;
  }

  void _record(String message, String symbol) {
    events.insert(
      0,
      ChronicleEvent(
        actor: nickname,
        message: message,
        createdAt: _clock(),
        symbol: symbol,
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
  ),
  ChoreDefinition(
    id: 'shopping',
    title: 'Vyklidit nákup',
    reward: 15,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
  ),
  ChoreDefinition(
    id: 'dishwasher',
    title: 'Vyklidit myčku',
    reward: 15,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
  ),
  ChoreDefinition(
    id: 'laundry',
    title: 'Uklidit si prádlo',
    reward: 20,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
  ),
  ChoreDefinition(
    id: 'stairs',
    title: 'Vysát schodiště',
    reward: 20,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
  ),
  ChoreDefinition(
    id: 'queenie',
    title: 'Vyčesat Queenie',
    reward: 30,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
  ),
  ChoreDefinition(
    id: 'toilet',
    title: 'Umýt toaletu',
    reward: 40,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
  ),
  ChoreDefinition(
    id: 'dogs',
    title: 'Příprava krmení pro psy',
    reward: 35,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    note: 'Včetně nakrmení',
  ),
  ChoreDefinition(
    id: 'sport',
    title: 'Sportovní aktivita',
    reward: 35,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
  ),
  ChoreDefinition(
    id: 'garden',
    title: 'Zalít zahradu',
    reward: 30,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    note: 'Lze plnit denně',
  ),
  ChoreDefinition(
    id: 'evening',
    title: 'Večerní úklid',
    reward: 45,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    note: 'Kuchyň, předsíň a obývák',
  ),
  ChoreDefinition(
    id: 'bathroom',
    title: 'Umýt koupelnu',
    reward: 60,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    note: 'Cena za jednu koupelnu',
  ),
  ChoreDefinition(
    id: 'mop',
    title: 'Vytřít parním mopem',
    reward: 50,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
  ),
  ChoreDefinition(
    id: 'ironing',
    title: 'Vyžehlit',
    reward: 70,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
  ),
  ChoreDefinition(
    id: 'cooking',
    title: 'Uvařit jídlo',
    reward: 70,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
  ),
  ChoreDefinition(
    id: 'school',
    title: 'Učení / Škola',
    reward: 60,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
  ),
  ChoreDefinition(
    id: 'room',
    title: 'Vygruntovat pokojíček',
    reward: 100,
    difficulty: ChoreDifficulty.special,
    symbol: '★',
    note: 'Dostupné jednou týdně',
    weeklyLimit: 1,
  ),
];
