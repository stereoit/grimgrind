# GrimGrind Theme Package Specification

This specification defines what constitutes a **Theme Package** in GrimGrind, how to author new themes in the future, and how the game separates **theme-independent mechanics** from **theme-dependent presentation**.

The first and automatic default theme is **`gothic_mansion`** (*Gothic Mansion*), implemented in [`lib/theme_package.dart`](../lib/theme_package.dart).

---

## 1. Core Principle: Mechanics vs. Theme

A theme **never** alters game balance or financial math.

| Theme-Independent (Core Mechanics) | Theme-Dependent (Theme Package) |
| :--- | :--- |
| 17 `ChoreDefinition.id` keys, `baseCoins`, `minutes`, `difficulty` tier | Card artwork (`<id>.png`), card suit symbols, optional card title/note overrides, difficulty labels & colors |
| `MonthlyLevel` thresholds (`0, 5, 12, 22, 35`) & bonus rates (`+0%` to `+50%`) | Level names (`Probuzený`…`Nesmrtelný`) and callouts (`First Blood`…`Godlike`) |
| `HeatLevel` day thresholds, cooldown rules, and bonus rates (`+0%` to `+30%`) | Heat tier names, rule summary copy, colors, icons, and leaderboard aura glow radius |
| `coinsPerCzk`, `Bank`, `ExchangeRequest`, `monthKey` | Currency name (`Coin` / `Coinů` / `C`), vault name (`Bank`), owner role name (`Ruka`), group noun (`Sídlo`) |
| `MemberSex` grammatical agreement | Onboarding slides, default names, invite code prefix, feed/proclamation copy |

---

## 2. Theme Package Contract (`GameThemePackage`)

Every theme is an instance of `GameThemePackage` registered in `ThemeRegistry.all` ([`lib/theme_package.dart`](../lib/theme_package.dart)).

### 2.1 Identity
* **`id`** (`String`, snake_case): Stable identifier stored on `Gang.themeId` (and in future per-month period configs). Example: `'gothic_mansion'`.
* **`displayName`** (`String`): Human-readable name shown in the Gang Management theme selector.
* **`subtitle`** (`String`): Short 1-line description of the aesthetic.
* **`fontFamily`** (`String`): Primary font family passed to `ThemeData` (e.g., `'serif'`, `'sans-serif'`).

### 2.2 Color Palette
Every theme must supply all 15 semantic color tokens plus tier maps:

| Token | Gothic Mansion | Usage |
| :--- | :--- | :--- |
| `voidBackground` | `#0B0B0D` | Scaffold & deepest background |
| `surface` | `#17171A` | Cards, panels, status strips |
| `elevatedSurface` | `#111114` | Modal bottom sheets & dialogs |
| `navBackground` | `#101012` | Bottom `NavigationBar` background |
| `navIndicator` | `#41212B` | Active nav destination pill |
| `primaryAccent` | `#C6A15B` | Rewards, coins, eyebrows, focus borders |
| `secondaryAccent` | `#6E1830` | Primary action buttons, FAB, snackbars |
| `secondaryBorder` | `#9B3B48` | Accent border on destructive/primary actions |
| `onSurface` | `#E9E0D0` | Primary body & headline text |
| `onAccentText` | `#F7EEE0` | Text on `secondaryAccent` surfaces |
| `mutedText` | `#968C80` | Secondary descriptions & timestamps |
| `subtleText` | `#776F66` | Strikethrough base coins, micro labels |
| `border` | `#3B3329` | Card & divider borders |
| `subtleBorder` | `#5A4931` | Subtle decorative frames |
| `coinBadgeFill` | `#282015` | Coin pill background in Feed |

Plus two 4-entry maps:
* **`difficultyColors`**: `Map<ChoreDifficulty, Color>` (`easy`, `medium`, `hard`, `special`).
* **`heatColors`**: `Map<HeatLevel, Color>` (`coldAsh`, `glowingEmbers`, `blazingForge`, `hellfire`).

### 2.3 Heat Icons & Aura Glow
* **`heatIcons`**: `Map<HeatLevel, IconData>` (4 tiers).
* **`heatGlowRadii`**: `Map<HeatLevel, double>` (e.g., `0.0`, `12.0`, `20.0`, `28.0` for leaderboard card aura).

