import 'package:flutter/material.dart';

import 'models.dart';

/// Immutable slide definition for the onboarding carousel.
class ThemeOnboardingSlide {
  const ThemeOnboardingSlide({
    required this.eyebrow,
    required this.title,
    required this.text,
    required this.imageAsset,
  });

  final String eyebrow;
  final String title;
  final String text;
  final String imageAsset;
}

/// Optional per-chore text & symbol overrides supplied by a theme package.
class ThemeChoreOverride {
  const ThemeChoreOverride({
    required this.title,
    this.note,
    this.symbol,
  });

  final String title;
  final String? note;
  final String? symbol;
}

/// Sound asset paths bundled with a [GameThemePackage].
class ThemeSoundPack {
  const ThemeSoundPack({
    required this.introMusic,
    required this.openDeck,
    required this.playCard,
    required this.convertCoins,
    required this.buttonTap,
  });

  /// Looping background music played during the onboarding intro.
  final String introMusic;

  /// Sound effect played when opening the chore deck.
  final String openDeck;

  /// Sound effect played when a card is played/completed.
  final String playCard;

  /// Sound effect played when coins are converted/exchanged.
  final String convertCoins;

  /// Subtle tactile sound effect played when touching buttons.
  final String buttonTap;

  List<String> get allAssets => [
    introMusic,
    openDeck,
    playCard,
    convertCoins,
    buttonTap,
  ];
}

/// Complete visual, asset, and terminology contract for a GrimGrind theme.
///
/// Game mechanics (`baseCoins`, `minutes`, `minCards`, `bonusRate`,
/// `heatPeakDays`, `coinsPerCzk`, `monthKey`) live outside the theme package so
/// themes can be swapped per monthly period without altering game balance.
class GameThemePackage {
  const GameThemePackage({
    required this.id,
    required this.displayName,
    required this.subtitle,
    required this.fontFamily,
    // Palette
    required this.voidBackground,
    required this.surface,
    required this.elevatedSurface,
    required this.navBackground,
    required this.navIndicator,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.secondaryBorder,
    required this.onSurface,
    required this.onAccentText,
    required this.mutedText,
    required this.subtleText,
    required this.border,
    required this.subtleBorder,
    required this.coinBadgeFill,
    required this.difficultyColors,
    required this.heatColors,
    required this.heatIcons,
    required this.heatGlowRadii,
    // Icons
    required this.ownerRoleIcon,
    required this.ownerRoleOutlinedIcon,
    required this.deckIcon,
    required this.deckOutlinedIcon,
    required this.bankIcon,
    required this.bankOutlinedIcon,
    required this.leaderboardIcon,
    required this.leaderboardOutlinedIcon,
    required this.chronicleIcon,
    required this.chronicleOutlinedIcon,
    required this.currencyIcon,
    // Assets
    required this.cardAssetDirectory,
    required this.onboardingDeckArt,
    required this.onboardingWorldArt,
    required this.exchangeArt,
    required this.monthTrophyArt,
    required this.soundPack,
    // Terminology & Copy
    required this.appWordmark,
    required this.groupNoun,
    required this.groupGenitive,
    required this.ownerRoleTitle,
    required this.ownerRoleInstrumental,
    required this.currencySingular,
    required this.currencyPlural,
    required this.currencyShort,
    required this.vaultName,
    required this.deckName,
    required this.chronicleName,
    required this.leaderboardName,
    required this.hallOfFameLabel,
    required this.defaultGangName,
    required this.defaultFounderNickname,
    required this.defaultMemberNickname,
    required this.inviteCodePrefix,
    required this.difficultyLabels,
    required this.difficultySymbols,
    required this.monthlyLevelLabels,
    required this.monthlyLevelCallouts,
    required this.heatLevelLabels,
    required this.heatLevelRuleSummaries,
    required this.onboardingSlides,
    this.choreOverrides = const {},
  });

  final String id;
  final String displayName;
  final String subtitle;
  final String fontFamily;

  // Palette
  final Color voidBackground;
  final Color surface;
  final Color elevatedSurface;
  final Color navBackground;
  final Color navIndicator;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color secondaryBorder;
  final Color onSurface;
  final Color onAccentText;
  final Color mutedText;
  final Color subtleText;
  final Color border;
  final Color subtleBorder;
  final Color coinBadgeFill;

