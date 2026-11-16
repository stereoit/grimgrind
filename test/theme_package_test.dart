import 'package:chore_cash/gangs_screens.dart';
import 'package:chore_cash/mansion_store.dart';
import 'package:chore_cash/models.dart';
import 'package:chore_cash/theme_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemePackage & ThemeRegistry', () {
    test('defaults to Gothic Mansion automatically', () {
      expect(ThemeRegistry.defaultThemeId, 'gothic_mansion');
      expect(ThemeRegistry.resolve(null).id, 'gothic_mansion');
      expect(ThemeRegistry.resolve('non_existent').id, 'gothic_mansion');

      final store = MansionStore();
      store.createGang(
        gangName: 'Sídlo stínů',
        founderNickname: 'Dark Lord',
      );

      expect(store.gang!.themeId, 'gothic_mansion');
      expect(store.activeTheme.id, 'gothic_mansion');
      expect(store.activeTheme.displayName, 'Gothic Mansion');
    });

    test('Gothic Mansion package provides complete card & tier definitions', () {
      final gothic = ThemeRegistry.gothicMansion;
      expect(gothic.onboardingSlides.length, 3);

      for (final chore in choreCatalog) {
        expect(gothic.cardAssetPath(chore.id), 'assets/cards/${chore.id}.png');
      }
      for (final diff in ChoreDifficulty.values) {
        expect(gothic.difficultyColors.containsKey(diff), isTrue);
        expect(gothic.difficultyLabels[diff], isNotEmpty);
      }
      for (final level in MonthlyLevel.values) {
        expect(gothic.monthlyLevelLabels[level], isNotEmpty);
        expect(gothic.monthlyLevelCallouts[level], isNotEmpty);
      }
      for (final heat in HeatLevel.values) {
        expect(gothic.heatColors.containsKey(heat), isTrue);
        expect(gothic.heatIcons.containsKey(heat), isTrue);
        expect(gothic.heatLevelLabels[heat], isNotEmpty);
      }
    });

    test('only owner can update gang theme and unknown themes are rejected', () {
      final store = MansionStore();
      store.createGang(
        gangName: 'Sídlo stínů',
        founderNickname: 'Dark Lord',
      );
      final gang = store.gang!;
      final inviteCode = gang.inviteCode;

      // Owner can set valid theme
      expect(store.isOwnerOf(gang.id), isTrue);
      expect(store.updateGangTheme(gang.id, 'gothic_mansion'), isTrue);

      // Unknown theme is rejected even for owner
      expect(store.updateGangTheme(gang.id, 'cyberpunk_2099'), isFalse);

      // Non-owner cannot change theme
      store.joinGangByCode(inviteCode: inviteCode, nickname: 'Shadow');
      expect(store.isOwnerOf(gang.id), isFalse);
      expect(store.updateGangTheme(gang.id, 'gothic_mansion'), isFalse);
    });

    testWidgets('ManageGangPage displays Theme Package card with Gothic Mansion',
        (tester) async {
      final store = MansionStore();
      store.createGang(
        gangName: 'Sídlo stínů',
        founderNickname: 'Dark Lord',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ManageGangPage(store: store, gangId: store.gang!.id),
        ),
      );

      await tester.scrollUntilVisible(
        find.text('TÉMA / MOTIV GANGU'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('TÉMA / MOTIV GANGU'), findsOneWidget);
      expect(find.text('Gothic Mansion'), findsOneWidget);
    });
  });
}