### 2.4 Navigation & Role Iconography
* `ownerRoleIcon` / `ownerRoleOutlinedIcon` (Gothic: `Icons.front_hand` — *Ruka*)
* `feedIcon` / `feedOutlinedIcon`
* `deckIcon` / `deckOutlinedIcon`
* `bankIcon` / `bankOutlinedIcon`
* `leaderboardIcon` / `leaderboardOutlinedIcon`
* `currencyIcon` (Gothic: `Icons.toll`)

---

## 3. Required Visual Assets Checklist

When creating a new theme under `assets/themes/<theme_id>/` (or a dedicated directory referenced by `cardAssetDirectory`), provide the following PNG assets:

### 3.1 Narrative & Feature Art (4 files)
1. `onboardingDeckArt` — Onboarding slide 1 (the shared deck/catalog).
2. `onboardingWorldArt` — Onboarding slide 2 & Gang Setup hero banner.
3. `exchangeArt` — Onboarding slide 3 & approved exchange celebration card in Feed (16:9).
4. `monthTrophyArt` — End-of-month winner proclamation divider card in Feed (16:9).

### 3.2 Chore Card Illustrations (17 files, 4:5 vertical aspect ratio)
Each file must be named `<choreId>.png` inside `cardAssetDirectory`:
* **Easy (`5`)**: `trash.png`, `shopping.png`, `dishwasher.png`, `laundry.png`, `stairs.png`
* **Medium (`6`)**: `queenie.png`, `toilet.png`, `dogs.png`, `sport.png`, `garden.png`, `evening.png`
* **Hard (`5`)**: `bathroom.png`, `mop.png`, `ironing.png`, `cooking.png`, `school.png`
* **Special (`1`)**: `room.png`

> **Layout Tip** (from `DESIGN.md`): Keep the bottom ~22% of each card illustration dark/low-detail so in-app overlaid titles remain legible, and avoid baking text or logos into card artwork.

---

## 4. Terminology, Labels & Copy

A theme defines:
* **World & Roles**: `appWordmark`, `groupNoun` / `groupGenitive` (*Sídlo* / *Sídla*), `ownerRoleTitle` / `ownerRoleInstrumental` (*Ruka* / *Rukou*).
* **Economy & Tabs**: `currencySingular` / `currencyPlural` / `currencyShort`, `vaultName`, `deckName`, `feedName`, `leaderboardName`, `hallOfFameLabel`.
* **Defaults**: `defaultGangName`, `defaultFounderNickname`, `defaultMemberNickname`, `inviteCodePrefix`.
* **Tiers**:
  * `difficultyLabels` & `difficultySymbols` (`4` entries)
  * `monthlyLevelLabels` & `monthlyLevelCallouts` (`5` entries)
  * `heatLevelLabels` & `heatLevelRuleSummaries` (`4` entries)
* **Onboarding Carousel**: `onboardingSlides` (list of `ThemeOnboardingSlide` with `eyebrow`, `title`, `text`, `imageAsset`).
* **Optional Card Reskinning (`choreOverrides`)**: Map any `chore.id` to `ThemeChoreOverride(title, note, symbol)` to rename tasks for a theme (e.g., *Uvařit jídlo* → *Uvařit lektvar*) without changing `chore.id` or rewards.

---

## 5. Owner Selection & Monthly Period Roadmap

* **Automatic Default**: `Gang.themeId` defaults to `'gothic_mansion'` (`ThemeRegistry.defaultThemeId`). Unknown or missing `themeId` values automatically fall back to `ThemeRegistry.gothicMansion`.
* **Owner-Only Control**: Only the Gang owner (`isHand` / `isOwnerOf(gangId)`) can change the active theme via `MansionStore.updateGangTheme(gangId, themeId)`, `FirebaseGangRepository.updateGangTheme(...)`, and the **Téma / Motiv Gangu** card in `ManageGangPage`.
* **Next Iteration (Monthly Periods)**:
  1. Store a `periodThemes: Map<String, String>` (`monthKey -> themeId`) on `Gang` (or on each `FeedEntry`) so past months keep their original theme in the Feed archive.
  2. Store structured `FeedEntry` metadata rather than pre-rendered themed strings in `functions/index.js`, or look up the Gang's active `themeId` in Cloud Functions when composing push notifications.
