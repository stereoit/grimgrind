import 'package:chore_cash/main.dart';
import 'package:chore_cash/mansion_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('onboarding leads into sample mansion feed, deck, bank and leaderboard', (
    tester,
  ) async {
    final store = MansionStore(clock: () => DateTime(2026, 7, 29, 12, 0));
    await tester.pumpWidget(GrimGrindApp(store: store));
    await tester.pumpAndSettle();

    // Step 1: Intro card 1
    expect(find.text('Sdílený Deck Sídla'), findsOneWidget);
    await tester.tap(find.text('Přeskočit'));
    await tester.pumpAndSettle();

    // Step 2: Gang setup
    expect(find.text('Vstup do Gangu'), findsOneWidget);
    final createButton = find.text('Založit Gang a stát se Rukou');
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

    // Open Deck and play a card
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Deck'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Vyber splněnou kartu'), findsOneWidget);
    expect(find.text('Vynést koš'), findsOneWidget);

    await tester.tap(find.text('Vynést koš'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Zahrát kartu (+'));
    await tester.pumpAndSettle();
    expect(store.bankCoinsFor(store.currentMember!.id), greaterThan(0));

    // Open Bank
    await tester.tap(find.text('Bank'));
    await tester.pumpAndSettle();
    expect(find.text('Bank & Směna u Ruky'), findsOneWidget);
    expect(find.textContaining('Požádat Ruku o směnu'), findsOneWidget);

    // Open Leaderboard
    await tester.tap(find.text('Žebříček'));
    await tester.pumpAndSettle();
    expect(find.text('Leaderboard Hráčů'), findsOneWidget);
    expect(find.text('Most Active'), findsOneWidget);
  });
}
