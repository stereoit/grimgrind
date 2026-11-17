import 'package:chore_cash/main.dart';
import 'package:chore_cash/mansion_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('onboarding leads into sample mansion feed, deck, bank and leaderboard', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('cs', 'CZ')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final store = MansionStore(clock: () => DateTime(2026, 7, 29, 12, 0));
    await tester.pumpWidget(GrimGrindApp(store: store));
    await tester.pumpAndSettle();

    // Step 1: Intro card 1
    expect(find.text('Sdílený Deck Sídla'), findsOneWidget);
    await tester.tap(find.text('Přeskočit'));
    await tester.pumpAndSettle();

    // Step 2: Login / Signup gate ("Brána do Sídla")
    expect(find.text('BRÁNA DO SÍDLA'), findsOneWidget);
    final guestButton = find.text('Pokračovat anonymně jako host');
    await tester.scrollUntilVisible(
      guestButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(guestButton);
    await tester.pumpAndSettle();

    // Step 3: Create Avatar
    expect(find.text('STVOŘENÍ AVATARA'), findsOneWidget);
    await tester.tap(find.text('Pokračovat do Sídla'));
    await tester.pumpAndSettle();

    // Step 4: Mansion setup
    expect(find.text('Vstup do Sídla'), findsOneWidget);
    final createButton = find.text('Založit Sídlo a stát se Rukou');
    await tester.scrollUntilVisible(
      createButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    // Main Feed with Month Proclamation divider
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Zahrát kartu'), findsOneWidget);

    // Open Deck from Feed's "Zahrát kartu" FAB and play a card
    await tester.tap(find.text('Zahrát kartu'));
    await tester.pumpAndSettle();
    expect(find.text('Vyber splněnou kartu'), findsOneWidget);
    expect(find.text('Vynést koš'), findsOneWidget);

    await tester.tap(find.text('Vynést koš'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Zahrát kartu (+'));
    await tester.pumpAndSettle();
    expect(store.bankCoinsFor(store.currentMember!.id), greaterThan(0));

    // Deck automatically closes back to Chronicle after playing a card
    expect(find.byType(NavigationBar), findsOneWidget);

    // Open Pouch (Mešec in Czech)
    await tester.tap(find.text('Mešec'));
    await tester.pumpAndSettle();
    expect(find.text('Mešec & Směna u Ruky'), findsOneWidget);
    expect(find.textContaining('Požádat Ruku o směnu'), findsOneWidget);

    // Open Leaderboard
    await tester.tap(find.text('Žebříček'));
    await tester.pumpAndSettle();
    expect(find.text('Leaderboard Hráčů'), findsOneWidget);
    expect(find.text('Most Active'), findsOneWidget);
  });
}
