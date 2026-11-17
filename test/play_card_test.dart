import 'package:chore_cash/main.dart';
import 'package:chore_cash/mansion_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'completing a card updates chronicle, deck, and bank',
      (tester) async {
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

    // 1. Open Deck via the "Zahrát kartu" FAB
    await tester.tap(find.text('Zahrát kartu'));
    await tester.pumpAndSettle();

    // 2. Tap on the first chore card (Vynést koš)
    final cardFinder = find.text('Vynést koš').first;
    expect(cardFinder, findsOneWidget);
    await tester.tap(cardFinder);
    await tester.pumpAndSettle();

    // 3. In bottom sheet, tap 'Zahrát kartu (+'
    final playButton = find.textContaining('Zahrát kartu (+');
    expect(playButton, findsOneWidget);
    await tester.tap(playButton);
    await tester.pumpAndSettle();

    // 4. Verify Chronicle (Kronika) shows the played card
    expect(find.text('Vynést koš'), findsWidgets);

    // 5. Switch to Pouch (Mešec) and verify the played card is listed
    await tester.tap(find.text('Mešec'));
    await tester.pumpAndSettle();
    expect(find.text('Vynést koš'), findsWidgets);
  });
}
