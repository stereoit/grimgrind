// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get navChronicle => 'Kronika';

  @override
  String get navPouch => 'Mešec';

  @override
  String get navLeaderboard => 'Žebříček';

  @override
  String get navMansion => 'Sídlo';

  @override
  String get deckTitle => 'Kniha karet';

  @override
  String get playCardFab => 'Zahrát kartu';

  @override
  String get skip => 'Přeskočit';

  @override
  String get nextRuleCard => 'Další karta pravidel';

  @override
  String get enterMansion => 'Vstoupit do Sídla';

  @override
  String get splashTagline => 'SÍDLO A DOMÁCÍ KÁZEŇ';

  @override
  String get splashLoading => 'VYMETÁNÍ PAVUČIN ZE SÍDLA...';

  @override
  String get onboardingRule1Eyebrow => 'PRAVIDLO I • KNIHA KARET';

  @override
  String get onboardingRule1Title => 'Sdílený Deck Sídla';

  @override
  String get onboardingRule1Text =>
      'Celá domácnost vybírá ze stejné knihy 17 úkolů. Žádné zamykání ani čekání – jakmile úkol splníš, rovnou kartu zahraješ do společného Feedu.';

  @override
  String get onboardingRule2Eyebrow => 'PRAVIDLO II • COINY, LEVEL & HEAT';

  @override
  String get onboardingRule2Title => 'Žhavé Násobiče Odměn';

  @override
  String get onboardingRule2Text =>
      'Během měsíce sbíráš karty a postupuješ od Probuzeného až k Nesmrtelnému. Pravidelným hraním navíc rozdmýcháš Heat, který chladne při lenošení.';

  @override
  String get onboardingRule3Eyebrow => 'PRAVIDLO III • RUKA & LEADERBOARD';

  @override
  String get onboardingRule3Title => 'Směň Bank a Ovládni Sídlo';

  @override
  String get onboardingRule3Text =>
      'Coiny padají do tvého Banku. Kdykoliv požádej Ruku (Zakladatele) o směnu na skutečné peníze. Teprve schválené směny se počítají do Leaderboardu!';

  @override
  String get authEyebrow => 'BRÁNA DO SÍDLA';

  @override
  String get authLoginTitle => 'Přihlášení';

  @override
  String get authRegisterTitle => 'Registrace';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authPasswordLabel => 'Heslo';

  @override
  String get authSignInBtn => 'Vstoupit do Sídla';

  @override
  String get authCreateAccountBtn => 'Vytvořit účet';

  @override
  String get authVerifyingSeal => 'Ověřuji pečeť...';

  @override
  String get authOr => 'NEBO';

  @override
  String get authContinueGoogle => 'Pokračovat přes Google';

  @override
  String get authContinueGuest => 'Pokračovat anonymně jako host';

  @override
  String get authSubtitle => 'Přihlas se do svého rodu nebo založ nový účet.';

  @override
  String get authSignInTab => 'Přihlásit se';

  @override
  String get authRegisterTab => 'Registrace';

  @override
  String get authFailedFallback => 'Ověření se nezdařilo.';

  @override
  String get authGoogleFailedFallback => 'Přihlášení přes Google selhalo.';

  @override
  String get authFooterQuote =>
      '„Kdo překročí práh bez pečetě, stane se pouhým stínem v kronice.“';

  @override
  String get sealSentEyebrow => 'PEČEŤ ODESLÁNA';

  @override
  String get verifyEmailTitle => 'Ověř svůj e-mail';

  @override
  String verifyEmailBody(String email) {
    return 'Na adresu $email jsme odeslali ověřovací odkaz. Potvrď ho ve své schránce, a mezitím můžeš pokračovat do Sídla.';
  }

  @override
  String get continueToAvatar => 'Pokračovat k tvorbě avatara';

  @override
  String get createAvatarEyebrow => 'STVOŘENÍ AVATARA';

  @override
  String get createAvatarHint => 'Tvoje přezdívka v Sídle';

  @override
  String get continueToMansion => 'Pokračovat do Sídla';

  @override
  String get createAvatarTitle => 'Tvůj Temný Avatar';

  @override
  String get createAvatarSubtitle =>
      'Zvol si přezdívku a rodovou podobu pro kroniku Sídla.';

  @override
  String get createAvatarNicknameLabel => 'Tvoje temná přezdívka';

  @override
  String get nicknameExampleHint => 'Např. Shadow Master';

  @override
  String get gangSetupTitle => 'Vstup do Sídla';

  @override
  String get gangSetupCreateBtn => 'Založit Sídlo a stát se Rukou';

  @override
  String get gangSetupCreating => 'Zakládám Sídlo...';

  @override
  String get gangSetupJoinBtn => 'Připojit se k Sídlu';

  @override
  String get gangSetupJoining => 'Připojuji se...';

  @override
  String get gangSetupQuickStart => 'Rychlý start s ukázkovým Sídlem';

  @override
  String get gangSetupEyebrow => 'ZALOŽENÍ NEBO PŘIPOJENÍ';

  @override
  String get gangSetupSubtitle =>
      'Zakládající člen získá roli Ruky (nastavuje kurz Coin → Kč a schvaluje směny) a pozve ostatní přes zvací kód.';

  @override
  String get defaultMansionName => 'Sídlo Addamsů';

  @override
  String get founderNicknameLabel => 'Tvoje přezdívka (Zakladatel = Ruka)';

  @override
  String get starterFamilyTitle => 'Přidat ukázkové členy & historii';

  @override
  String get starterFamilySubtitle =>
      'Ideální pro okamžité vyzkoušení Leaderboardu a schvalování směn';

  @override
  String get mansionInviteCodeLabel => 'Zvací kód Sídla';

  @override
  String get inviteCodeExampleHint => 'Např. GRIM-42';

  @override
  String get feedEmptyTitle => 'Kronika sídla mlčí';

  @override
  String get feedEmptyText =>
      'Zatím žádná zahraná karta. Pavučiny čekají na první zápis.';

  @override
  String get deckEyebrow => 'KNIHA KARET SÍDLA';

  @override
  String get deckHeading => 'Vyber splněnou kartu';

  @override
  String deckBonusSummary(
    String levelLabel,
    int levelPct,
    String heatLabel,
    int heatPct,
    int totalPct,
  ) {
    return 'Level $levelLabel (+$levelPct %) • $heatLabel (+$heatPct %) = celkem +$totalPct % Coinů.';
  }

  @override
  String deckAllFilter(int count) {
    return 'Všechny ($count)';
  }

  @override
  String get difficultyEasy => 'Pohoda';

  @override
  String get difficultyMedium => 'Horší';

  @override
  String get difficultyHard => 'Těžké';

  @override
  String get difficultySpecial => 'Speciální';

  @override
  String get levelAwakened => 'Probuzený';

  @override
  String get levelRestlessSpirit => 'Nepokojný duch';

  @override
  String get levelBloodthirsty => 'Krvežíznivý';

  @override
  String get levelUnstoppable => 'Nezastavitelný';

  @override
  String get levelGodlike => 'Nesmrtelný';

  @override
  String get heatColdAsh => 'Vychladlý popel';

  @override
  String get heatGlowingEmbers => 'Žhnoucí uhlíky';

  @override
  String get heatBlazingForge => 'Rozpálená výheň';

  @override
  String get heatHellfire => 'Pekelný žár';

  @override
  String get heatRuleColdAsh => 'Výchozí stav nebo pauza 4+ dny';

  @override
  String get heatRuleGlowingEmbers =>
      'Min. 2 dny aktivity • udržení: 1× za 3 dny';

  @override
  String get heatRuleBlazingForge =>
      'Min. 4 dny aktivity • udržení: 1× za 3 dny';

  @override
  String get heatRuleHellfire => 'Min. 7 dní aktivity • udržení: každý den';

  @override
  String get estimateLabel => 'ODHAD';

  @override
  String get difficultyStatLabel => 'OBTÍŽNOST';

  @override
  String get pouchRewardLabel => 'ZISK DO MEŠCE';

  @override
  String get playCardPrefix => 'Zahrát kartu (+';

  @override
  String cardPlayedSnackbar(int coins) {
    return 'Zahráno! +$coins připsáno do tvého Mešce.';
  }

  @override
  String get pouchEyebrow => 'TVŮJ MEŠEC';

  @override
  String get pouchHeading => 'Mešec & Směna u Ruky';

  @override
  String get pouchEmpty => 'Mešec je prázdný';

  @override
  String requestExchangeBtn(int count) {
    return 'Požádat Ruku o směnu ($count)';
  }

  @override
  String exchangeRequestedSnackbar(int totalCoins) {
    return 'Žádost o směnu $totalCoins zlaťáků odeslána Ruce.';
  }

  @override
  String get playedCardsInPouchSection => 'ZAHRANÉ KARTY V MEŠCI';

  @override
  String get pendingCardsSection => 'MOJE KARTY ČEKAJÍCÍ NA POTVRZENÍ RUKOU';

  @override
  String get handManagementSection => 'SPRÁVA RUKY (ZAKLADATEL)';

  @override
  String get closeMonthBtn => 'Uzavřít měsíc (Auto-směna & Výherce)';

  @override
  String monthClosedSnackbar(int created) {
    return 'Měsíc uzavřen! Vygenerováno $created automatických žádostí o směnu.';
  }

  @override
  String get noPendingExchanges => 'Žádné čekající žádosti o směnu';

  @override
  String get autoMonthEndLabel => 'Automatická uzávěrka měsíce';

  @override
  String get rejectCardTooltip => 'Neuznat kartu';

  @override
  String approveExchangeBtn(int totalCoins) {
    return 'Schválit směnu ($totalCoins)';
  }

  @override
  String get leaderboardEyebrow => 'SÍŇ HRDINŮ SÍDLA';

  @override
  String get leaderboardHeading => 'Leaderboard Hráčů';

  @override
  String get leaderboardSubtitle =>
      'Počítají se výhradně karty potvrzené směnou u Ruky.';

  @override
  String get leaderboardStatTasks => 'ÚKOLY';

  @override
  String get leaderboardStatCoins => 'COINY';

  @override
  String get leaderboardStatStreak => 'STREAK';

  @override
  String get leaderboardStatTime => 'ČAS';

  @override
  String inPouchWaitingPrefix(int count) {
    return 'V Mešci čeká: $count karet (';
  }

  @override
  String inviteCodeLine(String code) {
    return 'Zvací kód pro členy Sídla: $code';
  }

  @override
  String accountLine(String email) {
    return 'Účet: $email';
  }

  @override
  String get yourAvatarSection => 'TVŮJ AVATAR';

  @override
  String get nicknameLabel => 'Přezdívka';

  @override
  String get sexLabel => 'Pohlaví';

  @override
  String get myMansionsSection => 'MOJE SÍDLA';

  @override
  String get createMansionBtn => 'Založit Sídlo';

  @override
  String get joinMansionBtn => 'Připojit se';

  @override
  String get activeMansionBadge => 'AKTIVNÍ';

  @override
  String get inactiveBadge => 'NEAKTIVNÍ';

  @override
  String membersCountLabel(int count) {
    return '$count členů';
  }

  @override
  String get membersSectionTitle => 'ČLENOVÉ SÍDLA';

  @override
  String get setActiveMansionBtn => 'Nastavit jako aktivní Sídlo';

  @override
  String get leaveMansionBtn => 'Opustit Sídlo';

  @override
  String get leaveMansionConfirmTitle => 'Opustit Sídlo?';

  @override
  String leaveMansionConfirmBody(String name) {
    return 'Opravdu chceš opustit Sídlo „$name“? Budeš potřebovat nový zvací kód pro návrat.';
  }

  @override
  String get deleteMansionBtn => 'Smazat Sídlo';

  @override
  String get deleteMansionConfirmTitle => 'Opravdu smazat Sídlo?';

  @override
  String get myGangsBtn => 'Moje Sídla';

  @override
  String get inviteManageBtn => 'Pozvat / Správa';

  @override
  String get switchMemberSection => 'PŘEPNOUT ČLENA (TEST / DOMÁCNOST)';

  @override
  String get roleHandSubtitle => 'Zakladatel • Ruka';

  @override
  String get roleMemberSubtitle => 'Člen Sídla';

  @override
  String get renameNicknameLabel => 'Změnit moji přezdívku';

  @override
  String get saveBtn => 'Uložit';

  @override
  String get avatarSavedSnackbar => 'Avatar uložen.';

  @override
  String get logoutBtn => 'Odhlásit se';

  @override
  String get logoutConfirmTitle => 'Odhlásit se?';

  @override
  String get logoutConfirmBody =>
      'Budeš odhlášen ze svého účtu a přesměrován na přihlášení.';

  @override
  String logoutConfirmBodyEmail(String email) {
    return 'Odhlásit se z účtu $email a vrátit se na přihlášení?';
  }

  @override
  String get appUpdatesTitle => 'Aktualizace aplikace';

  @override
  String get checkNewVersion => 'Zkontrolovat novou verzi';

  @override
  String currentVersionLine(String version, int build) {
    return 'Aktuální verze $version (#$build)';
  }

  @override
  String get latestVersionSnackbar => 'Máš nejnovější dostupnou verzi.';

  @override
  String newVersionTitle(String version, int build) {
    return 'Nová verze $version (#$build)';
  }

  @override
  String get updateLaterBtn => 'Později';

  @override
  String get updateNowBtn => 'Aktualizovat';

  @override
  String get choreTrashTitle => 'Vynést koš';

  @override
  String get choreShoppingTitle => 'Vyklidit nákup';

  @override
  String get choreDishwasherTitle => 'Vyklidit myčku';

  @override
  String get choreLaundryTitle => 'Uklidit si prádlo';

  @override
  String get choreStairsTitle => 'Vysát schodiště';

  @override
  String get choreQueenieTitle => 'Vyčesat Queenie';

  @override
  String get choreToiletTitle => 'Umýt toaletu';

  @override
  String get choreDogsTitle => 'Příprava krmení pro psy';

  @override
  String get choreDogsNote => 'Včetně nakrmení';

  @override
  String get choreSportTitle => 'Sportovní aktivita';

  @override
  String get choreGardenTitle => 'Zalít zahradu';

  @override
  String get choreGardenNote => 'Péče o zeleň i masožravky';

  @override
  String get choreEveningTitle => 'Večerní úklid';

  @override
  String get choreEveningNote => 'Kuchyň, předsíň a obývák';

  @override
  String get choreBathroomTitle => 'Umýt koupelnu';

  @override
  String get choreMopTitle => 'Vytřít parním mopem';

  @override
  String get choreIroningTitle => 'Vyžehlit';

  @override
  String get choreCookingTitle => 'Uvařit jídlo';

  @override
  String get choreSchoolTitle => 'Učení / Škola';

  @override
  String get choreRoomTitle => 'Vygruntovat pokojíček';

  @override
  String get choreRoomNote => 'Velký hloubkový úklid';

  @override
  String get sexMale => 'Muž';

  @override
  String get sexFemale => 'Žena';

  @override
  String get sexNeutral => 'Neutrální';

  @override
  String get periodCurrentMonth => 'Tento měsíc';

  @override
  String get periodPreviousMonth => 'Minulý měsíc';

  @override
  String get periodAllTime => 'Síň slávy';

  @override
  String get sortMostActive => 'Most Active';

  @override
  String get sortMostHardWorking => 'Most Hard Working';

  @override
  String get sortByStreakLevel => 'By Streak Level';

  @override
  String get themeGothicSubtitle => 'Temné viktoriánské sídlo, rytiny a Ruka';

  @override
  String get exchangeApprovedBanner => 'SCHVÁLENÁ SMĚNA RUKOU';

  @override
  String countedTowardLeaderboard(String formattedDate) {
    return 'Započteno do měsíčního Leaderboardu • $formattedDate';
  }

  @override
  String periodClosingBanner(String monthKey) {
    return 'UZÁVĚRKA OBDOBÍ • $monthKey';
  }

  @override
  String feedCardPlayedLine(String actor, String choreName, int coins) {
    return '$actor zahrál/a kartu „$choreName“ a uložil/a $coins Coinů do Banku.';
  }

  @override
  String feedExchangeMessage(
    String actor,
    int cardCount,
    int coins,
    String czkPart,
  ) {
    return '$actor směnil/a $cardCount karet za $coins Coinů$czkPart.';
  }

  @override
  String feedMonthTitle(String monthKey) {
    return 'Měsíční vyhlášení • $monthKey';
  }

  @override
  String feedMonthClosedNoWinner(String monthKey) {
    return 'Měsíc $monthKey byl uzavřen. Levely se s novým měsícem resetují na Probuzený.';
  }

  @override
  String feedMonthClosedWinner(
    String winner,
    String monthKey,
    int coins,
    int cardCount,
  ) {
    return 'Vládcem měsíce $monthKey se stal/a $winner ($coins Coinů, $cardCount úkolů).';
  }

  @override
  String feedMonthClosedWinnerNoCount(
    String winner,
    String monthKey,
    int coins,
  ) {
    return 'Vládcem měsíce $monthKey se stal/a $winner ($coins Coinů).';
  }

  @override
  String get sexSelectorLabel => 'POHLAVÍ (PRO SPRÁVNÉ SKLOŇOVÁNÍ V KRONICE)';

  @override
  String get joinFellowshipEyebrow => 'VSTUP DO SPOLEČENSTVA';

  @override
  String get acceptInviteTitle => 'Přijmout pozvánku do Sídla';

  @override
  String get acceptInviteSubtitle =>
      'Ověřte kód brány a podepište se do rodové knihy.';

  @override
  String inviteForGang(String name) {
    return 'Pozvánka do: $name';
  }

  @override
  String existingMembersCount(int count) {
    return '$count stávajících členů';
  }

  @override
  String get inviteCodeOrLinkLabel => 'Zvací kód nebo odkaz';

  @override
  String get nicknameInMansionLabel => 'Tvoje přezdívka v tomto Sídle';

  @override
  String get cancelBtn => 'Zrušit';

  @override
  String get joiningBtn => 'Připojuji se...';

  @override
  String get joinBtn => 'Připojit se';

  @override
  String get invalidInviteCodeError => 'Neplatný zvací kód Sídla.';

  @override
  String get createMansionCharterEyebrow => 'ZAKLÁDACÍ LISTINA PANSTVÍ';

  @override
  String get createNewMansionTitle => 'Založit nové Sídlo';

  @override
  String get createNewMansionSubtitle =>
      'Vytvořte nové panství sídla. Stanete se Rukou a pánem nad pravidly pokladnice.';

  @override
  String get mansionNameLabel => 'Název Sídla';

  @override
  String get mansionNameHint => 'Např. Sídlo Havranů';

  @override
  String get founderHandNicknameLabel => 'Tvoje přezdívka (Ruka)';

  @override
  String get creatingBtn => 'Zakládám...';

  @override
  String get createBtn => 'Založit';

  @override
  String get createMansionFailedError => 'Nepodařilo se založit Sídlo.';

  @override
  String get mansionsManagementEyebrow => 'SPRÁVA SÍDEL';

  @override
  String get acceptCodeBtn => 'Přijmout kód';

  @override
  String get manageBtn => 'Spravovat';

  @override
  String fellowshipsOverview(int count) {
    return 'PŘEHLED SPOLEČENSTEV ($count)';
  }

  @override
  String get noMansionsYet => 'Zatím nejsi členem žádného Sídla.';

  @override
  String get canonQuote =>
      '„Spolek bez pevného sídla je pouhým hloučkem poutníků ve vichřici. Ruka vládne tam, kde pečeť drží slovo.“';

  @override
  String get canonAttribution => '— KÁNON ŘÁDU HAVRANŮ';

  @override
  String get standbyBadge => 'ZÁLOŽNÍ';

  @override
  String get roleHandOwnerBadge => 'RUKA (VLASTNÍK)';

  @override
  String get roleMemberBadge => 'ČLEN';

  @override
  String get ownerBadge => 'VLASTNÍK';

  @override
  String nicknameLine(String nickname) {
    return 'Přezdívka: $nickname';
  }

  @override
  String get inviteCodePrefix => 'Zvací kód: ';

  @override
  String exchangeRateLine(int coinsPerCzk) {
    return 'Směna: $coinsPerCzk Zl = 1 Kč';
  }

  @override
  String get mansionDeletedSnackbar => 'Sídlo bylo smazáno.';

  @override
  String get mansionWasDeleted => 'Sídlo bylo smazáno.';

  @override
  String shareInviteMessage(String name, String url, String code) {
    return 'Přidej se do mého Sídla „$name“ v GrimGrind! Otevři odkaz: $url (nebo zadej kód $code).';
  }

  @override
  String get manageAndInvitesTitle => 'Správa a Pozvánky';

  @override
  String get roleHandShort => 'RUKA';

  @override
  String get inviteFriendsSection => 'POZVÁNKA PRO PŘÁTELE (IM ODKAZ)';

  @override
  String get uniqueInviteCodeLabel => 'UNIKÁTNÍ ZVACÍ KÓD';

  @override
  String get inviteLinkCopiedSnackbar =>
      'Zvací odkaz zkopírován pro odeslání v chatu.';

  @override
  String get copyInviteLinkBtn => 'Zkopírovat zvací odkaz do zpráv';

  @override
  String newInviteCodeSnackbar(String code) {
    return 'Nový zvací kód: $code';
  }

  @override
  String get regenerateInviteCodeBtn => 'Obnovit zvací kód';

  @override
  String get dangerZoneEyebrow => 'NEBEZPEČNÁ ZÓNA';

  @override
  String get deleteMansionWarning =>
      'Smazáním Sídla trvale odstraníš celé panství, kroniku, karty v Mešci i všechny členy. Tato akce je nevratná.';

  @override
  String get finalDecisionEyebrow => 'KONEČNÉ ROZHODNUTÍ';

  @override
  String deleteMansionConfirmPrompt(String name) {
    return 'Tato akce trvale smaže „$name“ včetně všech karet a historie. Pro potvrzení napiš přesný název Sídla:';
  }

  @override
  String typeExactNameLabel(String name) {
    return 'Napiš: $name';
  }

  @override
  String get keepMansionBtn => 'Ponechat Sídlo';

  @override
  String get deleteForeverBtn => 'Trvale smazat';

  @override
  String get themeSectionTitle => 'TÉMA / MOTIV SÍDLA';

  @override
  String get handOnlyLabel => 'POUZE RUKA';

  @override
  String get readOnlyLabel => 'JEN ČTENÍ';

  @override
  String get themeOwnerHint =>
      'Vlastník může pro nové období zvolit balíček tématu. Výchozím tématem je Gothic Mansion.';

  @override
  String get themeMemberHint => 'Aktivní téma nastavené vlastníkem Sídla.';

  @override
  String get defaultShadowMansionName => 'Sídlo stínů';

  @override
  String get defaultMansionFallbackName => 'Sídlo';

  @override
  String get sampleQueenNickname => 'Královna sídla';

  @override
  String errorSignInFailed(String error) {
    return 'Přihlášení selhalo: $error';
  }

  @override
  String get errorInvalidEmailPassword =>
      'Zadej platný e-mail a heslo (min. 6 znaků).';

  @override
  String errorRegistrationFailed(String error) {
    return 'Registrace selhala: $error';
  }

  @override
  String get errorGoogleSignInCancelled =>
      'Přihlášení přes Google bylo zrušeno nebo selhalo.';

  @override
  String errorGoogleSignInFailed(String error) {
    return 'Přihlášení přes Google selhalo: $error';
  }

  @override
  String get errorAnonymousSignInFailed => 'Anonymní přihlášení se nezdařilo.';

  @override
  String errorAnonymousSignInException(String error) {
    return 'Anonymní přihlášení selhalo: $error';
  }

  @override
  String get errorSignInFirst => 'Nejprve se prosím přihlas.';

  @override
  String get errorAccountRequiredToCreate =>
      'Pro založení Sídla se musíš přihlásit účtem.';

  @override
  String get errorCreateMansionServer =>
      'Nepodařilo se založit Sídlo na serveru.';

  @override
  String errorCreateMansionException(String error) {
    return 'Chyba při zakládání Sídla: $error';
  }

  @override
  String get errorEnterInviteCode => 'Zadej zvací kód Sídla.';

  @override
  String get errorAccountRequiredToJoin =>
      'Pro vstup do Sídla se musíš přihlásit účtem.';

  @override
  String errorInviteNotFound(String code) {
    return 'Pozvánka s kódem $code nebyla nalezena.';
  }

  @override
  String errorLoadMansionFailed(String code) {
    return 'Sídlo pro kód $code se nepodařilo načíst.';
  }

  @override
  String errorJoinMansionException(String error) {
    return 'Chyba při připojování k Sídlu: $error';
  }
}
