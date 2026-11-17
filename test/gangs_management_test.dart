import 'package:chore_cash/gangs_screens.dart';
import 'package:chore_cash/main.dart';
import 'package:chore_cash/mansion_store.dart';
import 'package:chore_cash/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Multi-gang management & invite links', () {
    test('users can create multiple gangs, switch between them, and keep isolated state', () {
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 12, 0));

      store.createGang(
        gangName: 'Alpha Manor',
        founderNickname: 'Hand',
        founderSex: MemberSex.male,
      );
      final alfaId = store.gang!.id;
      store.playCard(store.deck.first);
      expect(store.bankCoinsFor(store.currentMember!.id), 100);

      store.createGang(
        gangName: 'Beta Manor',
        founderNickname: 'Queen',
        founderSex: MemberSex.female,
      );
      final betaId = store.gang!.id;
      expect(store.myGangs, hasLength(2));
      expect(store.gang!.id, betaId);
      expect(store.bankCoinsFor(store.currentMember!.id), 0);

      expect(store.switchGang(alfaId), isTrue);
      expect(store.gang!.name, 'Alpha Manor');
      expect(store.bankCoinsFor(store.currentMember!.id), 100);
    });

    test('MemberSex produces accurate gendered Czech wording in default Feed', () {
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 12, 0));
      store.createGang(
        gangName: 'Manor',
        founderNickname: 'Lady',
        founderSex: MemberSex.female,
      );

      store.playCard(store.deck.first);
      expect(store.feedEntries.first.message, contains('zahrála'));
      expect(store.feedEntries.first.message, contains('uložila'));

      final req = store.requestExchange()!;
      store.approveExchange(req.id);
      expect(store.feedEntries.first.message, contains('směnila'));

      store.closeMonth();
      expect(store.feedEntries.first.message, contains('Vládkyní'));
      expect(store.feedEntries.first.message, contains('se stala'));
    });

    test('parseInviteCodeFromUri supports HTTPS query, HTTPS path, and custom scheme', () {
      expect(
        MansionStore.parseInviteCodeFromUri(
          Uri.parse('https://grim-grind.web.app/join?code=grim-42'),
        ),
        'GRIM-42',
      );
      expect(
        MansionStore.parseInviteCodeFromUri(
          Uri.parse('https://grim-grind.web.app/join/grim-77'),
        ),
        'GRIM-77',
      );
      expect(
        MansionStore.parseInviteCodeFromUri(
          Uri.parse('grimgrind://join?code=grim-99'),
        ),
        'GRIM-99',
      );
    });

    test('only owner can regenerate invite code and delete gang with exact name', () {
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 12, 0));
      store.createGang(gangName: 'Shadow Manor', founderNickname: 'Hand');
      final gangId = store.gang!.id;
      final originalCode = store.gang!.inviteCode;

      // Join as non-owner member.
      store.joinGangByCode(
        inviteCode: originalCode,
        nickname: 'Newcomer',
        sex: MemberSex.neutral,
      );
      expect(store.isOwnerOf(gangId), isFalse);
      expect(store.regenerateInviteCode(gangId), isNull);
      expect(
        store.deleteGang(gangId, confirmationName: 'Shadow Manor'),
        isFalse,
      );

      // Switch back to founder (Hand).
      store.switchActiveMember(store.gang!.founderId);
      expect(store.isOwnerOf(gangId), isTrue);

      final regenerated = store.regenerateInviteCode(gangId);
      expect(regenerated, isNotNull);
      expect(regenerated, isNot(originalCode));

      // Wrong confirmation name fails.
      expect(store.deleteGang(gangId, confirmationName: 'Wrong Name'), isFalse);
      expect(store.myGangs, hasLength(1));

      // Exact confirmation name deletes the gang.
      expect(store.deleteGang(gangId, confirmationName: 'Shadow Manor'), isTrue);
      expect(store.myGangs, isEmpty);
      expect(store.isReady, isFalse);
    });
  });

  group('Gangs UI widget flows', () {
    testWidgets('MyGangsPage -> ManageGangPage -> dangerous delete requires exact gang name', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('cs', 'CZ')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 12, 0));
      store.createGang(gangName: 'Raven Manor', founderNickname: 'Hand');

      await tester.pumpWidget(GrimGrindApp(store: store));
      await tester.pumpAndSettle();

      // Open Sídlo (Mansion) tab from bottom NavigationBar.
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Sídlo'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Raven Manor'), findsOneWidget);
      expect(find.text('AKTIVNÍ'), findsOneWidget);

      // Tap the Mansion card to open Mansion Detail & Members.
      await tester.tap(find.text('Raven Manor'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('https://grim-grind.web.app/join?code='),
        findsOneWidget,
      );
      final membersHeader = find.text('ČLENOVÉ SÍDLA (1)');
      await tester.scrollUntilVisible(
        membersHeader,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(membersHeader, findsOneWidget);

      // Tap Delete Mansion -> confirmation dialog.
      final deleteBtn = find.text('Smazat Sídlo');
      await tester.scrollUntilVisible(
        deleteBtn,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();
      expect(find.text('Opravdu smazat Sídlo?'), findsOneWidget);

      // Typing wrong name keeps button disabled.
      await tester.enterText(find.byType(TextField).last, 'Something Else');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trvale smazat'));
      await tester.pumpAndSettle();
      expect(store.myGangs, hasLength(1));

      // Typing exact name deletes the Mansion and returns to onboarding.
      await tester.enterText(find.byType(TextField).last, 'Raven Manor');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trvale smazat'));
      await tester.pumpAndSettle();

      expect(store.myGangs, isEmpty);
      expect(find.text('Vstup do Sídla'), findsOneWidget);
    });

    testWidgets('AcceptInviteDialog collects Nickname and Sex when joining by code', (
      tester,
    ) async {
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 12, 0));
      store.createGang(gangName: 'Rose Manor', founderNickname: 'Hand');
      final code = store.gang!.inviteCode;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showAcceptInviteDialog(
                    context,
                    store,
                    initialCodeOrLink: code,
                  ),
                  child: const Text('Open Invite'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Invite'));
      await tester.pumpAndSettle();

      expect(find.text('Pozvánka do: Rose Manor'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'Morticia');
      await tester.tap(find.text('Žena'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Připojit se'));
      await tester.pumpAndSettle();

      expect(store.currentMember!.nickname, 'Morticia');
      expect(store.currentMember!.sex, MemberSex.female);
    });

    testWidgets('Mansion tab updates Nickname & Sex and allows leaving a Mansion', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 12, 0));
      store.createGang(gangName: 'First Manor', founderNickname: 'Hand');
      store.createGang(gangName: 'Second Manor', founderNickname: 'Hand');

      await tester.pumpWidget(GrimGrindApp(store: store));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Mansion'),
        ),
      );
      await tester.pumpAndSettle();

      // Update Nickname and Sex in Mansion tab.
      await tester.enterText(find.byType(TextField).first, 'Gomez');
      await tester.tap(find.text('Neutrální'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(store.currentMember!.nickname, 'Gomez');
      expect(store.currentMember!.sex, MemberSex.neutral);

      // Tap First Manor and leave it.
      await tester.tap(find.text('First Manor'));
      await tester.pumpAndSettle();
      final leaveBtn = find.text('Leave Mansion');
      await tester.scrollUntilVisible(
        leaveBtn,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(leaveBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Leave Mansion').last);
      await tester.pumpAndSettle();

      expect(store.myGangs, hasLength(1));
      expect(store.gang!.name, 'Second Manor');
    });

    testWidgets('Mansion tab shows Log Out when signed in and returns to AuthGateScreen', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final store = MansionStore(clock: () => DateTime(2026, 8, 10, 12, 0));
      await store.signInWithEmailAsync(
        email: 'morticia@addams.local',
        password: 'password123',
      );
      store.createGang(gangName: 'Addams Manor', founderNickname: 'Morticia');

      await tester.pumpWidget(GrimGrindApp(store: store));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Mansion'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('morticia@addams.local'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);

      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      expect(find.text('Log Out?'), findsOneWidget);
      await tester.tap(find.text('Log Out').last);
      await tester.pumpAndSettle();

      expect(store.isSignedIn, isFalse);
      expect(store.authUserEmail, isNull);
      expect(store.myGangs, isEmpty);
      expect(store.isReady, isFalse);
      expect(find.text('MANSION GATE'), findsOneWidget);
    });

    testWidgets('Mansion tab hides Log Out when not signed in', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final store = MansionStore(
        seedDemo: true,
        clock: () => DateTime(2026, 8, 10, 12, 0),
      );

      await tester.pumpWidget(GrimGrindApp(store: store));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Mansion'),
        ),
      );
      await tester.pumpAndSettle();

      expect(store.isSignedIn, isFalse);
      expect(find.text('Log Out'), findsNothing);
    });
  });
}
