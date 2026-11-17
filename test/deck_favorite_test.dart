import 'package:chore_cash/main.dart';
import 'package:chore_cash/mansion_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('toggling favorite icon moves card to top and back without playing', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('cs', 'CZ')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    final store = MansionStore(clock: () => DateTime(2026, 8, 2));
    store.completeIntro();
    store.createGang(
      gangName: 'Sídlo testů',
      founderNickname: 'Robert',
    );

    await tester.pumpWidget(GrimGrindApp(store: store));
    await tester.pumpAndSettle();

    // Open Deck
    await tester.tap(find.text('Zahrát kartu'));
    await tester.pumpAndSettle();

    final secondChore = store.deck[1];
    final firstChore = store.deck[0];

    // Initially, firstChore is above secondChore
    expect(
      tester.getTopLeft(find.byKey(ValueKey(firstChore.id))).dx <=
          tester.getTopLeft(find.byKey(ValueKey(secondChore.id))).dx,
      isTrue,
    );

    // Toggle favorite on the second chore card
    final favButtonOnSecond = find.descendant(
      of: find.byKey(ValueKey(secondChore.id)),
      matching: find.byIcon(Icons.favorite_border_rounded),
    );
    expect(favButtonOnSecond, findsOneWidget);
    await tester.tap(favButtonOnSecond);
    await tester.pumpAndSettle();

    // Bottom sheet should NOT have opened
    expect(find.textContaining('Zahrát kartu (+'), findsNothing);
    expect(store.isFavoriteChore(secondChore.id), isTrue);

    // Icon should now be filled favorite_rounded and card should be at the first position
    final filledFavOnSecond = find.descendant(
      of: find.byKey(ValueKey(secondChore.id)),
      matching: find.byIcon(Icons.favorite_rounded),
    );
    expect(filledFavOnSecond, findsOneWidget);

    final secondPos = tester.getTopLeft(find.byKey(ValueKey(secondChore.id)));
    final firstPos = tester.getTopLeft(find.byKey(ValueKey(firstChore.id)));
    expect(
      secondPos.dy < firstPos.dy ||
          (secondPos.dy == firstPos.dy && secondPos.dx < firstPos.dx),
      isTrue,
    );

    // Toggle favorite OFF
    await tester.tap(filledFavOnSecond);
    await tester.pumpAndSettle();

    expect(store.isFavoriteChore(secondChore.id), isFalse);
    expect(
      find.descendant(
        of: find.byKey(ValueKey(secondChore.id)),
        matching: find.byIcon(Icons.favorite_border_rounded),
      ),
      findsOneWidget,
    );
  });
}
