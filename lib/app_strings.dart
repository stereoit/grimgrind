import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'theme_package.dart';

/// Localized UI copy for GrimGrind supporting English (`en`) and Czech (`cs`).
///
/// Automatically follows the user's phone locale via [MaterialApp.supportedLocales]
/// and [localeResolutionCallback], falling back to English when the device
/// language is not Czech.
class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  bool get isCs => locale.languageCode == 'cs';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('cs'),
  ];

  static Locale resolveLocale(
    Locale? deviceLocale,
    Iterable<Locale> supported,
  ) {
    if (deviceLocale != null && deviceLocale.languageCode == 'cs') {
      return const Locale('cs');
    }
    return const Locale('en');
  }

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static AppStrings of(BuildContext context) {
    final localized = Localizations.of<AppStrings>(context, AppStrings);
    if (localized != null) return localized;
    final fallbackLocale =
        Localizations.maybeLocaleOf(context) ?? const Locale('en');
    return AppStrings(fallbackLocale);
  }

  // ---------------------------------------------------------------------------
  // Navigation & Top-Level Tabs
  // ---------------------------------------------------------------------------
  String get navChronicle => isCs ? 'Kronika' : 'Chronicle';
  String get navPouch => isCs ? 'Mešec' : 'Pouch';
  String get navLeaderboard => isCs ? 'Žebříček' : 'Leaderboard';
  String get navProfile => isCs ? 'Profil' : 'Profile';

  String get deckTitle => isCs ? 'Kniha karet' : 'Deck';
  String get playCardFab => isCs ? 'Zahrát kartu' : 'Play Card';

  // ---------------------------------------------------------------------------
  // Onboarding Intro
  // ---------------------------------------------------------------------------
  String get skip => isCs ? 'Přeskočit' : 'Skip';
  String get nextRuleCard =>
      isCs ? 'Další karta pravidel' : 'Next Rule Card';
  String get enterMansion =>
      isCs ? 'Vstoupit do Sídla' : 'Enter the Mansion';

  List<ThemeOnboardingSlide> onboardingSlidesFor(GameThemePackage theme) {
    if (isCs) return theme.onboardingSlides;
    return [
      ThemeOnboardingSlide(
        eyebrow: 'RULE I • BOOK OF CARDS',
        title: 'Shared Mansion Deck',
        text:
            'The entire household draws from the same book of 17 chores. No locking or waiting — as soon as you finish a chore, play the card straight into the Chronicle.',
        imageAsset: theme.onboardingSlides[0].imageAsset,
      ),
      ThemeOnboardingSlide(
        eyebrow: 'RULE II • COINS, LEVEL & HEAT',
        title: 'Blazing Reward Multipliers',
        text:
            'Play cards throughout the month to rise from Awakened to Godlike. Playing regularly stokes your Heat, which cools down when you slack off.',
        imageAsset: theme.onboardingSlides[1].imageAsset,
      ),
      ThemeOnboardingSlide(
        eyebrow: 'RULE III • THE HAND & LEADERBOARD',
        title: 'Exchange Pouch & Rule the Mansion',
        text:
            'Coins drop into your Pouch. Ask The Hand (Founder) to exchange them for real money anytime. Only approved exchanges count toward the Leaderboard!',
        imageAsset: theme.onboardingSlides[2].imageAsset,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Auth Gate & Email Verification & Avatar & Gang Setup
  // ---------------------------------------------------------------------------
  String get authEyebrow => isCs ? 'BRÁNA DO SÍDLA' : 'MANSION GATE';
  String get authLoginTitle => isCs ? 'Přihlášení' : 'Sign In';
  String get authRegisterTitle => isCs ? 'Registrace' : 'Create Account';
  String get authEmailLabel => isCs ? 'E-mail' : 'Email';
  String get authPasswordLabel => isCs ? 'Heslo' : 'Password';
  String get authSignInBtn =>
      isCs ? 'Vstoupit do Sídla' : 'Enter the Mansion';
  String get authCreateAccountBtn =>
      isCs ? 'Vytvořit účet' : 'Create Account';
  String get authVerifyingSeal =>
      isCs ? 'Ověřuji pečeť...' : 'Verifying seal...';
  String get authOr => isCs ? 'NEBO' : 'OR';
  String get authContinueGoogle =>
      isCs ? 'Pokračovat přes Google' : 'Continue with Google';
  String get authContinueGuest =>
      isCs ? 'Pokračovat anonymně jako host' : 'Continue as Guest';

  String get verifyEmailTitle =>
      isCs ? 'Ověř svůj e-mail' : 'Verify Your Email';
  String verifyEmailBody(String email) => isCs
      ? 'Na adresu $email jsme odeslali ověřovací odkaz. Potvrď ho ve své schránce, a mezitím můžeš pokračovat do Sídla.'
      : 'We sent a verification link to $email. Confirm it in your inbox — meanwhile you can continue into the Mansion.';
  String get continueToAvatar =>
      isCs ? 'Pokračovat k tvorbě avatara' : 'Continue to Avatar Creation';

  String get createAvatarEyebrow =>
      isCs ? 'STVOŘENÍ AVATARA' : 'CREATE YOUR AVATAR';
  String get createAvatarHint =>
      isCs ? 'Tvoje přezdívka v Sídle' : 'Your Mansion nickname';
  String get continueToMansion =>
      isCs ? 'Pokračovat do Sídla' : 'Continue to Mansion';

  String get gangSetupTitle =>
      isCs ? 'Vstup do Gangu' : 'Enter a Gang';
  String get gangSetupCreateBtn =>
      isCs ? 'Založit Gang a stát se Rukou' : 'Create Gang & Become The Hand';
  String get gangSetupCreating =>
      isCs ? 'Zakládám Gang...' : 'Creating Gang...';
  String get gangSetupJoinBtn =>
      isCs ? 'Připojit se ke Gangu' : 'Join Gang';
  String get gangSetupJoining =>
      isCs ? 'Připojuji se...' : 'Joining...';
  String get gangSetupQuickStart => isCs
      ? 'Rychlý start s ukázkovým Sídlem'
      : 'Quick Start with Sample Mansion';

  // ---------------------------------------------------------------------------
  // Feed / Chronicle
  // ---------------------------------------------------------------------------
  String get feedEmptyTitle =>
      isCs ? 'Kronika sídla mlčí' : 'The Chronicle is Silent';
  String get feedEmptyText => isCs
      ? 'Zatím žádná zahraná karta. Pavučiny čekají na první zápis.'
      : 'No cards played yet. The cobwebs await the first entry.';

  // ---------------------------------------------------------------------------
  // Deck & Play Card
  // ---------------------------------------------------------------------------
  String get deckEyebrow =>
      isCs ? 'KNIHA KARET SÍDLA' : 'MANSION BOOK OF CARDS';
  String get deckHeading =>
      isCs ? 'Vyber splněnou kartu' : 'Choose a completed card';
  String deckBonusSummary(
    String levelLabel,
    int levelPct,
    String heatLabel,
    int heatPct,
    int totalPct,
  ) =>
      isCs
          ? 'Level $levelLabel (+$levelPct %) • $heatLabel (+$heatPct %) = celkem +$totalPct % Coinů.'
          : 'Level $levelLabel (+$levelPct%) • $heatLabel (+$heatPct%) = +$totalPct% total Coins.';
  String deckAllFilter(int count) =>
      isCs ? 'Všechny ($count)' : 'All ($count)';

  String difficultyLabel(ChoreDifficulty difficulty, GameThemePackage theme) {
    if (isCs) return theme.difficultyLabel(difficulty);
    return switch (difficulty) {
      ChoreDifficulty.easy => 'Easy',
      ChoreDifficulty.medium => 'Medium',
      ChoreDifficulty.hard => 'Hard',
      ChoreDifficulty.special => 'Special',
    };
  }

  String monthlyLevelLabel(MonthlyLevel level, GameThemePackage theme) {
    if (isCs) return theme.monthlyLevelLabel(level);
    return switch (level) {
      MonthlyLevel.awakened => 'Awakened',
      MonthlyLevel.restlessSpirit => 'Restless Spirit',
      MonthlyLevel.bloodthirsty => 'Bloodthirsty',
      MonthlyLevel.unstoppable => 'Unstoppable',
      MonthlyLevel.godlike => 'Godlike',
    };
  }

  String heatLabel(HeatLevel heat, GameThemePackage theme) {
    if (isCs) return theme.heatLabel(heat);
    return switch (heat) {
      HeatLevel.coldAsh => 'Cold Ash',
      HeatLevel.glowingEmbers => 'Glowing Embers',
      HeatLevel.blazingForge => 'Blazing Forge',
      HeatLevel.hellfire => 'Hellfire',
    };
  }

  String get estimateLabel => isCs ? 'ODHAD' : 'ESTIMATE';
  String get pouchRewardLabel =>
      isCs ? 'ZISK DO MEŠCE' : 'POUCH REWARD';
  String get playCardPrefix =>
      isCs ? 'Zahrát kartu (+' : 'Play Card (+';
  String cardPlayedSnackbar(int coins) => isCs
      ? 'Zahráno! +$coins připsáno do tvého Mešce.'
      : 'Played! +$coins added to your Pouch.';

  // ---------------------------------------------------------------------------
  // Pouch / Bank & Exchange
  // ---------------------------------------------------------------------------
  String get pouchEyebrow => isCs ? 'TVŮJ MEŠEC' : 'YOUR POUCH';
  String get pouchHeading =>
      isCs ? 'Mešec & Směna u Ruky' : 'Pouch & Hand Exchange';
  String get pouchEmpty => isCs ? 'Mešec je prázdný' : 'Pouch is empty';
  String requestExchangeBtn(int count) => isCs
      ? 'Požádat Ruku o směnu ($count)'
      : 'Request Hand Exchange ($count)';
  String exchangeRequestedSnackbar(int totalCoins) => isCs
      ? 'Žádost o směnu $totalCoins zlaťáků odeslána Ruce.'
      : 'Exchange request for $totalCoins coins sent to The Hand.';
  String get playedCardsInPouchSection =>
      isCs ? 'ZAHRANÉ KARTY V MEŠCI' : 'PLAYED CARDS IN POUCH';
  String get pendingCardsSection => isCs
      ? 'MOJE KARTY ČEKAJÍCÍ NA POTVRZENÍ RUKOU'
      : 'MY CARDS AWAITING HAND APPROVAL';
  String get handManagementSection =>
      isCs ? 'SPRÁVA RUKY (ZAKLADATEL)' : 'HAND MANAGEMENT (FOUNDER)';
  String get closeMonthBtn => isCs
      ? 'Uzavřít měsíc (Auto-směna & Výherce)'
      : 'Close Month (Auto-Exchange & Winner)';
  String monthClosedSnackbar(int created) => isCs
      ? 'Měsíc uzavřen! Vygenerováno $created automatických žádostí o směnu.'
      : 'Month closed! Generated $created automatic exchange requests.';
  String get noPendingExchanges => isCs
      ? 'Žádné čekající žádosti o směnu'
      : 'No pending exchange requests';
  String get autoMonthEndLabel =>
      isCs ? 'Automatická uzávěrka měsíce' : 'Automatic month-end closing';
  String get rejectCardTooltip =>
      isCs ? 'Neuznat kartu' : 'Reject card';
  String approveExchangeBtn(int totalCoins) => isCs
      ? 'Schválit směnu ($totalCoins)'
      : 'Approve Exchange ($totalCoins)';

  // ---------------------------------------------------------------------------
  // Leaderboard
  // ---------------------------------------------------------------------------
  String get leaderboardEyebrow =>
      isCs ? 'SÍŇ HRDINŮ SÍDLA' : 'MANSION HALL OF HEROES';
  String get leaderboardHeading =>
      isCs ? 'Leaderboard Hráčů' : 'Player Leaderboard';

  // ---------------------------------------------------------------------------
  // Profile & Settings
  // ---------------------------------------------------------------------------
  String inviteCodeLine(String code) => isCs
      ? 'Zvací kód pro členy Gangu: $code'
      : 'Gang invite code: $code';
  String accountLine(String email) =>
      isCs ? 'Účet: $email' : 'Account: $email';
  String get myGangsBtn => isCs ? 'Moje Gangy' : 'My Gangs';
  String get inviteManageBtn =>
      isCs ? 'Pozvat / Správa' : 'Invite / Manage';
  String get switchMemberSection => isCs
      ? 'PŘEPNOUT ČLENA (TEST / DOMÁCNOST)'
      : 'SWITCH MEMBER (TEST / HOUSEHOLD)';
  String get roleHandSubtitle =>
      isCs ? 'Zakladatel • Ruka' : 'Founder • The Hand';
  String get roleMemberSubtitle =>
      isCs ? 'Člen Gangu' : 'Gang Member';
  String get renameNicknameLabel =>
      isCs ? 'Změnit moji přezdívku' : 'Change my nickname';
  String get saveBtn => isCs ? 'Uložit' : 'Save';
  String get appUpdatesTitle =>
      isCs ? 'Aktualizace aplikace' : 'App Updates';
  String get checkNewVersion =>
      isCs ? 'Zkontrolovat novou verzi' : 'Check for new version';
  String currentVersionLine(String version, int build) => isCs
      ? 'Aktuální verze $version (#$build)'
      : 'Current version $version (#$build)';
  String get latestVersionSnackbar => isCs
      ? 'Máš nejnovější dostupnou verzi.'
      : 'You have the latest available version.';

  // ---------------------------------------------------------------------------
  // Update Banner
  // ---------------------------------------------------------------------------
  String newVersionTitle(String version, int build) => isCs
      ? 'Nová verze $version (#$build)'
      : 'New version $version (#$build)';
  String get updateLaterBtn => isCs ? 'Později' : 'Later';
  String get updateNowBtn => isCs ? 'Aktualizovat' : 'Update';
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'cs';

  @override
  Future<AppStrings> load(Locale locale) =>
      SynchronousFuture<AppStrings>(AppStrings(locale));

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
