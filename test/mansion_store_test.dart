import 'package:chore_cash/mansion_store.dart';
import 'package:chore_cash/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('card follows the complete approval flow', () {
    final store = MansionStore(clock: () => DateTime(2026, 7, 29));
    final card = store.cards.first;

    expect(store.requestCard(card), isTrue);
    expect(card.status, ChoreStatus.requested);

    store.setRole(MansionRole.servant);
    store.issueCard(card);
    expect(card.status, ChoreStatus.assigned);

    store.setRole(MansionRole.player);
    store.completeCard(card);
    expect(card.status, ChoreStatus.completed);

    store.setRole(MansionRole.hand);
    store.approveCard(card);
    expect(card.status, ChoreStatus.approved);
    expect(store.monthReward, 10);
    expect(store.events.first.message, contains('schválil kartu'));
  });
}