  final Map<ChoreDifficulty, Color> difficultyColors;
  final Map<HeatLevel, Color> heatColors;
  final Map<HeatLevel, IconData> heatIcons;
  final Map<HeatLevel, double> heatGlowRadii;

  // Icons
  final IconData ownerRoleIcon;
  final IconData ownerRoleOutlinedIcon;
  final IconData deckIcon;
  final IconData deckOutlinedIcon;
  final IconData bankIcon;
  final IconData bankOutlinedIcon;
  final IconData leaderboardIcon;
  final IconData leaderboardOutlinedIcon;
  final IconData chronicleIcon;
  final IconData chronicleOutlinedIcon;
  final IconData currencyIcon;

  // Assets
  final String cardAssetDirectory;
  final String onboardingDeckArt;
  final String onboardingWorldArt;
  final String exchangeArt;
  final String monthTrophyArt;
  final ThemeSoundPack soundPack;

  // Terminology & Copy
  final String appWordmark;
  final String groupNoun;
  final String groupGenitive;
  final String ownerRoleTitle;
  final String ownerRoleInstrumental;
  final String currencySingular;
  final String currencyPlural;
  final String currencyShort;
  final String vaultName;
  final String deckName;
  final String chronicleName;
  final String leaderboardName;
  final String hallOfFameLabel;
  final String defaultGangName;
  final String defaultFounderNickname;
  final String defaultMemberNickname;
  final String inviteCodePrefix;

  final Map<ChoreDifficulty, String> difficultyLabels;
  final Map<ChoreDifficulty, String> difficultySymbols;
  final Map<MonthlyLevel, String> monthlyLevelLabels;
  final Map<MonthlyLevel, String> monthlyLevelCallouts;
  final Map<HeatLevel, String> heatLevelLabels;
  final Map<HeatLevel, String> heatLevelRuleSummaries;
  final List<ThemeOnboardingSlide> onboardingSlides;
  final Map<String, ThemeChoreOverride> choreOverrides;

  ThemeData buildThemeData() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: voidBackground,
    colorScheme: ColorScheme.dark(
      primary: primaryAccent,
      secondary: secondaryAccent,
      surface: surface,
      onSurface: onSurface,
    ),
    fontFamily: fontFamily,
    dividerColor: border,
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: border),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: navBackground,
      indicatorColor: navIndicator,
      labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 12)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: secondaryAccent,
      contentTextStyle: TextStyle(color: onAccentText),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return secondaryAccent;
          }
          return voidBackground;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return onAccentText;
          }
          return mutedText;
        }),
        iconColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return onAccentText;
          }
          return mutedText;
        }),
        side: WidgetStatePropertyAll(BorderSide(color: border)),
      ),
    ),
  );

  Color difficultyColor(ChoreDifficulty difficulty) =>
      difficultyColors[difficulty] ?? primaryAccent;

  String difficultyLabel(ChoreDifficulty difficulty) =>
      difficultyLabels[difficulty] ?? difficulty.label;

  String difficultySymbol(ChoreDifficulty difficulty) =>
      difficultySymbols[difficulty] ?? '•';

  Color heatColor(HeatLevel heat) => heatColors[heat] ?? mutedText;

  IconData heatIcon(HeatLevel heat) =>
      heatIcons[heat] ?? Icons.local_fire_department_outlined;

  double heatGlowRadius(HeatLevel heat) => heatGlowRadii[heat] ?? 0.0;

  String heatLabel(HeatLevel heat) => heatLevelLabels[heat] ?? heat.label;

  String heatRuleSummary(HeatLevel heat) =>
      heatLevelRuleSummaries[heat] ?? heat.ruleSummary;

  String monthlyLevelLabel(MonthlyLevel level) =>
      monthlyLevelLabels[level] ?? level.label;

  String monthlyLevelCallout(MonthlyLevel level) =>
      monthlyLevelCallouts[level] ?? level.utCallout;

  String cardAssetPath(String choreId) => '$cardAssetDirectory/$choreId.png';

  String choreTitle(ChoreDefinition chore) =>
      choreOverrides[chore.id]?.title ?? chore.title;

  String? choreNote(ChoreDefinition chore) =>
      choreOverrides[chore.id]?.note ?? chore.note;

  String choreSymbol(ChoreDefinition chore) =>
      choreOverrides[chore.id]?.symbol ?? chore.symbol;
}

