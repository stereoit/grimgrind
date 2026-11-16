import 'package:chore_cash/main.dart';
import 'package:chore_cash/mansion_store.dart';
import 'package:chore_cash/update_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UpdateInfo.fromFirestoreMap parses Android and iOS fields', () {
    final data = <String, dynamic>{
      'latestBuildNumber': 42,
      'latestVersion': '1.0.2',
      'androidBuildNumber': 44,
      'androidVersion': '1.0.3',
      'androidUrl': 'https://appdistribution.firebase.dev/android',
      'iosBuildNumber': 43,
      'iosVersion': '1.0.3-ios',
      'iosUrl': 'https://appdistribution.firebase.dev/ios',
      'releaseNotes': 'Oprava notifikací',
    };

    final androidInfo = UpdateInfo.fromFirestoreMap(
      data,
      TargetPlatform.android,
    );
    expect(androidInfo, isNotNull);
    expect(androidInfo!.latestBuildNumber, 44);
    expect(androidInfo.latestVersion, '1.0.3');
    expect(
      androidInfo.downloadUrl,
      'https://appdistribution.firebase.dev/android',
    );
    expect(androidInfo.releaseNotes, 'Oprava notifikací');

    final iosInfo = UpdateInfo.fromFirestoreMap(data, TargetPlatform.iOS);
    expect(iosInfo, isNotNull);
    expect(iosInfo!.latestBuildNumber, 43);
    expect(iosInfo.latestVersion, '1.0.3-ios');
    expect(iosInfo.downloadUrl, 'https://appdistribution.firebase.dev/ios');
  });

  testWidgets('MansionShell shows non-intrusive UpdateBanner and handles actions', (
    tester,
  ) async {
    final store = MansionStore(clock: () => DateTime(2026, 7, 29, 12, 0));
    store.createGang(
      gangName: 'Sídlo',
      founderNickname: 'Ruka',
      coinsPerCzk: 10,
    );

    String? launchedUrl;
    final updateService = DistributionUpdateService(
      customFetcher: () async => const UpdateCheckResult(
        info: UpdateInfo(
          latestBuildNumber: 99,
          latestVersion: '1.1.0',
          releaseNotes: 'Nový build pro domácnost',
          downloadUrl: 'https://appdistribution.firebase.dev',
        ),
        currentBuildNumber: 12,
        currentVersion: '1.0.0',
      ),
      customLauncher: (url) async {
        launchedUrl = url;
        return true;
      },
    );

    tester.platformDispatcher.localesTestValue = const [Locale('cs', 'CZ')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      GrimGrindApp(store: store, updateService: updateService),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nová verze 1.1.0 (#99)'), findsOneWidget);
    expect(find.text('Nový build pro domácnost'), findsOneWidget);

    await tester.tap(find.text('Aktualizovat'));
    await tester.pumpAndSettle();
    expect(launchedUrl, 'https://appdistribution.firebase.dev');

    await tester.tap(find.text('Později'));
    await tester.pumpAndSettle();
    expect(find.text('Nová verze 1.1.0 (#99)'), findsNothing);
  });
}
