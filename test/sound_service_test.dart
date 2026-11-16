import 'package:chore_cash/main.dart';
import 'package:chore_cash/mansion_store.dart';
import 'package:chore_cash/sound_service.dart';
import 'package:chore_cash/theme_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSoundBackend implements SoundBackend {
  final List<String> effectsPlayed = <String>[];
  final List<String> loopsStarted = <String>[];
  int stopLoopCalls = 0;

  @override
  Future<void> playEffect(String assetPath, {double volume = 1.0}) async {
    effectsPlayed.add(assetPath);
  }

  @override
  Future<void> playLoop(String assetPath, {double volume = 0.45}) async {
    loopsStarted.add(assetPath);
  }

  @override
  Future<void> stopLoop() async {
    stopLoopCalls++;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  late FakeSoundBackend fakeBackend;

  setUp(() {
    fakeBackend = FakeSoundBackend();
    SoundService.instance.resetForTesting();
    SoundService.instance.setBackendForTesting(fakeBackend);
  });

  tearDown(() {
    SoundService.instance.resetForTesting();
  });

  group('SoundService', () {
    test('plays theme-bundled SFX and intro music loop', () async {
      final pack = ThemeRegistry.gothicMansion.soundPack;

      await SoundService.instance.startIntroMusic();
      await SoundService.instance.startIntroMusic(); // idempotent
      expect(fakeBackend.loopsStarted, [pack.introMusic]);

      await SoundService.instance.playOpenDeck();
      await SoundService.instance.playCard();
      await SoundService.instance.playConvertCoins();
      await SoundService.instance.playButtonTap();

      expect(fakeBackend.effectsPlayed, [
        pack.openDeck,
        pack.playCard,
        pack.convertCoins,
        pack.buttonTap,
      ]);

      await SoundService.instance.stopIntroMusic();
      expect(fakeBackend.stopLoopCalls, 1);
    });

    test('muting stops intro music and suppresses sound effects', () async {
      await SoundService.instance.startIntroMusic();
      await SoundService.instance.setMuted(true);

      expect(fakeBackend.stopLoopCalls, 1);

      await SoundService.instance.playButtonTap();
      await SoundService.instance.playCard();
      expect(fakeBackend.effectsPlayed, isEmpty);
    });
  });

  group('Sound integration in UI', () {
    testWidgets('intro plays background music and button taps, stops on skip',
        (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('cs', 'CZ')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final store = MansionStore();
      final pack = ThemeRegistry.gothicMansion.soundPack;

      await tester.pumpWidget(GrimGrindApp(store: store));
      await tester.pump();

      expect(fakeBackend.loopsStarted, [pack.introMusic]);

      await tester.tap(find.text('Další karta pravidel'));
      await tester.pumpAndSettle();
      expect(fakeBackend.effectsPlayed, contains(pack.buttonTap));

      await tester.tap(find.text('Přeskočit'));
      await tester.pumpAndSettle();
      expect(fakeBackend.stopLoopCalls, greaterThanOrEqualTo(1));
    });

    testWidgets(
        'opening deck, playing card, and converting coins trigger theme sounds',
        (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('cs', 'CZ')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final store = MansionStore()..startSampleMansion();
      final pack = ThemeRegistry.gothicMansion.soundPack;

      await tester.pumpWidget(GrimGrindApp(store: store));
      await tester.pumpAndSettle();

      // 1. Open Deck via FAB
      await tester.tap(find.text('Zahrát kartu'));
      await tester.pumpAndSettle();
      expect(fakeBackend.effectsPlayed, contains(pack.openDeck));

      // 2. Tap a card (button tap) & confirm playing it (play card)
      await tester.tap(find.text(choreCatalog.first.title).first);
      await tester.pumpAndSettle();
      expect(fakeBackend.effectsPlayed, contains(pack.buttonTap));

      await tester.tap(find.text('Zahrát kartu (+'));
      await tester.pumpAndSettle();
      expect(fakeBackend.effectsPlayed, contains(pack.playCard));

      // 3. Switch to Pouch/Bank tab (button tap) & request coin conversion
      await tester.tap(find.text('Mešec'));
      await tester.pumpAndSettle();
      expect(
        fakeBackend.effectsPlayed.where((e) => e == pack.buttonTap).length,
        greaterThanOrEqualTo(2),
      );

      final requestBtn = find.textContaining('Požádat Ruku o směnu');
      expect(requestBtn, findsOneWidget);
      await tester.tap(requestBtn);
      await tester.pumpAndSettle();
      expect(fakeBackend.effectsPlayed, contains(pack.convertCoins));
    });
  });
}
