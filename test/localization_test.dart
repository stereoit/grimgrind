import 'package:chore_cash/app_strings.dart';
import 'package:chore_cash/main.dart';
import 'package:chore_cash/mansion_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppStrings localization by phone language', () {
    test('resolveLocale selects Czech for cs and falls back to English otherwise', () {
      expect(
        AppStrings.resolveLocale(const Locale('cs', 'CZ'), AppStrings.supportedLocales),
        const Locale('cs'),
      );
      expect(
        AppStrings.resolveLocale(const Locale('en', 'US'), AppStrings.supportedLocales),
        const Locale('en'),
      );
      expect(
        AppStrings.resolveLocale(const Locale('de', 'DE'), AppStrings.supportedLocales),
        const Locale('en'),
      );
      expect(
        AppStrings.resolveLocale(null, AppStrings.supportedLocales),
        const Locale('en'),
      );
    });

    testWidgets('uses English when phone locale is en_US', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      final store = MansionStore()..startSampleMansion();
      await tester.pumpWidget(GrimGrindApp(store: store));
      await tester.pumpAndSettle();

      expect(find.text('Chronicle'), findsOneWidget);
      expect(find.text('Pouch'), findsOneWidget);
      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('Mansion'), findsOneWidget);
      expect(find.text('Play Card'), findsOneWidget);

      await tester.tap(find.text('Pouch'));
      await tester.pumpAndSettle();
      expect(find.text('Pouch & Hand Exchange'), findsOneWidget);
    });

    testWidgets('uses Czech (Mešec, Kronika, etc.) when phone locale is cs_CZ',
        (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('cs', 'CZ')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      final store = MansionStore()..startSampleMansion();
      await tester.pumpWidget(GrimGrindApp(store: store));
      await tester.pumpAndSettle();

      expect(find.text('Kronika'), findsOneWidget);
      expect(find.text('Mešec'), findsOneWidget);
      expect(find.text('Žebříček'), findsOneWidget);
      expect(find.text('Sídlo'), findsOneWidget);
      expect(find.text('Zahrát kartu'), findsOneWidget);

      await tester.tap(find.text('Mešec'));
      await tester.pumpAndSettle();
      expect(find.text('Mešec & Směna u Ruky'), findsOneWidget);
    });
  });
}
