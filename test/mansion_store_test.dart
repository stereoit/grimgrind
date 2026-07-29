import 'package:chore_cash/mansion_store.dart';
import 'package:chore_cash/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('card is taken directly and accounted by the Hand', () {
    final store = MansionStore(clock: () => DateTime(2026, 7, 29));
    final card = store.cards.first;

    expect(store.takeCard(card), isTrue);
    expect(card.status, ChoreStatus.assigned);

    store.completeCard(card);
    expect(card.status, ChoreStatus.completed);
    expect(store.personalDeck, contains(card));
    expect(store.events.first.message, contains('zahrál kartu'));
    expect(store.events.first.cardId, card.chore.id);

    expect(store.accountCompletedCards(), 10);
    expect(card.status, ChoreStatus.approved);
    expect(store.monthReward, 10);
    expect(store.events.first.message, contains('Ruku o zúčtování'));
  });
}
