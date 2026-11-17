import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'models.dart';
import 'theme_package.dart';

/// Localized UI copy for GrimGrind supporting English (`en`) and Czech (`cs`).
///
/// Backed by Flutter's generated [AppLocalizations] from `lib/l10n/*.arb`.
/// Automatically follows the user's phone locale via [MaterialApp.supportedLocales]
/// and [localeResolutionCallback], falling back to English when the device
/// language is not Czech.
class AppStrings {
  AppStrings(this.locale, [AppLocalizations? l10n])
    : l10n = l10n ?? lookupAppLocalizations(locale);

  final Locale locale;
  final AppLocalizations l10n;

  static const List<Locale> supportedLocales = AppLocalizations.supportedLocales;

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
    final generated = AppLocalizations.of(context);
    return AppStrings(fallbackLocale, generated);
  }

  // Navigation & Top-Level Tabs
  String get navChronicle => l10n.navChronicle;
  String get navPouch => l10n.navPouch;
  String get navLeaderboard => l10n.navLeaderboard;
  String get navMansion => l10n.navMansion;
  String get deckTitle => l10n.deckTitle;
  String get playCardFab => l10n.playCardFab;

  // Onboarding Intro & Splash
  String get skip => l10n.skip;
  String get nextRuleCard => l10n.nextRuleCard;
  String get enterMansion => l10n.enterMansion;
  String get splashTagline => l10n.splashTagline;
  String get splashLoading => l10n.splashLoading;

  List<ThemeOnboardingSlide> onboardingSlidesFor(GameThemePackage theme) => [
    ThemeOnboardingSlide(
      eyebrow: l10n.onboardingRule1Eyebrow,
      title: l10n.onboardingRule1Title,
      text: l10n.onboardingRule1Text,
      imageAsset: theme.onboardingSlides[0].imageAsset,
    ),
    ThemeOnboardingSlide(
      eyebrow: l10n.onboardingRule2Eyebrow,
      title: l10n.onboardingRule2Title,
      text: l10n.onboardingRule2Text,
      imageAsset: theme.onboardingSlides[1].imageAsset,
    ),
    ThemeOnboardingSlide(
      eyebrow: l10n.onboardingRule3Eyebrow,
      title: l10n.onboardingRule3Title,
      text: l10n.onboardingRule3Text,
      imageAsset: theme.onboardingSlides[2].imageAsset,
    ),
  ];

  // Auth Gate & Email Verification & Avatar & Mansion Setup
  String get authEyebrow => l10n.authEyebrow;
  String get authLoginTitle => l10n.authLoginTitle;
  String get authRegisterTitle => l10n.authRegisterTitle;
  String get authEmailLabel => l10n.authEmailLabel;
  String get authPasswordLabel => l10n.authPasswordLabel;
  String get authSignInBtn => l10n.authSignInBtn;
  String get authCreateAccountBtn => l10n.authCreateAccountBtn;
  String get authVerifyingSeal => l10n.authVerifyingSeal;
  String get authOr => l10n.authOr;
  String get authContinueGoogle => l10n.authContinueGoogle;
  String get authContinueGuest => l10n.authContinueGuest;
  String get authSubtitle => l10n.authSubtitle;
  String get authSignInTab => l10n.authSignInTab;
  String get authRegisterTab => l10n.authRegisterTab;
  String get authFailedFallback => l10n.authFailedFallback;
  String get authGoogleFailedFallback => l10n.authGoogleFailedFallback;
  String get authFooterQuote => l10n.authFooterQuote;

  String get sealSentEyebrow => l10n.sealSentEyebrow;
  String get verifyEmailTitle => l10n.verifyEmailTitle;
  String verifyEmailBody(String email) => l10n.verifyEmailBody(email);
  String get continueToAvatar => l10n.continueToAvatar;

  String get createAvatarEyebrow => l10n.createAvatarEyebrow;
  String get createAvatarHint => l10n.createAvatarHint;
  String get continueToMansion => l10n.continueToMansion;
  String get createAvatarTitle => l10n.createAvatarTitle;
  String get createAvatarSubtitle => l10n.createAvatarSubtitle;
  String get createAvatarNicknameLabel => l10n.createAvatarNicknameLabel;
  String get nicknameExampleHint => l10n.nicknameExampleHint;

  String get gangSetupTitle => l10n.gangSetupTitle;
  String get gangSetupCreateBtn => l10n.gangSetupCreateBtn;
  String get gangSetupCreating => l10n.gangSetupCreating;
  String get gangSetupJoinBtn => l10n.gangSetupJoinBtn;
  String get gangSetupJoining => l10n.gangSetupJoining;
  String get gangSetupQuickStart => l10n.gangSetupQuickStart;
  String get gangSetupEyebrow => l10n.gangSetupEyebrow;
  String get gangSetupSubtitle => l10n.gangSetupSubtitle;
  String get defaultMansionName => l10n.defaultMansionName;
  String get founderNicknameLabel => l10n.founderNicknameLabel;
  String get starterFamilyTitle => l10n.starterFamilyTitle;
  String get starterFamilySubtitle => l10n.starterFamilySubtitle;
  String get mansionInviteCodeLabel => l10n.mansionInviteCodeLabel;
  String get inviteCodeExampleHint => l10n.inviteCodeExampleHint;

  // Feed / Chronicle
  String get chronicleEmptyTitle => l10n.chronicleEmptyTitle;
  String get chronicleEmptyText => l10n.chronicleEmptyText;

  // Deck & Play Card
  String get deckEyebrow => l10n.deckEyebrow;
  String get deckHeading => l10n.deckHeading;
  String deckBonusSummary(
    String levelLabel,
    int levelPct,
    String heatLabel,
    int heatPct,
    int totalPct,
  ) =>
      l10n.deckBonusSummary(levelLabel, levelPct, heatLabel, heatPct, totalPct);
  String deckAllFilter(int count) => l10n.deckAllFilter(count);

  String difficultyLabel(ChoreDifficulty difficulty, GameThemePackage theme) =>
      switch (difficulty) {
        ChoreDifficulty.easy => l10n.difficultyEasy,
        ChoreDifficulty.medium => l10n.difficultyMedium,
        ChoreDifficulty.hard => l10n.difficultyHard,
        ChoreDifficulty.special => l10n.difficultySpecial,
      };

  String monthlyLevelLabel(MonthlyLevel level, GameThemePackage theme) =>
      switch (level) {
        MonthlyLevel.awakened => l10n.levelAwakened,
        MonthlyLevel.restlessSpirit => l10n.levelRestlessSpirit,
        MonthlyLevel.bloodthirsty => l10n.levelBloodthirsty,
        MonthlyLevel.unstoppable => l10n.levelUnstoppable,
        MonthlyLevel.godlike => l10n.levelGodlike,
      };

  String heatLabel(HeatLevel heat, GameThemePackage theme) => switch (heat) {
    HeatLevel.coldAsh => l10n.heatColdAsh,
    HeatLevel.glowingEmbers => l10n.heatGlowingEmbers,
    HeatLevel.blazingForge => l10n.heatBlazingForge,
    HeatLevel.hellfire => l10n.heatHellfire,
  };

  String heatRuleSummary(HeatLevel heat) => switch (heat) {
    HeatLevel.coldAsh => l10n.heatRuleColdAsh,
    HeatLevel.glowingEmbers => l10n.heatRuleGlowingEmbers,
    HeatLevel.blazingForge => l10n.heatRuleBlazingForge,
    HeatLevel.hellfire => l10n.heatRuleHellfire,
  };

  String get estimateLabel => l10n.estimateLabel;
  String get difficultyStatLabel => l10n.difficultyStatLabel;
  String get pouchRewardLabel => l10n.pouchRewardLabel;
  String get playCardPrefix => l10n.playCardPrefix;
  String cardPlayedSnackbar(int coins) => l10n.cardPlayedSnackbar(coins);

  // Pouch / Bank & Exchange
  String get pouchEyebrow => l10n.pouchEyebrow;
  String get pouchHeading => l10n.pouchHeading;
  String get pouchEmpty => l10n.pouchEmpty;
  String requestExchangeBtn(int count) => l10n.requestExchangeBtn(count);
  String exchangeRequestedSnackbar(int totalCoins) =>
      l10n.exchangeRequestedSnackbar(totalCoins);
  String get playedCardsInPouchSection => l10n.playedCardsInPouchSection;
  String get pendingCardsSection => l10n.pendingCardsSection;
  String get handManagementSection => l10n.handManagementSection;
  String get closeMonthBtn => l10n.closeMonthBtn;
  String monthClosedSnackbar(int created) => l10n.monthClosedSnackbar(created);
  String get noPendingExchanges => l10n.noPendingExchanges;
  String get autoMonthEndLabel => l10n.autoMonthEndLabel;
  String get rejectCardTooltip => l10n.rejectCardTooltip;
  String approveExchangeBtn(int totalCoins) =>
      l10n.approveExchangeBtn(totalCoins);

  // Leaderboard
  String get leaderboardEyebrow => l10n.leaderboardEyebrow;
  String get leaderboardHeading => l10n.leaderboardHeading;
  String get leaderboardSubtitle => l10n.leaderboardSubtitle;
  String get leaderboardStatTasks => l10n.leaderboardStatTasks;
  String get leaderboardStatCoins => l10n.leaderboardStatCoins;
  String get leaderboardStatStreak => l10n.leaderboardStatStreak;
  String get leaderboardStatTime => l10n.leaderboardStatTime;
  String inPouchWaitingPrefix(int count) => l10n.inPouchWaitingPrefix(count);

  // Mansion & Settings
  String inviteCodeLine(String code) => l10n.inviteCodeLine(code);
  String accountLine(String email) => l10n.accountLine(email);
  String get yourAvatarSection => l10n.yourAvatarSection;
  String get nicknameLabel => l10n.nicknameLabel;
  String get sexLabel => l10n.sexLabel;
  String get myMansionsSection => l10n.myMansionsSection;
  String get createMansionBtn => l10n.createMansionBtn;
  String get joinMansionBtn => l10n.joinMansionBtn;
  String get activeMansionBadge => l10n.activeMansionBadge;
  String get inactiveBadge => l10n.inactiveBadge;
  String membersCountLabel(int count) => l10n.membersCountLabel(count);
  String get membersSectionTitle => l10n.membersSectionTitle;
  String get setActiveMansionBtn => l10n.setActiveMansionBtn;
  String get leaveMansionBtn => l10n.leaveMansionBtn;
  String get leaveMansionConfirmTitle => l10n.leaveMansionConfirmTitle;
  String leaveMansionConfirmBody(String name) =>
      l10n.leaveMansionConfirmBody(name);
  String get deleteMansionBtn => l10n.deleteMansionBtn;
  String get deleteMansionConfirmTitle => l10n.deleteMansionConfirmTitle;
  String get myGangsBtn => l10n.myGangsBtn;
  String get inviteManageBtn => l10n.inviteManageBtn;
  String get switchMemberSection => l10n.switchMemberSection;
  String get roleHandSubtitle => l10n.roleHandSubtitle;
  String get roleMemberSubtitle => l10n.roleMemberSubtitle;
  String get renameNicknameLabel => l10n.renameNicknameLabel;
  String get saveBtn => l10n.saveBtn;
  String get avatarSavedSnackbar => l10n.avatarSavedSnackbar;
  String get logoutBtn => l10n.logoutBtn;
  String get logoutConfirmTitle => l10n.logoutConfirmTitle;
  String get logoutConfirmBody => l10n.logoutConfirmBody;
  String logoutConfirmBodyEmail(String email) =>
      l10n.logoutConfirmBodyEmail(email);
  String get appUpdatesTitle => l10n.appUpdatesTitle;
  String get checkNewVersion => l10n.checkNewVersion;
  String currentVersionLine(String version, int build) =>
      l10n.currentVersionLine(version, build);
  String get latestVersionSnackbar => l10n.latestVersionSnackbar;

  // Update Banner
  String newVersionTitle(String version, int build) =>
      l10n.newVersionTitle(version, build);
  String get updateLaterBtn => l10n.updateLaterBtn;
  String get updateNowBtn => l10n.updateNowBtn;

  // Chores (Book of Cards)
  String choreTitle(ChoreDefinition chore) =>
      choreTitleById(chore.id, fallback: chore.title);

  String choreTitleById(String? choreId, {required String fallback}) =>
      switch (choreId) {
        'trash' => l10n.choreTrashTitle,
        'shopping' => l10n.choreShoppingTitle,
        'dishwasher' => l10n.choreDishwasherTitle,
        'laundry' => l10n.choreLaundryTitle,
        'stairs' => l10n.choreStairsTitle,
        'queenie' => l10n.choreQueenieTitle,
        'toilet' => l10n.choreToiletTitle,
        'dogs' => l10n.choreDogsTitle,
        'sport' => l10n.choreSportTitle,
        'garden' => l10n.choreGardenTitle,
        'evening' => l10n.choreEveningTitle,
        'bathroom' => l10n.choreBathroomTitle,
        'mop' => l10n.choreMopTitle,
        'ironing' => l10n.choreIroningTitle,
        'cooking' => l10n.choreCookingTitle,
        'school' => l10n.choreSchoolTitle,
        'room' => l10n.choreRoomTitle,
        _ => fallback,
      };

  String? choreNote(ChoreDefinition chore) {
    if (chore.note == null) return null;
    return switch (chore.id) {
      'dogs' => l10n.choreDogsNote,
      'garden' => l10n.choreGardenNote,
      'evening' => l10n.choreEveningNote,
      'room' => l10n.choreRoomNote,
      _ => chore.note,
    };
  }

  // Model Enums & Theme Helpers
  String memberSexLabel(MemberSex sex) => switch (sex) {
    MemberSex.male => l10n.sexMale,
    MemberSex.female => l10n.sexFemale,
    MemberSex.neutral => l10n.sexNeutral,
  };

  String leaderboardPeriodLabel(LeaderboardPeriod period) => switch (period) {
    LeaderboardPeriod.currentMonth => l10n.periodCurrentMonth,
    LeaderboardPeriod.previousMonth => l10n.periodPreviousMonth,
    LeaderboardPeriod.allTime => l10n.periodAllTime,
  };

  String leaderboardSortLabel(LeaderboardSort sort) => switch (sort) {
    LeaderboardSort.mostActive => l10n.sortMostActive,
    LeaderboardSort.mostHardWorking => l10n.sortMostHardWorking,
    LeaderboardSort.byStreakLevel => l10n.sortByStreakLevel,
  };

  String themeSubtitle(GameThemePackage theme) => l10n.themeGothicSubtitle;

  // Chronicle Feed Entries
  String get exchangeApprovedBanner => l10n.exchangeApprovedBanner;
  String countedTowardLeaderboard(String formattedDate) =>
      l10n.countedTowardLeaderboard(formattedDate);
  String periodClosingBanner(String monthKey) =>
      l10n.periodClosingBanner(monthKey);

  String chronicleCardPlayedTitle(ChronicleEntry entry) =>
      choreTitleById(entry.choreId, fallback: entry.title);

  String chronicleCardPlayedLine(ChronicleEntry entry) {
    if (entry.coins == null) {
      return '${entry.actorNickname} ${entry.message}';
    }
    final choreName = choreTitleById(entry.choreId, fallback: entry.title);
    return l10n.chronicleCardPlayedLine(
      entry.actorNickname,
      choreName,
      entry.coins!,
    );
  }

  String chronicleExchangeMessage(ChronicleEntry entry) {
    if (entry.cardCount == null || entry.coins == null) {
      return entry.message;
    }
    final czkPart = entry.czkAmount != null ? ' (${entry.czkAmount} CZK)' : '';
    return l10n.chronicleExchangeMessage(
      entry.actorNickname,
      entry.cardCount!,
      entry.coins!,
      czkPart,
    );
  }

  String chronicleMonthTitle(ChronicleEntry entry) =>
      l10n.chronicleMonthTitle(entry.monthKey);

  String chronicleMonthMessage(ChronicleEntry entry) {
    if (entry.winnerNickname == null) {
      return l10n.chronicleMonthClosedNoWinner(entry.monthKey);
    }
    if (entry.cardCount == null) {
      return l10n.chronicleMonthClosedWinnerNoCount(
        entry.winnerNickname!,
        entry.monthKey,
        entry.coins ?? 0,
      );
    }
    return l10n.chronicleMonthClosedWinner(
      entry.winnerNickname!,
      entry.monthKey,
      entry.coins ?? 0,
      entry.cardCount!,
    );
  }

  // Gangs Management & Invites
  String get sexSelectorLabel => l10n.sexSelectorLabel;
  String get joinFellowshipEyebrow => l10n.joinFellowshipEyebrow;
  String get acceptInviteTitle => l10n.acceptInviteTitle;
  String get acceptInviteSubtitle => l10n.acceptInviteSubtitle;
  String inviteForGang(String name) => l10n.inviteForGang(name);
  String existingMembersCount(int count) => l10n.existingMembersCount(count);
  String get inviteCodeOrLinkLabel => l10n.inviteCodeOrLinkLabel;
  String get nicknameInMansionLabel => l10n.nicknameInMansionLabel;
  String get cancelBtn => l10n.cancelBtn;
  String get joiningBtn => l10n.joiningBtn;
  String get joinBtn => l10n.joinBtn;
  String get invalidInviteCodeError => l10n.invalidInviteCodeError;
  String get welcomeToMansionTitle => l10n.welcomeToMansionTitle;
  String welcomeToMansionBody(String name) => l10n.welcomeToMansionBody(name);
  String get welcomeToMansionConfirmBtn => l10n.welcomeToMansionConfirmBtn;

  String get createMansionCharterEyebrow => l10n.createMansionCharterEyebrow;
  String get createNewMansionTitle => l10n.createNewMansionTitle;
  String get createNewMansionSubtitle => l10n.createNewMansionSubtitle;
  String get mansionNameLabel => l10n.mansionNameLabel;
  String get mansionNameHint => l10n.mansionNameHint;
  String get founderHandNicknameLabel => l10n.founderHandNicknameLabel;
  String get creatingBtn => l10n.creatingBtn;
  String get createBtn => l10n.createBtn;
  String get createMansionFailedError => l10n.createMansionFailedError;

  String get mansionsManagementEyebrow => l10n.mansionsManagementEyebrow;
  String get acceptCodeBtn => l10n.acceptCodeBtn;
  String get manageBtn => l10n.manageBtn;
  String fellowshipsOverview(int count) => l10n.fellowshipsOverview(count);
  String get noMansionsYet => l10n.noMansionsYet;
  String get canonQuote => l10n.canonQuote;
  String get canonAttribution => l10n.canonAttribution;
  String get standbyBadge => l10n.standbyBadge;
  String get roleHandOwnerBadge => l10n.roleHandOwnerBadge;
  String get roleMemberBadge => l10n.roleMemberBadge;
  String get ownerBadge => l10n.ownerBadge;
  String nicknameLine(String nickname) => l10n.nicknameLine(nickname);
  String get inviteCodePrefix => l10n.inviteCodePrefix;
  String exchangeRateLine(int coinsPerCzk) =>
      l10n.exchangeRateLine(coinsPerCzk);
  String get mansionDeletedSnackbar => l10n.mansionDeletedSnackbar;
  String get mansionWasDeleted => l10n.mansionWasDeleted;

  String shareInviteMessage(String name, String url, String code) =>
      l10n.shareInviteMessage(name, url, code);
  String get manageAndInvitesTitle => l10n.manageAndInvitesTitle;
  String get roleHandShort => l10n.roleHandShort;
  String get inviteFriendsSection => l10n.inviteFriendsSection;
  String get uniqueInviteCodeLabel => l10n.uniqueInviteCodeLabel;
  String get inviteLinkCopiedSnackbar => l10n.inviteLinkCopiedSnackbar;
  String get copyInviteLinkBtn => l10n.copyInviteLinkBtn;
  String newInviteCodeSnackbar(String code) => l10n.newInviteCodeSnackbar(code);
  String get regenerateInviteCodeBtn => l10n.regenerateInviteCodeBtn;
  String get dangerZoneEyebrow => l10n.dangerZoneEyebrow;
  String get deleteMansionWarning => l10n.deleteMansionWarning;
  String get finalDecisionEyebrow => l10n.finalDecisionEyebrow;
  String deleteMansionConfirmPrompt(String name) =>
      l10n.deleteMansionConfirmPrompt(name);
  String typeExactNameLabel(String name) => l10n.typeExactNameLabel(name);
  String get keepMansionBtn => l10n.keepMansionBtn;
  String get deleteForeverBtn => l10n.deleteForeverBtn;
  String get themeSectionTitle => l10n.themeSectionTitle;
  String get handOnlyLabel => l10n.handOnlyLabel;
  String get readOnlyLabel => l10n.readOnlyLabel;
  String get themeOwnerHint => l10n.themeOwnerHint;
  String get themeMemberHint => l10n.themeMemberHint;
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.delegate.isSupported(locale);

  @override
  Future<AppStrings> load(Locale locale) async {
    final l10n = await AppLocalizations.delegate.load(locale);
    return AppStrings(locale, l10n);
  }

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