/// Central registry of available theme packages.
class ThemeRegistry {
  ThemeRegistry._();

  static const String defaultThemeId = 'gothic_mansion';

  static const GameThemePackage gothicMansion = GameThemePackage(
    id: defaultThemeId,
    displayName: 'Gothic Mansion',
    subtitle: 'Temné viktoriánské sídlo, rytiny a Ruka',
    fontFamily: 'serif',
    voidBackground: Color(0xFF0B0B0D),
    surface: Color(0xFF17171A),
    elevatedSurface: Color(0xFF111114),
    navBackground: Color(0xFF101012),
    navIndicator: Color(0xFF41212B),
    primaryAccent: Color(0xFFC6A15B),
    secondaryAccent: Color(0xFF6E1830),
    secondaryBorder: Color(0xFF9B3B48),
    onSurface: Color(0xFFE9E0D0),
    onAccentText: Color(0xFFF7EEE0),
    mutedText: Color(0xFF968C80),
    subtleText: Color(0xFF776F66),
    border: Color(0xFF3B3329),
    subtleBorder: Color(0xFF5A4931),
    coinBadgeFill: Color(0xFF282015),
    difficultyColors: {
      ChoreDifficulty.easy: Color(0xFF66816A),
      ChoreDifficulty.medium: Color(0xFFC6A15B),
      ChoreDifficulty.hard: Color(0xFF9B3B48),
      ChoreDifficulty.special: Color(0xFF846BA3),
    },
    heatColors: {
      HeatLevel.coldAsh: Color(0xFF625B53),
      HeatLevel.glowingEmbers: Color(0xFFD97B29),
      HeatLevel.blazingForge: Color(0xFFE5A435),
      HeatLevel.hellfire: Color(0xFFE04826),
    },
    heatIcons: {
      HeatLevel.coldAsh: Icons.ac_unit_outlined,
      HeatLevel.glowingEmbers: Icons.local_fire_department_outlined,
      HeatLevel.blazingForge: Icons.local_fire_department,
      HeatLevel.hellfire: Icons.whatshot,
    },
    heatGlowRadii: {
      HeatLevel.coldAsh: 0.0,
      HeatLevel.glowingEmbers: 12.0,
      HeatLevel.blazingForge: 20.0,
      HeatLevel.hellfire: 28.0,
    },
    ownerRoleIcon: Icons.front_hand,
    ownerRoleOutlinedIcon: Icons.front_hand_outlined,
    deckIcon: Icons.menu_book,
    deckOutlinedIcon: Icons.menu_book_outlined,
    bankIcon: Icons.savings,
    bankOutlinedIcon: Icons.savings_outlined,
    leaderboardIcon: Icons.emoji_events,
    leaderboardOutlinedIcon: Icons.emoji_events_outlined,
    chronicleIcon: Icons.dynamic_feed,
    chronicleOutlinedIcon: Icons.dynamic_feed_outlined,
    currencyIcon: Icons.toll,
    cardAssetDirectory: 'assets/cards',
    onboardingDeckArt: 'assets/art/spellbook_deck.png',
    onboardingWorldArt: 'assets/art/mansion.png',
    exchangeArt: 'assets/art/the_hand_exchange.png',
    monthTrophyArt: 'assets/art/month_trophy.png',
    soundPack: ThemeSoundPack(
      introMusic: 'assets/sounds/gothic_mansion/intro_music.wav',
      openDeck: 'assets/sounds/gothic_mansion/open_deck.wav',
      playCard: 'assets/sounds/gothic_mansion/play_card.wav',
      convertCoins: 'assets/sounds/gothic_mansion/convert_coins.wav',
      buttonTap: 'assets/sounds/gothic_mansion/button_tap.wav',
    ),
    appWordmark: 'GRIMGRIND',
    groupNoun: 'Sídlo',
    groupGenitive: 'Sídla',
    ownerRoleTitle: 'Ruka',
    ownerRoleInstrumental: 'Rukou',
    currencySingular: 'Coin',
    currencyPlural: 'Coinů',
    currencyShort: 'C',
    vaultName: 'Bank',
    deckName: 'Deck',
    chronicleName: 'Chronicle',
    leaderboardName: 'Žebříček',
    hallOfFameLabel: 'Síň slávy',
    defaultGangName: 'Sídlo Addamsů',
    defaultFounderNickname: 'Dark Lord',
    defaultMemberNickname: 'Shadow',
    inviteCodePrefix: 'GRIM',
    difficultyLabels: {
      ChoreDifficulty.easy: 'Pohoda',
      ChoreDifficulty.medium: 'Horší',
      ChoreDifficulty.hard: 'Těžké',
      ChoreDifficulty.special: 'Speciální',
    },
    difficultySymbols: {
      ChoreDifficulty.easy: '♣',
      ChoreDifficulty.medium: '◆',
      ChoreDifficulty.hard: '♥',
      ChoreDifficulty.special: '★',
    },
    monthlyLevelLabels: {
      MonthlyLevel.awakened: 'Probuzený',
      MonthlyLevel.restlessSpirit: 'Nepokojný duch',
      MonthlyLevel.bloodthirsty: 'Krvežíznivý',
      MonthlyLevel.unstoppable: 'Nezastavitelný',
      MonthlyLevel.godlike: 'Nesmrtelný',
    },
    monthlyLevelCallouts: {
      MonthlyLevel.awakened: 'First Blood',
      MonthlyLevel.restlessSpirit: 'Killing Spree',
      MonthlyLevel.bloodthirsty: 'Rampage',
      MonthlyLevel.unstoppable: 'Unstoppable',
      MonthlyLevel.godlike: 'Godlike',
    },
    heatLevelLabels: {
      HeatLevel.coldAsh: 'Vychladlý popel',
      HeatLevel.glowingEmbers: 'Žhnoucí uhlíky',
      HeatLevel.blazingForge: 'Rozpálená výheň',
      HeatLevel.hellfire: 'Pekelný žár',
    },
    heatLevelRuleSummaries: {
      HeatLevel.coldAsh: 'Výchozí stav nebo pauza 4+ dny',
      HeatLevel.glowingEmbers: 'Min. 2 dny aktivity • udržení: 1× za 3 dny',
      HeatLevel.blazingForge: 'Min. 4 dny aktivity • udržení: 1× za 3 dny',
      HeatLevel.hellfire: 'Min. 7 dní aktivity • udržení: každý den',
    },
    onboardingSlides: [
      ThemeOnboardingSlide(
        eyebrow: 'PRAVIDLO I • KNIHA KARET',
        title: 'Sdílený Deck Sídla',
        text:
            'Celá domácnost vybírá ze stejné knihy 17 úkolů. Žádné zamykání ani čekání – jakmile úkol splníš, rovnou kartu zahraješ do společného Feedu.',
        imageAsset: 'assets/art/spellbook_deck.png',
      ),
      ThemeOnboardingSlide(
        eyebrow: 'PRAVIDLO II • COINY, LEVEL & HEAT',
        title: 'Žhavé Násobiče Odměn',
        text:
            'Během měsíce sbíráš karty a postupuješ od Probuzeného až k Nesmrtelnému. Pravidelným hraním navíc rozdmýcháš Heat, který chladne při lenošení.',
        imageAsset: 'assets/art/mansion.png',
      ),
      ThemeOnboardingSlide(
        eyebrow: 'PRAVIDLO III • RUKA & LEADERBOARD',
        title: 'Směň Bank a Ovládni Sídlo',
        text:
            'Coiny padají do tvého Banku. Kdykoliv požádej Ruku (Zakladatele) o směnu na skutečné peníze. Teprve schválené směny se počítají do Leaderboardu!',
        imageAsset: 'assets/art/the_hand_exchange.png',
      ),
    ],
  );

  static const List<GameThemePackage> all = [gothicMansion];

  static GameThemePackage? byId(String? themeId) {
    if (themeId == null) return null;
    for (final theme in all) {
      if (theme.id == themeId) return theme;
    }
    return null;
  }

  static bool contains(String? themeId) => byId(themeId) != null;

  /// Returns the matching theme package or falls back to [gothicMansion].
  static GameThemePackage resolve(String? themeId) =>
      byId(themeId) ?? gothicMansion;
}

/// Exposes the active [GameThemePackage] down the widget tree.
class ThemeScope extends InheritedWidget {
  const ThemeScope({
    super.key,
    required this.theme,
    required super.child,
  });

  final GameThemePackage theme;

  static GameThemePackage of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    return scope?.theme ?? ThemeRegistry.gothicMansion;
  }

  @override
  bool updateShouldNotify(ThemeScope oldWidget) => theme.id != oldWidget.theme.id;
}
