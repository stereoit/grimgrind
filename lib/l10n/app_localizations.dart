import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('en'),
  ];

  /// No description provided for @navChronicle.
  ///
  /// In en, this message translates to:
  /// **'Chronicle'**
  String get navChronicle;

  /// No description provided for @navPouch.
  ///
  /// In en, this message translates to:
  /// **'Pouch'**
  String get navPouch;

  /// No description provided for @navLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get navLeaderboard;

  /// No description provided for @navMansion.
  ///
  /// In en, this message translates to:
  /// **'Mansion'**
  String get navMansion;

  /// No description provided for @deckTitle.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get deckTitle;

  /// No description provided for @playCardFab.
  ///
  /// In en, this message translates to:
  /// **'Play Card'**
  String get playCardFab;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @nextRuleCard.
  ///
  /// In en, this message translates to:
  /// **'Next Rule Card'**
  String get nextRuleCard;

  /// No description provided for @enterMansion.
  ///
  /// In en, this message translates to:
  /// **'Enter the Mansion'**
  String get enterMansion;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'THE MANSION & HOUSEHOLD GRIND'**
  String get splashTagline;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'SWEEPING COBWEBS FROM THE MANSION...'**
  String get splashLoading;

  /// No description provided for @onboardingRule1Eyebrow.
  ///
  /// In en, this message translates to:
  /// **'RULE I • BOOK OF CARDS'**
  String get onboardingRule1Eyebrow;

  /// No description provided for @onboardingRule1Title.
  ///
  /// In en, this message translates to:
  /// **'Shared Mansion Deck'**
  String get onboardingRule1Title;

  /// No description provided for @onboardingRule1Text.
  ///
  /// In en, this message translates to:
  /// **'The entire household draws from the same book of 17 chores. No locking or waiting — as soon as you finish a chore, play the card straight into the Chronicle.'**
  String get onboardingRule1Text;

  /// No description provided for @onboardingRule2Eyebrow.
  ///
  /// In en, this message translates to:
  /// **'RULE II • COINS, LEVEL & HEAT'**
  String get onboardingRule2Eyebrow;

  /// No description provided for @onboardingRule2Title.
  ///
  /// In en, this message translates to:
  /// **'Blazing Reward Multipliers'**
  String get onboardingRule2Title;

  /// No description provided for @onboardingRule2Text.
  ///
  /// In en, this message translates to:
  /// **'Play cards throughout the month to rise from Awakened to Godlike. Playing regularly stokes your Heat, which cools down when you slack off.'**
  String get onboardingRule2Text;

  /// No description provided for @onboardingRule3Eyebrow.
  ///
  /// In en, this message translates to:
  /// **'RULE III • THE HAND & LEADERBOARD'**
  String get onboardingRule3Eyebrow;

  /// No description provided for @onboardingRule3Title.
  ///
  /// In en, this message translates to:
  /// **'Exchange Pouch & Rule the Mansion'**
  String get onboardingRule3Title;

  /// No description provided for @onboardingRule3Text.
  ///
  /// In en, this message translates to:
  /// **'Coins drop into your Pouch. Ask The Hand (Founder) to exchange them for real money anytime. Only approved exchanges count toward the Leaderboard!'**
  String get onboardingRule3Text;

  /// No description provided for @authEyebrow.
  ///
  /// In en, this message translates to:
  /// **'MANSION GATE'**
  String get authEyebrow;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authLoginTitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authRegisterTitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authSignInBtn.
  ///
  /// In en, this message translates to:
  /// **'Enter the Mansion'**
  String get authSignInBtn;

  /// No description provided for @authCreateAccountBtn.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccountBtn;

  /// No description provided for @authVerifyingSeal.
  ///
  /// In en, this message translates to:
  /// **'Verifying seal...'**
  String get authVerifyingSeal;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authOr;

  /// No description provided for @authContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueGoogle;

  /// No description provided for @authContinueGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get authContinueGuest;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your household or create a new account.'**
  String get authSubtitle;

  /// No description provided for @authSignInTab.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignInTab;

  /// No description provided for @authRegisterTab.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterTab;

  /// No description provided for @authFailedFallback.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed.'**
  String get authFailedFallback;

  /// No description provided for @authGoogleFailedFallback.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed.'**
  String get authGoogleFailedFallback;

  /// No description provided for @authFooterQuote.
  ///
  /// In en, this message translates to:
  /// **'“Whoever crosses the threshold without a seal becomes a mere shadow in the chronicle.”'**
  String get authFooterQuote;

  /// No description provided for @sealSentEyebrow.
  ///
  /// In en, this message translates to:
  /// **'SEAL SENT'**
  String get sealSentEyebrow;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. Confirm it in your inbox — meanwhile you can continue into the Mansion.'**
  String verifyEmailBody(String email);

  /// No description provided for @continueToAvatar.
  ///
  /// In en, this message translates to:
  /// **'Continue to Avatar Creation'**
  String get continueToAvatar;

  /// No description provided for @createAvatarEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CREATE YOUR AVATAR'**
  String get createAvatarEyebrow;

  /// No description provided for @createAvatarHint.
  ///
  /// In en, this message translates to:
  /// **'Your Mansion nickname'**
  String get createAvatarHint;

  /// No description provided for @continueToMansion.
  ///
  /// In en, this message translates to:
  /// **'Continue to Mansion'**
  String get continueToMansion;

  /// No description provided for @createAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Dark Avatar'**
  String get createAvatarTitle;

  /// No description provided for @createAvatarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your nickname and likeness for the Mansion chronicle.'**
  String get createAvatarSubtitle;

  /// No description provided for @createAvatarNicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your dark nickname'**
  String get createAvatarNicknameLabel;

  /// No description provided for @nicknameExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Shadow Master'**
  String get nicknameExampleHint;

  /// No description provided for @gangSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a Mansion'**
  String get gangSetupTitle;

  /// No description provided for @gangSetupCreateBtn.
  ///
  /// In en, this message translates to:
  /// **'Create Mansion & Become The Hand'**
  String get gangSetupCreateBtn;

  /// No description provided for @gangSetupCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating Mansion...'**
  String get gangSetupCreating;

  /// No description provided for @gangSetupJoinBtn.
  ///
  /// In en, this message translates to:
  /// **'Join Mansion'**
  String get gangSetupJoinBtn;

  /// No description provided for @gangSetupJoining.
  ///
  /// In en, this message translates to:
  /// **'Joining...'**
  String get gangSetupJoining;

  /// No description provided for @gangSetupQuickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick Start with Sample Mansion'**
  String get gangSetupQuickStart;

  /// No description provided for @gangSetupEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CREATE OR JOIN'**
  String get gangSetupEyebrow;

  /// No description provided for @gangSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The founding member becomes The Hand (sets the Coin → CZK rate and approves exchanges) and invites others via an invite code.'**
  String get gangSetupSubtitle;

  /// No description provided for @defaultMansionName.
  ///
  /// In en, this message translates to:
  /// **'Addams Mansion'**
  String get defaultMansionName;

  /// No description provided for @founderNicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your nickname (Founder = The Hand)'**
  String get founderNicknameLabel;

  /// No description provided for @starterFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add sample members & history'**
  String get starterFamilyTitle;

  /// No description provided for @starterFamilySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ideal for trying out the Leaderboard and exchange approvals right away'**
  String get starterFamilySubtitle;

  /// No description provided for @mansionInviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mansion Invite Code'**
  String get mansionInviteCodeLabel;

  /// No description provided for @inviteCodeExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. GRIM-42'**
  String get inviteCodeExampleHint;

  /// No description provided for @chronicleEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'The Chronicle is Silent'**
  String get chronicleEmptyTitle;

  /// No description provided for @chronicleEmptyText.
  ///
  /// In en, this message translates to:
  /// **'No cards played yet. The cobwebs await the first entry.'**
  String get chronicleEmptyText;

  /// No description provided for @deckEyebrow.
  ///
  /// In en, this message translates to:
  /// **'MANSION BOOK OF CARDS'**
  String get deckEyebrow;

  /// No description provided for @deckHeading.
  ///
  /// In en, this message translates to:
  /// **'Choose a completed card'**
  String get deckHeading;

  /// No description provided for @deckBonusSummary.
  ///
  /// In en, this message translates to:
  /// **'Level {levelLabel} (+{levelPct}%) • {heatLabel} (+{heatPct}%) = +{totalPct}% total Coins.'**
  String deckBonusSummary(
    String levelLabel,
    int levelPct,
    String heatLabel,
    int heatPct,
    int totalPct,
  );

  /// No description provided for @deckAllFilter.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String deckAllFilter(int count);

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @difficultySpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get difficultySpecial;

  /// No description provided for @levelAwakened.
  ///
  /// In en, this message translates to:
  /// **'Awakened'**
  String get levelAwakened;

  /// No description provided for @levelRestlessSpirit.
  ///
  /// In en, this message translates to:
  /// **'Restless Spirit'**
  String get levelRestlessSpirit;

  /// No description provided for @levelBloodthirsty.
  ///
  /// In en, this message translates to:
  /// **'Bloodthirsty'**
  String get levelBloodthirsty;

  /// No description provided for @levelUnstoppable.
  ///
  /// In en, this message translates to:
  /// **'Unstoppable'**
  String get levelUnstoppable;

  /// No description provided for @levelGodlike.
  ///
  /// In en, this message translates to:
  /// **'Godlike'**
  String get levelGodlike;

  /// No description provided for @heatColdAsh.
  ///
  /// In en, this message translates to:
  /// **'Cold Ash'**
  String get heatColdAsh;

  /// No description provided for @heatGlowingEmbers.
  ///
  /// In en, this message translates to:
  /// **'Glowing Embers'**
  String get heatGlowingEmbers;

  /// No description provided for @heatBlazingForge.
  ///
  /// In en, this message translates to:
  /// **'Blazing Forge'**
  String get heatBlazingForge;

  /// No description provided for @heatHellfire.
  ///
  /// In en, this message translates to:
  /// **'Hellfire'**
  String get heatHellfire;

  /// No description provided for @heatRuleColdAsh.
  ///
  /// In en, this message translates to:
  /// **'Default state or 4+ days break'**
  String get heatRuleColdAsh;

  /// No description provided for @heatRuleGlowingEmbers.
  ///
  /// In en, this message translates to:
  /// **'Min. 2 active days • keep: 1× per 3 days'**
  String get heatRuleGlowingEmbers;

  /// No description provided for @heatRuleBlazingForge.
  ///
  /// In en, this message translates to:
  /// **'Min. 4 active days • keep: 1× per 3 days'**
  String get heatRuleBlazingForge;

  /// No description provided for @heatRuleHellfire.
  ///
  /// In en, this message translates to:
  /// **'Min. 7 active days • keep: every day'**
  String get heatRuleHellfire;

  /// No description provided for @estimateLabel.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATE'**
  String get estimateLabel;

  /// No description provided for @difficultyStatLabel.
  ///
  /// In en, this message translates to:
  /// **'DIFFICULTY'**
  String get difficultyStatLabel;

  /// No description provided for @pouchRewardLabel.
  ///
  /// In en, this message translates to:
  /// **'POUCH REWARD'**
  String get pouchRewardLabel;

  /// No description provided for @playCardPrefix.
  ///
  /// In en, this message translates to:
  /// **'Play Card (+'**
  String get playCardPrefix;

  /// No description provided for @cardPlayedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Played! +{coins} added to your Pouch.'**
  String cardPlayedSnackbar(int coins);

  /// No description provided for @pouchEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR POUCH'**
  String get pouchEyebrow;

  /// No description provided for @pouchHeading.
  ///
  /// In en, this message translates to:
  /// **'Pouch & Hand Exchange'**
  String get pouchHeading;

  /// No description provided for @pouchEmpty.
  ///
  /// In en, this message translates to:
  /// **'Pouch is empty'**
  String get pouchEmpty;

  /// No description provided for @requestExchangeBtn.
  ///
  /// In en, this message translates to:
  /// **'Request Hand Exchange ({count})'**
  String requestExchangeBtn(int count);

  /// No description provided for @exchangeRequestedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Exchange request for {totalCoins} coins sent to The Hand.'**
  String exchangeRequestedSnackbar(int totalCoins);

  /// No description provided for @playedCardsInPouchSection.
  ///
  /// In en, this message translates to:
  /// **'PLAYED CARDS IN POUCH'**
  String get playedCardsInPouchSection;

  /// No description provided for @pendingCardsSection.
  ///
  /// In en, this message translates to:
  /// **'MY CARDS AWAITING HAND APPROVAL'**
  String get pendingCardsSection;

  /// No description provided for @handManagementSection.
  ///
  /// In en, this message translates to:
  /// **'HAND MANAGEMENT (FOUNDER)'**
  String get handManagementSection;

  /// No description provided for @closeMonthBtn.
  ///
  /// In en, this message translates to:
  /// **'Close Month (Auto-Exchange & Winner)'**
  String get closeMonthBtn;

  /// No description provided for @monthClosedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Month closed! Generated {created} automatic exchange requests.'**
  String monthClosedSnackbar(int created);

  /// No description provided for @noPendingExchanges.
  ///
  /// In en, this message translates to:
  /// **'No pending exchange requests'**
  String get noPendingExchanges;

  /// No description provided for @autoMonthEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Automatic month-end closing'**
  String get autoMonthEndLabel;

  /// No description provided for @rejectCardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reject card'**
  String get rejectCardTooltip;

  /// No description provided for @approveExchangeBtn.
  ///
  /// In en, this message translates to:
  /// **'Approve Exchange ({totalCoins})'**
  String approveExchangeBtn(int totalCoins);

  /// No description provided for @leaderboardEyebrow.
  ///
  /// In en, this message translates to:
  /// **'MANSION HALL OF HEROES'**
  String get leaderboardEyebrow;

  /// No description provided for @leaderboardHeading.
  ///
  /// In en, this message translates to:
  /// **'Player Leaderboard'**
  String get leaderboardHeading;

  /// No description provided for @leaderboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only cards approved in a Hand Exchange count.'**
  String get leaderboardSubtitle;

  /// No description provided for @leaderboardStatTasks.
  ///
  /// In en, this message translates to:
  /// **'CHORES'**
  String get leaderboardStatTasks;

  /// No description provided for @leaderboardStatCoins.
  ///
  /// In en, this message translates to:
  /// **'COINS'**
  String get leaderboardStatCoins;

  /// No description provided for @leaderboardStatStreak.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get leaderboardStatStreak;

  /// No description provided for @leaderboardStatTime.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get leaderboardStatTime;

  /// No description provided for @inPouchWaitingPrefix.
  ///
  /// In en, this message translates to:
  /// **'Waiting in Pouch: {count} cards ('**
  String inPouchWaitingPrefix(int count);

  /// No description provided for @inviteCodeLine.
  ///
  /// In en, this message translates to:
  /// **'Mansion invite code: {code}'**
  String inviteCodeLine(String code);

  /// No description provided for @accountLine.
  ///
  /// In en, this message translates to:
  /// **'Account: {email}'**
  String accountLine(String email);

  /// No description provided for @yourAvatarSection.
  ///
  /// In en, this message translates to:
  /// **'YOUR AVATAR'**
  String get yourAvatarSection;

  /// No description provided for @nicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nicknameLabel;

  /// No description provided for @sexLabel.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sexLabel;

  /// No description provided for @myMansionsSection.
  ///
  /// In en, this message translates to:
  /// **'MY MANSIONS'**
  String get myMansionsSection;

  /// No description provided for @createMansionBtn.
  ///
  /// In en, this message translates to:
  /// **'Create Mansion'**
  String get createMansionBtn;

  /// No description provided for @joinMansionBtn.
  ///
  /// In en, this message translates to:
  /// **'Join Mansion'**
  String get joinMansionBtn;

  /// No description provided for @activeMansionBadge.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeMansionBadge;

  /// No description provided for @inactiveBadge.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get inactiveBadge;

  /// No description provided for @membersCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Members'**
  String membersCountLabel(int count);

  /// No description provided for @membersSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'MEMBERS'**
  String get membersSectionTitle;

  /// No description provided for @setActiveMansionBtn.
  ///
  /// In en, this message translates to:
  /// **'Set as Active Mansion'**
  String get setActiveMansionBtn;

  /// No description provided for @leaveMansionBtn.
  ///
  /// In en, this message translates to:
  /// **'Leave Mansion'**
  String get leaveMansionBtn;

  /// No description provided for @leaveMansionConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Mansion?'**
  String get leaveMansionConfirmTitle;

  /// No description provided for @leaveMansionConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave \"{name}\"? You will need an invite code to rejoin.'**
  String leaveMansionConfirmBody(String name);

  /// No description provided for @deleteMansionBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete Mansion'**
  String get deleteMansionBtn;

  /// No description provided for @deleteMansionConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Mansion?'**
  String get deleteMansionConfirmTitle;

  /// No description provided for @myGangsBtn.
  ///
  /// In en, this message translates to:
  /// **'My Mansions'**
  String get myGangsBtn;

  /// No description provided for @inviteManageBtn.
  ///
  /// In en, this message translates to:
  /// **'Invite / Manage'**
  String get inviteManageBtn;

  /// No description provided for @switchMemberSection.
  ///
  /// In en, this message translates to:
  /// **'SWITCH MEMBER (TEST / HOUSEHOLD)'**
  String get switchMemberSection;

  /// No description provided for @roleHandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Founder • The Hand'**
  String get roleHandSubtitle;

  /// No description provided for @roleMemberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mansion Member'**
  String get roleMemberSubtitle;

  /// No description provided for @renameNicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Change my nickname'**
  String get renameNicknameLabel;

  /// No description provided for @saveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBtn;

  /// No description provided for @avatarSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Avatar saved.'**
  String get avatarSavedSnackbar;

  /// No description provided for @logoutBtn.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutBtn;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out of your account and returned to the sign-in screen.'**
  String get logoutConfirmBody;

  /// No description provided for @logoutConfirmBodyEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign out of {email} and return to the sign-in screen?'**
  String logoutConfirmBodyEmail(String email);

  /// No description provided for @appUpdatesTitle.
  ///
  /// In en, this message translates to:
  /// **'App Updates'**
  String get appUpdatesTitle;

  /// No description provided for @checkNewVersion.
  ///
  /// In en, this message translates to:
  /// **'Check for new version'**
  String get checkNewVersion;

  /// No description provided for @currentVersionLine.
  ///
  /// In en, this message translates to:
  /// **'Current version {version} (#{build})'**
  String currentVersionLine(String version, int build);

  /// No description provided for @latestVersionSnackbar.
  ///
  /// In en, this message translates to:
  /// **'You have the latest available version.'**
  String get latestVersionSnackbar;

  /// No description provided for @newVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'New version {version} (#{build})'**
  String newVersionTitle(String version, int build);

  /// No description provided for @updateLaterBtn.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLaterBtn;

  /// No description provided for @updateNowBtn.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateNowBtn;

  /// No description provided for @choreTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Take Out the Trash'**
  String get choreTrashTitle;

  /// No description provided for @choreShoppingTitle.
  ///
  /// In en, this message translates to:
  /// **'Unpack Groceries'**
  String get choreShoppingTitle;

  /// No description provided for @choreDishwasherTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty the Dishwasher'**
  String get choreDishwasherTitle;

  /// No description provided for @choreLaundryTitle.
  ///
  /// In en, this message translates to:
  /// **'Put Away Laundry'**
  String get choreLaundryTitle;

  /// No description provided for @choreStairsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vacuum the Stairs'**
  String get choreStairsTitle;

  /// No description provided for @choreQueenieTitle.
  ///
  /// In en, this message translates to:
  /// **'Brush Queenie'**
  String get choreQueenieTitle;

  /// No description provided for @choreToiletTitle.
  ///
  /// In en, this message translates to:
  /// **'Clean the Toilet'**
  String get choreToiletTitle;

  /// No description provided for @choreDogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare Dog Food'**
  String get choreDogsTitle;

  /// No description provided for @choreDogsNote.
  ///
  /// In en, this message translates to:
  /// **'Including feeding'**
  String get choreDogsNote;

  /// No description provided for @choreSportTitle.
  ///
  /// In en, this message translates to:
  /// **'Sports Activity'**
  String get choreSportTitle;

  /// No description provided for @choreGardenTitle.
  ///
  /// In en, this message translates to:
  /// **'Water the Garden'**
  String get choreGardenTitle;

  /// No description provided for @choreGardenNote.
  ///
  /// In en, this message translates to:
  /// **'Care for plants & carnivorous flora'**
  String get choreGardenNote;

  /// No description provided for @choreEveningTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening Tidy-Up'**
  String get choreEveningTitle;

  /// No description provided for @choreEveningNote.
  ///
  /// In en, this message translates to:
  /// **'Kitchen, hallway, and living room'**
  String get choreEveningNote;

  /// No description provided for @choreBathroomTitle.
  ///
  /// In en, this message translates to:
  /// **'Clean the Bathroom'**
  String get choreBathroomTitle;

  /// No description provided for @choreMopTitle.
  ///
  /// In en, this message translates to:
  /// **'Steam Mop the Floors'**
  String get choreMopTitle;

  /// No description provided for @choreIroningTitle.
  ///
  /// In en, this message translates to:
  /// **'Ironing'**
  String get choreIroningTitle;

  /// No description provided for @choreCookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Cook a Meal'**
  String get choreCookingTitle;

  /// No description provided for @choreSchoolTitle.
  ///
  /// In en, this message translates to:
  /// **'Study / Schoolwork'**
  String get choreSchoolTitle;

  /// No description provided for @choreRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep-Clean Bedroom'**
  String get choreRoomTitle;

  /// No description provided for @choreRoomNote.
  ///
  /// In en, this message translates to:
  /// **'Major deep clean'**
  String get choreRoomNote;

  /// No description provided for @sexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get sexMale;

  /// No description provided for @sexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get sexFemale;

  /// No description provided for @sexNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get sexNeutral;

  /// No description provided for @periodCurrentMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get periodCurrentMonth;

  /// No description provided for @periodPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get periodPreviousMonth;

  /// No description provided for @periodAllTime.
  ///
  /// In en, this message translates to:
  /// **'Hall of Fame'**
  String get periodAllTime;

  /// No description provided for @sortMostActive.
  ///
  /// In en, this message translates to:
  /// **'Most Active'**
  String get sortMostActive;

  /// No description provided for @sortMostHardWorking.
  ///
  /// In en, this message translates to:
  /// **'Most Hard Working'**
  String get sortMostHardWorking;

  /// No description provided for @sortByStreakLevel.
  ///
  /// In en, this message translates to:
  /// **'By Streak Level'**
  String get sortByStreakLevel;

  /// No description provided for @themeGothicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Victorian mansion, engravings, and The Hand'**
  String get themeGothicSubtitle;

  /// No description provided for @exchangeApprovedBanner.
  ///
  /// In en, this message translates to:
  /// **'EXCHANGE APPROVED BY THE HAND'**
  String get exchangeApprovedBanner;

  /// No description provided for @countedTowardLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Counted toward monthly Leaderboard • {formattedDate}'**
  String countedTowardLeaderboard(String formattedDate);

  /// No description provided for @periodClosingBanner.
  ///
  /// In en, this message translates to:
  /// **'PERIOD CLOSING • {monthKey}'**
  String periodClosingBanner(String monthKey);

  /// No description provided for @chronicleCardPlayedLine.
  ///
  /// In en, this message translates to:
  /// **'{actor} played \"{choreName}\" and stored {coins} Coins in the Pouch.'**
  String chronicleCardPlayedLine(String actor, String choreName, int coins);

  /// No description provided for @chronicleExchangeMessage.
  ///
  /// In en, this message translates to:
  /// **'{actor} exchanged {cardCount} cards for {coins} Coins{czkPart}.'**
  String chronicleExchangeMessage(
    String actor,
    int cardCount,
    int coins,
    String czkPart,
  );

  /// No description provided for @chronicleMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Proclamation • {monthKey}'**
  String chronicleMonthTitle(String monthKey);

  /// No description provided for @chronicleMonthClosedNoWinner.
  ///
  /// In en, this message translates to:
  /// **'Month {monthKey} has closed. Monthly levels reset to Awakened for the new month.'**
  String chronicleMonthClosedNoWinner(String monthKey);

  /// No description provided for @chronicleMonthClosedWinner.
  ///
  /// In en, this message translates to:
  /// **'{winner} became Ruler of {monthKey} ({coins} Coins, {cardCount} chores).'**
  String chronicleMonthClosedWinner(
    String winner,
    String monthKey,
    int coins,
    int cardCount,
  );

  /// No description provided for @chronicleMonthClosedWinnerNoCount.
  ///
  /// In en, this message translates to:
  /// **'{winner} became Ruler of {monthKey} ({coins} Coins).'**
  String chronicleMonthClosedWinnerNoCount(
    String winner,
    String monthKey,
    int coins,
  );

  /// No description provided for @sexSelectorLabel.
  ///
  /// In en, this message translates to:
  /// **'SEX (FOR CHRONICLE WORDING)'**
  String get sexSelectorLabel;

  /// No description provided for @joinFellowshipEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ENTER THE FELLOWSHIP'**
  String get joinFellowshipEyebrow;

  /// No description provided for @acceptInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept Mansion Invite'**
  String get acceptInviteTitle;

  /// No description provided for @acceptInviteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify the gate code and sign your name in the ledger.'**
  String get acceptInviteSubtitle;

  /// No description provided for @inviteForGang.
  ///
  /// In en, this message translates to:
  /// **'Invite to: {name}'**
  String inviteForGang(String name);

  /// No description provided for @existingMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} existing members'**
  String existingMembersCount(int count);

  /// No description provided for @inviteCodeOrLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite code or link'**
  String get inviteCodeOrLinkLabel;

  /// No description provided for @nicknameInMansionLabel.
  ///
  /// In en, this message translates to:
  /// **'Your nickname in this Mansion'**
  String get nicknameInMansionLabel;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;

  /// No description provided for @joiningBtn.
  ///
  /// In en, this message translates to:
  /// **'Joining...'**
  String get joiningBtn;

  /// No description provided for @joinBtn.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinBtn;

  /// No description provided for @invalidInviteCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid Mansion invite code.'**
  String get invalidInviteCodeError;

  /// No description provided for @createMansionCharterEyebrow.
  ///
  /// In en, this message translates to:
  /// **'MANSION FOUNDING CHARTER'**
  String get createMansionCharterEyebrow;

  /// No description provided for @createNewMansionTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Mansion'**
  String get createNewMansionTitle;

  /// No description provided for @createNewMansionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Found a new mansion estate. You become The Hand and master of the treasury rules.'**
  String get createNewMansionSubtitle;

  /// No description provided for @mansionNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Mansion Name'**
  String get mansionNameLabel;

  /// No description provided for @mansionNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Raven Manor'**
  String get mansionNameHint;

  /// No description provided for @founderHandNicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your nickname (The Hand)'**
  String get founderHandNicknameLabel;

  /// No description provided for @creatingBtn.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creatingBtn;

  /// No description provided for @createBtn.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createBtn;

  /// No description provided for @createMansionFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create Mansion.'**
  String get createMansionFailedError;

  /// No description provided for @mansionsManagementEyebrow.
  ///
  /// In en, this message translates to:
  /// **'MANSION MANAGEMENT'**
  String get mansionsManagementEyebrow;

  /// No description provided for @acceptCodeBtn.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get acceptCodeBtn;

  /// No description provided for @manageBtn.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageBtn;

  /// No description provided for @fellowshipsOverview.
  ///
  /// In en, this message translates to:
  /// **'MANSIONS OVERVIEW ({count})'**
  String fellowshipsOverview(int count);

  /// No description provided for @noMansionsYet.
  ///
  /// In en, this message translates to:
  /// **'You are not a member of any Mansion yet.'**
  String get noMansionsYet;

  /// No description provided for @canonQuote.
  ///
  /// In en, this message translates to:
  /// **'“A fellowship without a steadfast manor is merely a band of wanderers in the gale. The Hand rules where the seal keeps the word.”'**
  String get canonQuote;

  /// No description provided for @canonAttribution.
  ///
  /// In en, this message translates to:
  /// **'— CANON OF THE ORDER OF RAVENS'**
  String get canonAttribution;

  /// No description provided for @standbyBadge.
  ///
  /// In en, this message translates to:
  /// **'STANDBY'**
  String get standbyBadge;

  /// No description provided for @roleHandOwnerBadge.
  ///
  /// In en, this message translates to:
  /// **'THE HAND (OWNER)'**
  String get roleHandOwnerBadge;

  /// No description provided for @roleMemberBadge.
  ///
  /// In en, this message translates to:
  /// **'MEMBER'**
  String get roleMemberBadge;

  /// No description provided for @ownerBadge.
  ///
  /// In en, this message translates to:
  /// **'OWNER'**
  String get ownerBadge;

  /// No description provided for @nicknameLine.
  ///
  /// In en, this message translates to:
  /// **'Nickname: {nickname}'**
  String nicknameLine(String nickname);

  /// No description provided for @inviteCodePrefix.
  ///
  /// In en, this message translates to:
  /// **'Invite code: '**
  String get inviteCodePrefix;

  /// No description provided for @exchangeRateLine.
  ///
  /// In en, this message translates to:
  /// **'Rate: {coinsPerCzk} Coins = 1 CZK'**
  String exchangeRateLine(int coinsPerCzk);

  /// No description provided for @mansionDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Mansion deleted.'**
  String get mansionDeletedSnackbar;

  /// No description provided for @mansionWasDeleted.
  ///
  /// In en, this message translates to:
  /// **'Mansion was deleted.'**
  String get mansionWasDeleted;

  /// No description provided for @shareInviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Join my Mansion \"{name}\" on GrimGrind! Open link: {url} (or enter code {code}).'**
  String shareInviteMessage(String name, String url, String code);

  /// No description provided for @manageAndInvitesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage & Invites'**
  String get manageAndInvitesTitle;

  /// No description provided for @roleHandShort.
  ///
  /// In en, this message translates to:
  /// **'THE HAND'**
  String get roleHandShort;

  /// No description provided for @inviteFriendsSection.
  ///
  /// In en, this message translates to:
  /// **'INVITE FRIENDS (IM LINK)'**
  String get inviteFriendsSection;

  /// No description provided for @uniqueInviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'UNIQUE INVITE CODE'**
  String get uniqueInviteCodeLabel;

  /// No description provided for @inviteLinkCopiedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied to share in chat.'**
  String get inviteLinkCopiedSnackbar;

  /// No description provided for @copyInviteLinkBtn.
  ///
  /// In en, this message translates to:
  /// **'Copy Invite Link to Share'**
  String get copyInviteLinkBtn;

  /// No description provided for @newInviteCodeSnackbar.
  ///
  /// In en, this message translates to:
  /// **'New invite code: {code}'**
  String newInviteCodeSnackbar(String code);

  /// No description provided for @regenerateInviteCodeBtn.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Invite Code'**
  String get regenerateInviteCodeBtn;

  /// No description provided for @dangerZoneEyebrow.
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get dangerZoneEyebrow;

  /// No description provided for @deleteMansionWarning.
  ///
  /// In en, this message translates to:
  /// **'Deleting the Mansion permanently removes the entire estate, chronicle, Pouch cards, and all members. This action cannot be undone.'**
  String get deleteMansionWarning;

  /// No description provided for @finalDecisionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'FINAL DECISION'**
  String get finalDecisionEyebrow;

  /// No description provided for @deleteMansionConfirmPrompt.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes \"{name}\" including all cards and history. Type the exact Mansion name to confirm:'**
  String deleteMansionConfirmPrompt(String name);

  /// No description provided for @typeExactNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Type: {name}'**
  String typeExactNameLabel(String name);

  /// No description provided for @keepMansionBtn.
  ///
  /// In en, this message translates to:
  /// **'Keep Mansion'**
  String get keepMansionBtn;

  /// No description provided for @deleteForeverBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get deleteForeverBtn;

  /// No description provided for @themeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'MANSION THEME'**
  String get themeSectionTitle;

  /// No description provided for @handOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'THE HAND ONLY'**
  String get handOnlyLabel;

  /// No description provided for @readOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'READ ONLY'**
  String get readOnlyLabel;

  /// No description provided for @themeOwnerHint.
  ///
  /// In en, this message translates to:
  /// **'The owner can choose a theme package for a new period. Default theme is Gothic Mansion.'**
  String get themeOwnerHint;

  /// No description provided for @themeMemberHint.
  ///
  /// In en, this message translates to:
  /// **'Active theme set by the Mansion owner.'**
  String get themeMemberHint;

  /// No description provided for @defaultShadowMansionName.
  ///
  /// In en, this message translates to:
  /// **'Shadow Mansion'**
  String get defaultShadowMansionName;

  /// No description provided for @defaultMansionFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Mansion'**
  String get defaultMansionFallbackName;

  /// No description provided for @sampleQueenNickname.
  ///
  /// In en, this message translates to:
  /// **'Mansion Queen'**
  String get sampleQueenNickname;

  /// No description provided for @errorSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: {error}'**
  String errorSignInFailed(String error);

  /// No description provided for @errorInvalidEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email and password (min. 6 characters).'**
  String get errorInvalidEmailPassword;

  /// No description provided for @errorRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String errorRegistrationFailed(String error);

  /// No description provided for @errorGoogleSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'User canceled'**
  String get errorGoogleSignInCancelled;

  /// No description provided for @errorGoogleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed: {error}'**
  String errorGoogleSignInFailed(String error);

  /// No description provided for @errorAnonymousSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Anonymous sign-in failed.'**
  String get errorAnonymousSignInFailed;

  /// No description provided for @errorAnonymousSignInException.
  ///
  /// In en, this message translates to:
  /// **'Anonymous sign-in failed: {error}'**
  String errorAnonymousSignInException(String error);

  /// No description provided for @errorSignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Please sign in first.'**
  String get errorSignInFirst;

  /// No description provided for @errorAccountRequiredToCreate.
  ///
  /// In en, this message translates to:
  /// **'Sign in with an account to create a Mansion.'**
  String get errorAccountRequiredToCreate;

  /// No description provided for @errorCreateMansionServer.
  ///
  /// In en, this message translates to:
  /// **'Failed to create Mansion on server.'**
  String get errorCreateMansionServer;

  /// No description provided for @errorCreateMansionException.
  ///
  /// In en, this message translates to:
  /// **'Error creating Mansion: {error}'**
  String errorCreateMansionException(String error);

  /// No description provided for @errorEnterInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Mansion invite code.'**
  String get errorEnterInviteCode;

  /// No description provided for @errorAccountRequiredToJoin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with an account to join a Mansion.'**
  String get errorAccountRequiredToJoin;

  /// No description provided for @errorInviteNotFound.
  ///
  /// In en, this message translates to:
  /// **'Invite code {code} not found.'**
  String errorInviteNotFound(String code);

  /// No description provided for @errorLoadMansionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load Mansion for code {code}.'**
  String errorLoadMansionFailed(String code);

  /// No description provided for @errorJoinMansionException.
  ///
  /// In en, this message translates to:
  /// **'Error joining Mansion: {error}'**
  String errorJoinMansionException(String error);

  /// No description provided for @welcomeToMansionTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the mansion'**
  String get welcomeToMansionTitle;

  /// No description provided for @welcomeToMansionBody.
  ///
  /// In en, this message translates to:
  /// **'You have joined \"{name}\". Everything is set up and ready.'**
  String welcomeToMansionBody(String name);

  /// No description provided for @welcomeToMansionConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get welcomeToMansionConfirmBtn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
