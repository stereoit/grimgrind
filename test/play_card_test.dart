import 'package:chore_cash/features/mansion/mansion_shell.dart';
import 'package:chore_cash/mansion_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('completing a card updates chronicle, catalog, and personal deck',
      (tester) async {
    final store = MansionStore(clock: () => DateTime(2026, 8, 2));

    await tester.pumpWidget(
      MaterialApp(
        home: MansionShell(store: store),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Switch to Karty (HallPage)
    await tester.tap(find.text('Karty'));
    await tester.pumpAndSettle();

    // 2. Tap on the first card (e.g. Vynést koš)
    final cardFinder = find.text('Vynést koš').first;
    expect(cardFinder, findsOneWidget);
    await tester.tap(cardFinder);
    await tester.pumpAndSettle();

    // 3. In bottom sheet, tap 'Splnit úkol'
    final completeButton = find.text('Splnit úkol (10 Kč)');
    expect(completeButton, findsOneWidget);
    await tester.tap(completeButton);
    await tester.pumpAndSettle();

    // 4. In confirmation dialog, tap 'Ano, splněno'
    final confirmButton = find.widgetWithText(FilledButton, 'Ano, splněno');
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // 5. Verify Chronicle (Kronika)
    await tester.tap(find.text('Kronika'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('splnil úkol a přidal kartu'),
      findsOneWidget,
    );

    // 6. Verify Personal Deck (Balíček)
    await tester.tap(find.text('Balíček'));
    await tester.pumpAndSettle();
    expect(find.text('Vynést koš'), findsWidgets);
  });
}
