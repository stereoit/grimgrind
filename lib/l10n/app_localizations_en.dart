// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navChronicle => 'Chronicle';

  @override
  String get navPouch => 'Pouch';

  @override
  String get navLeaderboard => 'Leaderboard';

  @override
  String get navMansion => 'Mansion';

  @override
  String get deckTitle => 'Deck';

  @override
  String get playCardFab => 'Play Card';

  @override
  String get skip => 'Skip';

  @override
  String get nextRuleCard => 'Next Rule Card';

  @override
  String get enterMansion => 'Enter the Mansion';

  @override
  String get splashTagline => 'THE MANSION & HOUSEHOLD GRIND';

  @override
  String get splashLoading => 'SWEEPING COBWEBS FROM THE MANSION...';

  @override
  String get onboardingRule1Eyebrow => 'RULE I • BOOK OF CARDS';

  @override
  String get onboardingRule1Title => 'Shared Mansion Deck';

  @override
  String get onboardingRule1Text =>
      'The entire household draws from the same book of 17 chores. No locking or waiting — as soon as you finish a chore, play the card straight into the Chronicle.';

  @override
  String get onboardingRule2Eyebrow => 'RULE II • COINS, LEVEL & HEAT';

  @override
  String get onboardingRule2Title => 'Blazing Reward Multipliers';

  @override
  String get onboardingRule2Text =>
      'Play cards throughout the month to rise from Awakened to Godlike. Playing regularly stokes your Heat, which cools down when you slack off.';

  @override
  String get onboardingRule3Eyebrow => 'RULE III • THE HAND & LEADERBOARD';

  @override
  String get onboardingRule3Title => 'Exchange Pouch & Rule the Mansion';

  @override
  String get onboardingRule3Text =>
      'Coins drop into your Pouch. Ask The Hand (Founder) to exchange them for real money anytime. Only approved exchanges count toward the Leaderboard!';

  @override
  String get authEyebrow => 'MANSION GATE';

  @override
  String get authLoginTitle => 'Sign In';

  @override
  String get authRegisterTitle => 'Create Account';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authSignInBtn => 'Enter the Mansion';

  @override
  String get authCreateAccountBtn => 'Create Account';

  @override
  String get authVerifyingSeal => 'Verifying seal...';

  @override
  String get authOr => 'OR';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authContinueGuest => 'Continue as Guest';

  @override
  String get authSubtitle =>
      'Sign in to your household or create a new account.';

  @override
  String get authSignInTab => 'Sign In';

  @override
  String get authRegisterTab => 'Register';

  @override
  String get authFailedFallback => 'Authentication failed.';

  @override
  String get authGoogleFailedFallback => 'Google sign-in failed.';

  @override
  String get authFooterQuote =>
      '“Whoever crosses the threshold without a seal becomes a mere shadow in the chronicle.”';

  @override
  String get sealSentEyebrow => 'SEAL SENT';

  @override
  String get verifyEmailTitle => 'Verify Your Email';

  @override
  String verifyEmailBody(String email) {
    return 'We sent a verification link to $email. Confirm it in your inbox — meanwhile you can continue into the Mansion.';
  }

  @override
  String get continueToAvatar => 'Continue to Avatar Creation';

  @override
  String get createAvatarEyebrow => 'CREATE YOUR AVATAR';

  @override
  String get createAvatarHint => 'Your Mansion nickname';

  @override
  String get continueToMansion => 'Continue to Mansion';

  @override
  String get createAvatarTitle => 'Your Dark Avatar';

  @override
  String get createAvatarSubtitle =>
      'Choose your nickname and likeness for the Mansion chronicle.';

  @override
  String get createAvatarNicknameLabel => 'Your dark nickname';

  @override
  String get nicknameExampleHint => 'e.g. Shadow Master';

  @override
  String get gangSetupTitle => 'Enter a Mansion';

  @override
  String get gangSetupCreateBtn => 'Create Mansion & Become The Hand';

  @override
  String get gangSetupCreating => 'Creating Mansion...';

  @override
  String get gangSetupJoinBtn => 'Join Mansion';

  @override
  String get gangSetupJoining => 'Joining...';

  @override
  String get gangSetupQuickStart => 'Quick Start with Sample Mansion';

  @override
  String get gangSetupEyebrow => 'CREATE OR JOIN';

  @override
  String get gangSetupSubtitle =>
      'The founding member becomes The Hand (sets the Coin → CZK rate and approves exchanges) and invites others via an invite code.';

  @override
  String get defaultMansionName => 'Addams Mansion';

  @override
  String get founderNicknameLabel => 'Your nickname (Founder = The Hand)';

  @override
  String get starterFamilyTitle => 'Add sample members & history';

  @override
  String get starterFamilySubtitle =>
      'Ideal for trying out the Leaderboard and exchange approvals right away';

  @override
  String get mansionInviteCodeLabel => 'Mansion Invite Code';

  @override
  String get inviteCodeExampleHint => 'e.g. GRIM-42';

  @override
  String get feedEmptyTitle => 'The Chronicle is Silent';

  @override
  String get feedEmptyText =>
      'No cards played yet. The cobwebs await the first entry.';

  @override
  String get deckEyebrow => 'MANSION BOOK OF CARDS';

  @override
  String get deckHeading => 'Choose a completed card';

  @override
  String deckBonusSummary(
    String levelLabel,
    int levelPct,
    String heatLabel,
    int heatPct,
    int totalPct,
  ) {
    return 'Level $levelLabel (+$levelPct%) • $heatLabel (+$heatPct%) = +$totalPct% total Coins.';
  }

  @override
  String deckAllFilter(int count) {
    return 'All ($count)';
  }

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultySpecial => 'Special';

  @override
  String get levelAwakened => 'Awakened';

  @override
  String get levelRestlessSpirit => 'Restless Spirit';

  @override
  String get levelBloodthirsty => 'Bloodthirsty';

  @override
  String get levelUnstoppable => 'Unstoppable';

  @override
  String get levelGodlike => 'Godlike';

  @override
  String get heatColdAsh => 'Cold Ash';

  @override
  String get heatGlowingEmbers => 'Glowing Embers';

  @override
  String get heatBlazingForge => 'Blazing Forge';

  @override
  String get heatHellfire => 'Hellfire';

  @override
  String get heatRuleColdAsh => 'Default state or 4+ days break';

  @override
  String get heatRuleGlowingEmbers =>
      'Min. 2 active days • keep: 1× per 3 days';

  @override
  String get heatRuleBlazingForge => 'Min. 4 active days • keep: 1× per 3 days';

  @override
  String get heatRuleHellfire => 'Min. 7 active days • keep: every day';

  @override
  String get estimateLabel => 'ESTIMATE';

  @override
  String get difficultyStatLabel => 'DIFFICULTY';

  @override
  String get pouchRewardLabel => 'POUCH REWARD';

  @override
  String get playCardPrefix => 'Play Card (+';

  @override
  String cardPlayedSnackbar(int coins) {
    return 'Played! +$coins added to your Pouch.';
  }

  @override
  String get pouchEyebrow => 'YOUR POUCH';

  @override
  String get pouchHeading => 'Pouch & Hand Exchange';

  @override
  String get pouchEmpty => 'Pouch is empty';

  @override
  String requestExchangeBtn(int count) {
    return 'Request Hand Exchange ($count)';
  }

  @override
  String exchangeRequestedSnackbar(int totalCoins) {
    return 'Exchange request for $totalCoins coins sent to The Hand.';
  }

  @override
  String get playedCardsInPouchSection => 'PLAYED CARDS IN POUCH';

  @override
  String get pendingCardsSection => 'MY CARDS AWAITING HAND APPROVAL';

  @override
  String get handManagementSection => 'HAND MANAGEMENT (FOUNDER)';

  @override
  String get closeMonthBtn => 'Close Month (Auto-Exchange & Winner)';

  @override
  String monthClosedSnackbar(int created) {
    return 'Month closed! Generated $created automatic exchange requests.';
  }

  @override
  String get noPendingExchanges => 'No pending exchange requests';

  @override
  String get autoMonthEndLabel => 'Automatic month-end closing';

  @override
  String get rejectCardTooltip => 'Reject card';

  @override
  String approveExchangeBtn(int totalCoins) {
    return 'Approve Exchange ($totalCoins)';
  }

  @override
  String get leaderboardEyebrow => 'MANSION HALL OF HEROES';

  @override
  String get leaderboardHeading => 'Player Leaderboard';

  @override
  String get leaderboardSubtitle =>
      'Only cards approved in a Hand Exchange count.';

  @override
  String get leaderboardStatTasks => 'CHORES';

  @override
  String get leaderboardStatCoins => 'COINS';

  @override
  String get leaderboardStatStreak => 'STREAK';

  @override
  String get leaderboardStatTime => 'TIME';

  @override
  String inPouchWaitingPrefix(int count) {
    return 'Waiting in Pouch: $count cards (';
  }

  @override
  String inviteCodeLine(String code) {
    return 'Mansion invite code: $code';
  }

  @override
  String accountLine(String email) {
    return 'Account: $email';
  }

  @override
  String get yourAvatarSection => 'YOUR AVATAR';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get sexLabel => 'Sex';

  @override
  String get myMansionsSection => 'MY MANSIONS';

  @override
  String get createMansionBtn => 'Create Mansion';

  @override
  String get joinMansionBtn => 'Join Mansion';

  @override
  String get activeMansionBadge => 'ACTIVE';

  @override
  String get inactiveBadge => 'INACTIVE';

  @override
  String membersCountLabel(int count) {
    return '$count Members';
  }

  @override
  String get membersSectionTitle => 'MEMBERS';

  @override
  String get setActiveMansionBtn => 'Set as Active Mansion';

  @override
  String get leaveMansionBtn => 'Leave Mansion';

  @override
  String get leaveMansionConfirmTitle => 'Leave Mansion?';

  @override
  String leaveMansionConfirmBody(String name) {
    return 'Are you sure you want to leave \"$name\"? You will need an invite code to rejoin.';
  }

  @override
  String get deleteMansionBtn => 'Delete Mansion';

  @override
  String get deleteMansionConfirmTitle => 'Delete Mansion?';

  @override
  String get myGangsBtn => 'My Mansions';

  @override
  String get inviteManageBtn => 'Invite / Manage';

  @override
  String get switchMemberSection => 'SWITCH MEMBER (TEST / HOUSEHOLD)';

  @override
  String get roleHandSubtitle => 'Founder • The Hand';

  @override
  String get roleMemberSubtitle => 'Mansion Member';

  @override
  String get renameNicknameLabel => 'Change my nickname';

  @override
  String get saveBtn => 'Save';

  @override
  String get avatarSavedSnackbar => 'Avatar saved.';

  @override
  String get logoutBtn => 'Log Out';

  @override
  String get logoutConfirmTitle => 'Log Out?';

  @override
  String get logoutConfirmBody =>
      'You will be signed out of your account and returned to the sign-in screen.';

  @override
  String logoutConfirmBodyEmail(String email) {
    return 'Sign out of $email and return to the sign-in screen?';
  }

  @override
  String get appUpdatesTitle => 'App Updates';

  @override
  String get checkNewVersion => 'Check for new version';

  @override
  String currentVersionLine(String version, int build) {
    return 'Current version $version (#$build)';
  }

  @override
  String get latestVersionSnackbar => 'You have the latest available version.';

  @override
  String newVersionTitle(String version, int build) {
    return 'New version $version (#$build)';
  }

  @override
  String get updateLaterBtn => 'Later';

  @override
  String get updateNowBtn => 'Update';

  @override
  String get choreTrashTitle => 'Take Out the Trash';

  @override
  String get choreShoppingTitle => 'Unpack Groceries';

  @override
  String get choreDishwasherTitle => 'Empty the Dishwasher';

  @override
  String get choreLaundryTitle => 'Put Away Laundry';

  @override
  String get choreStairsTitle => 'Vacuum the Stairs';

  @override
  String get choreQueenieTitle => 'Brush Queenie';

  @override
  String get choreToiletTitle => 'Clean the Toilet';

  @override
  String get choreDogsTitle => 'Prepare Dog Food';

  @override
  String get choreDogsNote => 'Including feeding';

  @override
  String get choreSportTitle => 'Sports Activity';

  @override
  String get choreGardenTitle => 'Water the Garden';

  @override
  String get choreGardenNote => 'Care for plants & carnivorous flora';

  @override
  String get choreEveningTitle => 'Evening Tidy-Up';

  @override
  String get choreEveningNote => 'Kitchen, hallway, and living room';

  @override
  String get choreBathroomTitle => 'Clean the Bathroom';

  @override
  String get choreMopTitle => 'Steam Mop the Floors';

  @override
  String get choreIroningTitle => 'Ironing';

  @override
  String get choreCookingTitle => 'Cook a Meal';

  @override
  String get choreSchoolTitle => 'Study / Schoolwork';

  @override
  String get choreRoomTitle => 'Deep-Clean Bedroom';

  @override
  String get choreRoomNote => 'Major deep clean';

  @override
  String get sexMale => 'Male';

  @override
  String get sexFemale => 'Female';

  @override
  String get sexNeutral => 'Neutral';

  @override
  String get periodCurrentMonth => 'This Month';

  @override
  String get periodPreviousMonth => 'Last Month';

  @override
  String get periodAllTime => 'Hall of Fame';

  @override
  String get sortMostActive => 'Most Active';

  @override
  String get sortMostHardWorking => 'Most Hard Working';

  @override
  String get sortByStreakLevel => 'By Streak Level';

  @override
  String get themeGothicSubtitle =>
      'Dark Victorian mansion, engravings, and The Hand';

  @override
  String get exchangeApprovedBanner => 'EXCHANGE APPROVED BY THE HAND';

  @override
  String countedTowardLeaderboard(String formattedDate) {
    return 'Counted toward monthly Leaderboard • $formattedDate';
  }

  @override
  String periodClosingBanner(String monthKey) {
    return 'PERIOD CLOSING • $monthKey';
  }

  @override
  String feedCardPlayedLine(String actor, String choreName, int coins) {
    return '$actor played \"$choreName\" and stored $coins Coins in the Pouch.';
  }

  @override
  String feedExchangeMessage(
    String actor,
    int cardCount,
    int coins,
    String czkPart,
  ) {
    return '$actor exchanged $cardCount cards for $coins Coins$czkPart.';
  }

  @override
  String feedMonthTitle(String monthKey) {
    return 'Monthly Proclamation • $monthKey';
  }

  @override
  String feedMonthClosedNoWinner(String monthKey) {
    return 'Month $monthKey has closed. Monthly levels reset to Awakened for the new month.';
  }

  @override
  String feedMonthClosedWinner(
    String winner,
    String monthKey,
    int coins,
    int cardCount,
  ) {
    return '$winner became Ruler of $monthKey ($coins Coins, $cardCount chores).';
  }

  @override
  String feedMonthClosedWinnerNoCount(
    String winner,
    String monthKey,
    int coins,
  ) {
    return '$winner became Ruler of $monthKey ($coins Coins).';
  }

  @override
  String get sexSelectorLabel => 'SEX (FOR CHRONICLE WORDING)';

  @override
  String get joinFellowshipEyebrow => 'ENTER THE FELLOWSHIP';

  @override
  String get acceptInviteTitle => 'Accept Mansion Invite';

  @override
  String get acceptInviteSubtitle =>
      'Verify the gate code and sign your name in the ledger.';

  @override
  String inviteForGang(String name) {
    return 'Invite to: $name';
  }

  @override
  String existingMembersCount(int count) {
    return '$count existing members';
  }

  @override
  String get inviteCodeOrLinkLabel => 'Invite code or link';

  @override
  String get nicknameInMansionLabel => 'Your nickname in this Mansion';

  @override
  String get cancelBtn => 'Cancel';

  @override
  String get joiningBtn => 'Joining...';

  @override
  String get joinBtn => 'Join';

  @override
  String get invalidInviteCodeError => 'Invalid Mansion invite code.';

  @override
  String get createMansionCharterEyebrow => 'MANSION FOUNDING CHARTER';

  @override
  String get createNewMansionTitle => 'Create New Mansion';

  @override
  String get createNewMansionSubtitle =>
      'Found a new mansion estate. You become The Hand and master of the treasury rules.';

  @override
  String get mansionNameLabel => 'Mansion Name';

  @override
  String get mansionNameHint => 'e.g. Raven Manor';

  @override
  String get founderHandNicknameLabel => 'Your nickname (The Hand)';

  @override
  String get creatingBtn => 'Creating...';

  @override
  String get createBtn => 'Create';

  @override
  String get createMansionFailedError => 'Failed to create Mansion.';

  @override
  String get mansionsManagementEyebrow => 'MANSION MANAGEMENT';

  @override
  String get acceptCodeBtn => 'Enter Code';

  @override
  String get manageBtn => 'Manage';

  @override
  String fellowshipsOverview(int count) {
    return 'MANSIONS OVERVIEW ($count)';
  }

  @override
  String get noMansionsYet => 'You are not a member of any Mansion yet.';

  @override
  String get canonQuote =>
      '“A fellowship without a steadfast manor is merely a band of wanderers in the gale. The Hand rules where the seal keeps the word.”';

  @override
  String get canonAttribution => '— CANON OF THE ORDER OF RAVENS';

  @override
  String get standbyBadge => 'STANDBY';

  @override
  String get roleHandOwnerBadge => 'THE HAND (OWNER)';

  @override
  String get roleMemberBadge => 'MEMBER';

  @override
  String get ownerBadge => 'OWNER';

  @override
  String nicknameLine(String nickname) {
    return 'Nickname: $nickname';
  }

  @override
  String get inviteCodePrefix => 'Invite code: ';

  @override
  String exchangeRateLine(int coinsPerCzk) {
    return 'Rate: $coinsPerCzk Coins = 1 CZK';
  }

  @override
  String get mansionDeletedSnackbar => 'Mansion deleted.';

  @override
  String get mansionWasDeleted => 'Mansion was deleted.';

  @override
  String shareInviteMessage(String name, String url, String code) {
    return 'Join my Mansion \"$name\" on GrimGrind! Open link: $url (or enter code $code).';
  }

  @override
  String get manageAndInvitesTitle => 'Manage & Invites';

  @override
  String get roleHandShort => 'THE HAND';

  @override
  String get inviteFriendsSection => 'INVITE FRIENDS (IM LINK)';

  @override
  String get uniqueInviteCodeLabel => 'UNIQUE INVITE CODE';

  @override
  String get inviteLinkCopiedSnackbar => 'Invite link copied to share in chat.';

  @override
  String get copyInviteLinkBtn => 'Copy Invite Link to Share';

  @override
  String newInviteCodeSnackbar(String code) {
    return 'New invite code: $code';
  }

  @override
  String get regenerateInviteCodeBtn => 'Regenerate Invite Code';

  @override
  String get dangerZoneEyebrow => 'DANGER ZONE';

  @override
  String get deleteMansionWarning =>
      'Deleting the Mansion permanently removes the entire estate, chronicle, Pouch cards, and all members. This action cannot be undone.';

  @override
  String get finalDecisionEyebrow => 'FINAL DECISION';

  @override
  String deleteMansionConfirmPrompt(String name) {
    return 'This permanently deletes \"$name\" including all cards and history. Type the exact Mansion name to confirm:';
  }

  @override
  String typeExactNameLabel(String name) {
    return 'Type: $name';
  }

  @override
  String get keepMansionBtn => 'Keep Mansion';

  @override
  String get deleteForeverBtn => 'Delete Forever';

  @override
  String get themeSectionTitle => 'MANSION THEME';

  @override
  String get handOnlyLabel => 'THE HAND ONLY';

  @override
  String get readOnlyLabel => 'READ ONLY';

  @override
  String get themeOwnerHint =>
      'The owner can choose a theme package for a new period. Default theme is Gothic Mansion.';

  @override
  String get themeMemberHint => 'Active theme set by the Mansion owner.';

  @override
  String get defaultShadowMansionName => 'Shadow Mansion';

  @override
  String get defaultMansionFallbackName => 'Mansion';

  @override
  String get sampleQueenNickname => 'Mansion Queen';

  @override
  String errorSignInFailed(String error) {
    return 'Sign-in failed: $error';
  }

  @override
  String get errorInvalidEmailPassword =>
      'Enter a valid email and password (min. 6 characters).';

  @override
  String errorRegistrationFailed(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get errorGoogleSignInCancelled => 'User canceled';

  @override
  String errorGoogleSignInFailed(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String get errorAnonymousSignInFailed => 'Anonymous sign-in failed.';

  @override
  String errorAnonymousSignInException(String error) {
    return 'Anonymous sign-in failed: $error';
  }

  @override
  String get errorSignInFirst => 'Please sign in first.';

  @override
  String get errorAccountRequiredToCreate =>
      'Sign in with an account to create a Mansion.';

  @override
  String get errorCreateMansionServer => 'Failed to create Mansion on server.';

  @override
  String errorCreateMansionException(String error) {
    return 'Error creating Mansion: $error';
  }

  @override
  String get errorEnterInviteCode => 'Enter Mansion invite code.';

  @override
  String get errorAccountRequiredToJoin =>
      'Sign in with an account to join a Mansion.';

  @override
  String errorInviteNotFound(String code) {
    return 'Invite code $code not found.';
  }

  @override
  String errorLoadMansionFailed(String code) {
    return 'Could not load Mansion for code $code.';
  }

  @override
  String errorJoinMansionException(String error) {
    return 'Error joining Mansion: $error';
  }
}
