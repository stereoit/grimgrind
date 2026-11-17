import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'app_strings.dart';
import 'gangs_screens.dart';
import 'mansion_store.dart';
import 'models.dart';
import 'sound_service.dart';
import 'theme_package.dart';
import 'update_checker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {
    // Gracefully continue in local/demo mode if Firebase is unavailable.
  }
  runApp(const GrimGrindApp());
}

class GrimGrindApp extends StatefulWidget {
  const GrimGrindApp({super.key, this.store, this.updateService});

  final MansionStore? store;
  final DistributionUpdateService? updateService;

  @override
  State<GrimGrindApp> createState() => _GrimGrindAppState();
}

class _GrimGrindAppState extends State<GrimGrindApp> {
  late final MansionStore store = widget.store ?? MansionStore();

  @override
  void initState() {
    super.initState();
    if (widget.store == null) {
      store.syncFromFirebase();
    }
  }

  @override
  void dispose() {
    if (widget.store == null) store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final activeTheme = store.activeTheme;
        SoundService.instance.updateTheme(activeTheme);
        return ThemeScope(
          theme: activeTheme,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'GrimGrind',
            theme: activeTheme.buildThemeData(),
            supportedLocales: AppStrings.supportedLocales,
            localeResolutionCallback: AppStrings.resolveLocale,
            localizationsDelegates: const [
              AppStrings.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: !store.isReady
                ? OnboardingFlow(store: store)
                : MansionShell(
                    store: store,
                    updateService: widget.updateService,
                  ),
          ),
        );
      },
    );
  }
}

Color _difficultyColor(BuildContext context, ChoreDifficulty difficulty) =>
    ThemeScope.of(context).difficultyColor(difficulty);

Color _heatColor(BuildContext context, HeatLevel heat) =>
    ThemeScope.of(context).heatColor(heat);

IconData _heatIcon(BuildContext context, HeatLevel heat) =>
    ThemeScope.of(context).heatIcon(heat);

// =============================================================================
// Onboarding: 3 Intro Cards + Create / Join Gang
// =============================================================================

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.store});

  final MansionStore store;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _introIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_syncIntroMusic);
    _syncIntroMusic();
  }

  @override
  void didUpdateWidget(covariant OnboardingFlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store != widget.store) {
      oldWidget.store.removeListener(_syncIntroMusic);
      widget.store.addListener(_syncIntroMusic);
    }
    _syncIntroMusic();
  }

  void _syncIntroMusic() {
    if (!widget.store.hasSeenIntro) {
      SoundService.instance.startIntroMusic();
    } else {
      SoundService.instance.stopIntroMusic();
    }
  }

  @override
  void dispose() {
    widget.store.removeListener(_syncIntroMusic);
    SoundService.instance.stopIntroMusic();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.store.hasSeenIntro) {
      return _buildIntroPages(context);
    }
    if (!widget.store.isSignedIn) {
      return _AuthGateScreen(store: widget.store);
    }
    if (widget.store.pendingVerificationEmail != null) {
      return _EmailVerificationNoticeScreen(store: widget.store);
    }
    if (!widget.store.hasAvatar) {
      return _CreateAvatarScreen(store: widget.store);
    }
    return _GangSetupScreen(store: widget.store);
  }

  Widget _buildIntroPages(BuildContext context) {
    final theme = ThemeScope.of(context);
    final s = AppStrings.of(context);
    final slides = s.onboardingSlidesFor(theme);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    theme.appWordmark,
                    style: TextStyle(
                      letterSpacing: 3,
                      fontSize: 16,
                      color: theme.primaryAccent,
                    ),
                  ),
                  TextButton(
                    onPressed: withButtonSound(widget.store.completeIntro),
                    child: Text(s.skip),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (value) => setState(() => _introIndex = value),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.subtleBorder,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                slide.imageAsset,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          slide.eyebrow,
                          style: const TextStyle(
                            color: Color(0xFFC6A15B),
                            letterSpacing: 2,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF968C80),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (i) => Container(
                        width: i == _introIndex ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: i == _introIndex
                              ? const Color(0xFFC6A15B)
                              : const Color(0xFF3B3329),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: withButtonSound(() {
                        if (_introIndex < slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOut,
                          );
                        } else {
                          widget.store.completeIntro();
                        }
                      }),
                      child: Text(
                        _introIndex < slides.length - 1
                            ? s.nextRuleCard
                            : s.enterMansion,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthGateScreen extends StatefulWidget {
  const _AuthGateScreen({required this.store});

  final MansionStore store;

  @override
  State<_AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<_AuthGateScreen> {
  static const Color _voidBg = Color(0xFF0B0B0D);
  static const Color _coalSurface = Color(0xFF17171A);
  static const Color _gothBorder = Color(0xFF3B3329);
  static const Color _boneText = Color(0xFFE9E0D0);
  static const Color _mutedStone = Color(0xFFA79C8C);
  static const Color _goldAccent = Color(0xFFC6A15B);
  static const Color _bloodWine = Color(0xFF6E1830);
  static const Color _bloodBorder = Color(0xFF9B3B48);

  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorText;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitCredentials() async {
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    final ok = _isRegisterMode
        ? await widget.store.registerWithEmailAsync(
            email: _emailController.text,
            password: _passwordController.text,
          )
        : await widget.store.signInWithEmailAsync(
            email: _emailController.text,
            password: _passwordController.text,
          );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _isSubmitting = false;
        _errorText = widget.store.lastSyncError ?? 'Ověření se nezdařilo.';
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    final ok = await widget.store.signInWithGoogleAsync();
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _isSubmitting = false;
        _errorText =
            widget.store.lastSyncError ?? 'Přihlášení přes Google selhalo.';
      });
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    final ok = await widget.store.continueAnonymouslyAsync();
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _isSubmitting = false;
        _errorText =
            widget.store.lastSyncError ?? 'Anonymní vstup se nezdařil.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: _voidBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _coalSurface,
                        border: Border.all(
                          color: _goldAccent.withValues(alpha: 0.7),
                          width: 1.4,
                        ),
                      ),
                      child: const Icon(
                        Icons.vpn_key_outlined,
                        color: _goldAccent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      s.authEyebrow,
                      style: const TextStyle(
                        color: _goldAccent,
                        fontSize: 11,
                        letterSpacing: 2.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'GrimGrind',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: _boneText,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Přihlas se do svého rodu nebo založ nový účet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _mutedStone, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _coalSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _gothBorder, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Přihlásit se'),
                            icon: Icon(Icons.login, size: 16),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Registrace'),
                            icon: Icon(Icons.person_add_alt_1, size: 16),
                          ),
                        ],
                        selected: {_isRegisterMode},
                        onSelectionChanged: _isSubmitting
                            ? null
                            : (s) => setState(() {
                                _isRegisterMode = s.first;
                                _errorText = null;
                              }),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: _voidBg,
                          labelText: 'E-mail',
                          prefixIcon: Icon(
                            Icons.alternate_email,
                            color: _mutedStone,
                            size: 18,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _voidBg,
                          labelText: 'Heslo',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: _mutedStone,
                            size: 18,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: _mutedStone,
                              size: 18,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      if (_errorText != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _bloodWine.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _bloodBorder),
                          ),
                          child: Text(
                            _errorText!,
                            style: const TextStyle(
                              color: _bloodBorder,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _bloodWine,
                          foregroundColor: _boneText,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: _bloodBorder),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : withButtonSound(_submitCredentials),
                        icon: const Icon(Icons.key_outlined, size: 18),
                        label: Text(
                          _isSubmitting
                              ? s.authVerifyingSeal
                              : (_isRegisterMode
                                    ? s.authCreateAccountBtn
                                    : s.authSignInBtn),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: _gothBorder)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              s.authOr,
                              style: const TextStyle(
                                color: _mutedStone,
                                fontSize: 11,
                                letterSpacing: 1.6,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: _gothBorder)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _voidBg,
                          foregroundColor: _boneText,
                          side: const BorderSide(color: _goldAccent),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : withButtonSound(_signInWithGoogle),
                        icon: const Icon(
                          Icons.g_mobiledata,
                          color: _goldAccent,
                          size: 24,
                        ),
                        label: Text(s.authContinueGoogle),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _voidBg,
                          foregroundColor: _boneText,
                          side: const BorderSide(color: _gothBorder),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : withButtonSound(_continueAsGuest),
                        icon: const Icon(
                          Icons.person_outline,
                          color: _goldAccent,
                          size: 18,
                        ),
                        label: Text(s.authContinueGuest),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '„Kdo překročí práh bez pečetě, stane se pouhým stínem v kronice.“',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _mutedStone,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailVerificationNoticeScreen extends StatelessWidget {
  const _EmailVerificationNoticeScreen({required this.store});

  final MansionStore store;

  static const Color _voidBg = Color(0xFF0B0B0D);
  static const Color _coalSurface = Color(0xFF17171A);
  static const Color _boneText = Color(0xFFE9E0D0);
  static const Color _mutedStone = Color(0xFFA79C8C);
  static const Color _goldAccent = Color(0xFFC6A15B);
  static const Color _bloodWine = Color(0xFF6E1830);
  static const Color _bloodBorder = Color(0xFF9B3B48);

  @override
  Widget build(BuildContext context) {
    final email = store.pendingVerificationEmail ?? '';
    return Scaffold(
      backgroundColor: _voidBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: _coalSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _goldAccent.withValues(alpha: 0.7)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    color: _goldAccent,
                    size: 44,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'PEČEŤ ODESLÁNA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _goldAccent,
                      fontSize: 11,
                      letterSpacing: 2.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Zkontroluj svůj e-mail',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _boneText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Na adresu $email jsme odeslali ověřovací odkaz. Potvrď ho ve své schránce, a mezitím můžeš pokračovat do Sídla.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _mutedStone, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _bloodWine,
                      foregroundColor: _boneText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: _bloodBorder),
                      ),
                    ),
                    onPressed: withButtonSound(
                      store.acknowledgeVerificationEmail,
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Pokračovat k tvorbě avatara'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateAvatarScreen extends StatefulWidget {
  const _CreateAvatarScreen({required this.store});

  final MansionStore store;

  @override
  State<_CreateAvatarScreen> createState() => _CreateAvatarScreenState();
}

class _CreateAvatarScreenState extends State<_CreateAvatarScreen> {
  static const Color _voidBg = Color(0xFF0B0B0D);
  static const Color _coalSurface = Color(0xFF17171A);
  static const Color _gothBorder = Color(0xFF3B3329);
  static const Color _boneText = Color(0xFFE9E0D0);
  static const Color _mutedStone = Color(0xFFA79C8C);
  static const Color _goldAccent = Color(0xFFC6A15B);
  static const Color _bloodWine = Color(0xFF6E1830);
  static const Color _bloodBorder = Color(0xFF9B3B48);

  late final TextEditingController _nicknameController = TextEditingController(
    text: widget.store.avatarNickname ?? 'Dark Lord',
  );
  late MemberSex _selectedSex = widget.store.avatarSex;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: _voidBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _coalSurface,
                        border: Border.all(
                          color: _goldAccent.withValues(alpha: 0.7),
                          width: 1.4,
                        ),
                      ),
                      child: const Icon(
                        Icons.badge_outlined,
                        color: _goldAccent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      s.createAvatarEyebrow,
                      style: const TextStyle(
                        color: _goldAccent,
                        fontSize: 11,
                        letterSpacing: 2.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tvůj Temný Avatar',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: _boneText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Zvol si přezdívku a rodovou podobu pro kroniku Sídla.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _mutedStone, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _coalSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _gothBorder, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: _voidBg,
                          labelText: 'Tvoje temná přezdívka',
                          hintText: 'Např. Shadow Master',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: _mutedStone,
                            size: 18,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      MemberSexSelector(
                        selected: _selectedSex,
                        onChanged: (sex) => setState(() => _selectedSex = sex),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _bloodWine,
                          foregroundColor: _boneText,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: _bloodBorder),
                          ),
                        ),
                        onPressed: withButtonSound(() {
                          widget.store.saveAvatar(
                            nickname: _nicknameController.text,
                            sex: _selectedSex,
                          );
                        }),
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: Text(s.continueToMansion),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GangSetupScreen extends StatefulWidget {
  const _GangSetupScreen({required this.store});

  final MansionStore store;

  @override
  State<_GangSetupScreen> createState() => _GangSetupScreenState();
}

class _GangSetupScreenState extends State<_GangSetupScreen> {
  bool _createMode = true;
  bool _includeStarterFamily = true;
  bool _isSubmitting = false;
  late MemberSex _selectedSex = widget.store.avatarSex;
  final _gangNameController = TextEditingController(text: 'Sídlo Addamsů');
  late final _nicknameController = TextEditingController(
    text: widget.store.avatarNickname ?? 'Dark Lord',
  );
  late final TextEditingController _inviteCodeController =
      TextEditingController(
        text: widget.store.pendingInviteCode ?? 'GRIM-42',
      );

  @override
  void initState() {
    super.initState();
    if (widget.store.pendingInviteCode != null) {
      _createMode = false;
    }
  }

  @override
  void dispose() {
    _gangNameController.dispose();
    _nicknameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                ThemeScope.of(context).onboardingWorldArt,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ZALOŽENÍ NEBO PŘIPOJENÍ',
              style: TextStyle(
                color: Color(0xFFC6A15B),
                letterSpacing: 2,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            Text(s.gangSetupTitle, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            const Text(
              'Zakládající člen získá roli Ruky (nastavuje kurz Coin → Kč a schvaluje směny) a pozve ostatní přes zvací kód.',
              style: TextStyle(color: Color(0xFF968C80), height: 1.4),
            ),
            const SizedBox(height: 20),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.castle_outlined),
                  label: Text(s.createMansionBtn),
                ),
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.vpn_key_outlined),
                  label: Text(s.joinMansionBtn),
                ),
              ],
              selected: {_createMode},
              onSelectionChanged: (sel) =>
                  setState(() => _createMode = sel.first),
            ),
            const SizedBox(height: 20),
            if (_createMode) ...[
              TextField(
                controller: _gangNameController,
                decoration: InputDecoration(
                  labelText: s.isCs ? 'Název Sídla' : 'Mansion Name',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Tvoje přezdívka (Zakladatel = Ruka)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              MemberSexSelector(
                selected: _selectedSex,
                onChanged: (sex) => setState(() => _selectedSex = sex),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _includeStarterFamily,
                onChanged: (v) => setState(() => _includeStarterFamily = v),
                title: const Text('Přidat ukázkové členy & historii'),
                subtitle: const Text(
                  'Ideální pro okamžité vyzkoušení Leaderboardu a schvalování směn',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : withButtonSound(() async {
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _isSubmitting = true);
                        final ok = await widget.store.createGangAsync(
                          gangName: _gangNameController.text,
                          founderNickname: _nicknameController.text,
                          founderSex: _selectedSex,
                          includeStarterFamily: _includeStarterFamily,
                        );
                        if (!mounted) return;
                        setState(() => _isSubmitting = false);
                        if (!ok) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.store.lastSyncError ??
                                    (s.isCs
                                        ? 'Nepodařilo se založit Sídlo.'
                                        : 'Failed to create Mansion.'),
                              ),
                            ),
                          );
                        }
                      }),
                icon: const Icon(Icons.castle_outlined),
                label: Text(
                  _isSubmitting ? s.gangSetupCreating : s.gangSetupCreateBtn,
                ),
              ),
            ] else ...[
              TextField(
                controller: _inviteCodeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: s.isCs ? 'Zvací kód Sídla' : 'Mansion Invite Code',
                  hintText: s.isCs ? 'Např. GRIM-42' : 'e.g. GRIM-42',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Tvoje temná přezdívka',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              MemberSexSelector(
                selected: _selectedSex,
                onChanged: (sex) => setState(() => _selectedSex = sex),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : withButtonSound(() async {
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _isSubmitting = true);
                        final ok = await widget.store.joinGangByCodeAsync(
                          inviteCode: _inviteCodeController.text,
                          nickname: _nicknameController.text,
                          sex: _selectedSex,
                        );
                        if (!mounted) return;
                        setState(() => _isSubmitting = false);
                        if (!ok) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.store.lastSyncError ??
                                    (s.isCs
                                        ? 'Neplatný zvací kód Sídla.'
                                        : 'Invalid Mansion invite code.'),
                              ),
                            ),
                          );
                        }
                      }),
                icon: const Icon(Icons.login),
                label: Text(
                  _isSubmitting ? s.gangSetupJoining : s.gangSetupJoinBtn,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: withButtonSound(widget.store.startSampleMansion),
              child: Text(s.gangSetupQuickStart),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Main Shell
// =============================================================================

class MansionShell extends StatefulWidget {
  const MansionShell({super.key, required this.store, this.updateService});

  final MansionStore store;
  final DistributionUpdateService? updateService;

  @override
  State<MansionShell> createState() => _MansionShellState();
}

class _MansionShellState extends State<MansionShell> {
  int index = 0;
  late final DistributionUpdateService _updateService =
      widget.updateService ?? DistributionUpdateService();
  UpdateCheckResult? _pendingUpdate;
  bool _updateDismissed = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingInvite());
  }

  Future<void> _checkPendingInvite() async {
    final code = widget.store.pendingInviteCode;
    if (!mounted || code == null) return;
    widget.store.clearPendingInviteCode();
    await showAcceptInviteDialog(context, widget.store, initialCodeOrLink: code);
  }

  Future<void> _checkForUpdates() async {
    final result = await _updateService.checkForUpdate();
    if (!mounted || result == null || !result.isUpdateAvailable) return;
    setState(() {
      _pendingUpdate = result;
      _updateDismissed = false;
    });
  }

  void _openDeck() {
    SoundService.instance.playOpenDeck();
    final s = AppStrings.of(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(s.deckTitle)),
          body: SafeArea(child: DeckPage(store: widget.store)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final theme = ThemeScope.of(context);
    final s = AppStrings.of(context);
    final member = store.currentMember!;
    final level = store.monthlyLevelFor(member.id);
    final heat = store.heatLevelFor(member);
    final pendingCount = store.isCurrentUserHand
        ? store.pendingExchanges.length
        : 0;

    final pages = [
      FeedPage(
        store: store,
        onOpenDeck: _openDeck,
      ),
      BankPage(store: store),
      LeaderboardPage(store: store),
      ProfileSettingsPage(
        store: store,
        updateService: _updateService,
        pendingUpdate: _pendingUpdate,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              store.gang!.name.toUpperCase(),
              style: const TextStyle(letterSpacing: 2.2, fontSize: 16),
            ),
            Text(
              '${member.nickname} • ${s.monthlyLevelLabel(level, theme)} • ${s.heatLabel(heat, theme)}',
              style: const TextStyle(
                color: Color(0xFF968C80),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_pendingUpdate != null && !_updateDismissed)
              UpdateBanner(
                result: _pendingUpdate!,
                onUpdate: () =>
                    _updateService.openUpdateUrl(_pendingUpdate!.info),
                onDismiss: () => setState(() => _updateDismissed = true),
              ),
            Expanded(
              child: IndexedStack(index: index, children: pages),
            ),
          ],
        ),
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF6E1830),
              foregroundColor: const Color(0xFFF7EEE0),
              onPressed: _openDeck,
              icon: const Icon(Icons.auto_stories),
              label: Text(s.playCardFab),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: withButtonSound1(
          (value) => setState(() => index = value),
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dynamic_feed_outlined),
            selectedIcon: const Icon(Icons.dynamic_feed),
            label: s.navChronicle,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.savings_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.savings),
            ),
            label: s.navPouch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events),
            label: s.navLeaderboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.castle_outlined),
            selectedIcon: const Icon(Icons.castle),
            label: s.navMansion,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 1. Main Feed (Instagram-style stream with Month Proclamation Dividers)
// =============================================================================

class FeedPage extends StatelessWidget {
  const FeedPage({
    super.key,
    required this.store,
    required this.onOpenDeck,
  });

  final MansionStore store;
  final VoidCallback onOpenDeck;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final entries = store.feedEntries;

    return CustomScrollView(
      key: const PageStorageKey('feed'),
      slivers: [
        if (entries.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.dynamic_feed_outlined,
              imageAsset: 'assets/branding/chronicle_empty.png',
              title: s.feedEmptyTitle,
              text: s.feedEmptyText,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            sliver: SliverList.separated(
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final entry = entries[i];
                return switch (entry.type) {
                  FeedEntryType.cardPlayed => _FeedPlayedCardPost(entry: entry),
                  FeedEntryType.exchangeApproved => _FeedExchangePost(
                    entry: entry,
                  ),
                  FeedEntryType.monthProclamation => _FeedMonthDividerCard(
                    entry: entry,
                  ),
                };
              },
            ),
          ),
      ],
    );
  }
}

class _CoinAmount extends StatelessWidget {
  const _CoinAmount({
    required this.amount,
    this.prefix = '',
    this.fontSize = 14,
    this.iconSize = 16,
    this.color = const Color(0xFFC6A15B),
    this.fontWeight = FontWeight.bold,
  });

  final int amount;
  final String prefix;
  final double fontSize;
  final double iconSize;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '$prefix$amount',
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      const SizedBox(width: 4),
      ClipOval(
        child: Image.asset(
          'assets/branding/gold_coin.png',
          width: iconSize,
          height: iconSize,
          fit: BoxFit.cover,
        ),
      ),
    ],
  );
}

class _FeedPlayedCardPost extends StatelessWidget {
  const _FeedPlayedCardPost({required this.entry});

  final FeedEntry entry;

  @override
  Widget build(BuildContext context) {
    final heat = entry.heatAtEvent ?? HeatLevel.coldAsh;
    final level = entry.levelAtEvent ?? MonthlyLevel.awakened;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: _heatColor(context, heat).withValues(alpha: 0.2),
                  child: Icon(
                    _heatIcon(context, heat),
                    size: 18,
                    color: _heatColor(context, heat),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.actorNickname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE9E0D0),
                        ),
                      ),
                      Text(
                        '${level.label} • ${DateFormat('d. M. • HH:mm').format(entry.createdAt)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF968C80),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF282015),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC6A15B)),
                  ),
                  child: _CoinAmount(
                    amount: entry.coins ?? 0,
                    prefix: '+',
                    fontSize: 12,
                    iconSize: 15,
                  ),
                ),
              ],
            ),
          ),
          if (entry.choreId != null)
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    ThemeScope.of(context).cardAssetPath(entry.choreId!),
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 24, 14, 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xE60B0B0D)],
                        ),
                      ),
                      child: Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFFE9E0D0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Text(
              '${entry.actorNickname} ${entry.message}',
              style: const TextStyle(color: Color(0xFFD5CCB8), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedExchangePost extends StatelessWidget {
  const _FeedExchangePost({required this.entry});

  final FeedEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFC6A15B), width: 1.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  ThemeScope.of(context).exchangeArt,
                  fit: BoxFit.cover,
                ),
                Container(
                  color: const Color(0x880B0B0D),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SCHVÁLENÁ SMĚNA RUKOU',
                        style: TextStyle(
                          color: Color(0xFFC6A15B),
                          letterSpacing: 2,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _CoinAmount(
                        amount: entry.coins ?? 0,
                        fontSize: 24,
                        iconSize: 24,
                        color: const Color(0xFFE9E0D0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.message,
                  style: const TextStyle(height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  'Započteno do měsíčního Leaderboardu • ${DateFormat('d. M. • HH:mm').format(entry.createdAt)}',
                  style: const TextStyle(
                    color: Color(0xFF968C80),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedMonthDividerCard extends StatelessWidget {
  const _FeedMonthDividerCard({required this.entry});

  final FeedEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFC6A15B))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'UZÁVĚRKA OBDOBÍ • ${entry.monthKey}',
                style: const TextStyle(
                  color: Color(0xFFC6A15B),
                  letterSpacing: 2,
                  fontSize: 10,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFC6A15B))),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFC6A15B), width: 1.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      ThemeScope.of(context).monthTrophyArt,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xE60B0B0D)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 12,
                      child: Text(
                        entry.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFFC6A15B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  entry.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 2. Deck View (Shared Spellbook of 17 Cards with Live Coin Values)
// =============================================================================

class DeckPage extends StatefulWidget {
  const DeckPage({super.key, required this.store});

  final MansionStore store;

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  ChoreDifficulty? _filter;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final theme = ThemeScope.of(context);
    final s = AppStrings.of(context);
    final member = store.currentMember!;
    final level = store.monthlyLevelFor(member.id);
    final heat = store.heatLevelFor(member);
    final totalBonus = level.bonusPercent + heat.bonusPercent;

    final cards = _filter == null
        ? store.deck
        : store.deck.where((c) => c.difficulty == _filter).toList();

    return CustomScrollView(
      key: const PageStorageKey('deck'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.deckEyebrow,
                  style: const TextStyle(
                    color: Color(0xFFC6A15B),
                    letterSpacing: 2,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.deckHeading,
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  s.deckBonusSummary(
                    s.monthlyLevelLabel(level, theme),
                    level.bonusPercent,
                    s.heatLabel(heat, theme),
                    heat.bonusPercent,
                    totalBonus,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF968C80),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text(s.deckAllFilter(store.deck.length)),
                        selected: _filter == null,
                        onSelected: withButtonSound1(
                          (_) => setState(() => _filter = null),
                        ),
                      ),
                      const SizedBox(width: 8),
                      for (final diff in ChoreDifficulty.values) ...[
                        FilterChip(
                          label: Text(s.difficultyLabel(diff, theme)),
                          selected: _filter == diff,
                          onSelected: withButtonSound1(
                            (_) => setState(() => _filter = diff),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisExtent: 298,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: cards.length,
            itemBuilder: (context, i) {
              final chore = cards[i];
              final coins = store.effectiveCoinsFor(chore, member);
              return _DeckCardTile(
                chore: chore,
                effectiveCoins: coins,
                onTap: withButtonSound(
                  () => _confirmPlayCard(context, store, chore, coins),
                )!,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DeckCardTile extends StatelessWidget {
  const _DeckCardTile({
    required this.chore,
    required this.effectiveCoins,
    required this.onTap,
  });

  final ChoreDefinition chore;
  final int effectiveCoins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);
    final accent = _difficultyColor(context, chore.difficulty);
    final boosted = effectiveCoins > chore.baseCoins;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: accent, width: 3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      theme.choreSymbol(chore),
                      style: TextStyle(fontSize: 22, color: accent),
                    ),
                    Text(
                      AppStrings.of(context)
                          .difficultyLabel(chore.difficulty, theme)
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      theme.cardAssetPath(chore.id),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  chore.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 17, height: 1.15),
                ),
                const SizedBox(height: 6),
                Text(
                  '${chore.minutes} min',
                  style: const TextStyle(
                    color: Color(0xFF968C80),
                    fontSize: 11,
                  ),
                ),
                const Divider(height: 16),
                Row(
                  children: [
                    _CoinAmount(
                      amount: effectiveCoins,
                      fontSize: 17,
                      iconSize: 18,
                    ),
                    if (boosted) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${chore.baseCoins}',
                        style: const TextStyle(
                          color: Color(0xFF776F66),
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const Spacer(),
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFFE9E0D0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _confirmPlayCard(
  BuildContext context,
  MansionStore store,
  ChoreDefinition chore,
  int effectiveCoins,
) async {
  final s = AppStrings.of(context);
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF111114),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                ThemeScope.of(context).cardAssetPath(chore.id),
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              chore.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26),
            ),
            if (chore.note != null) ...[
              const SizedBox(height: 8),
              Text(
                chore.note!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF968C80)),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.schedule,
                    value: '${chore.minutes} min',
                    label: s.estimateLabel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Icons.toll,
                    value: '$effectiveCoins',
                    valueWidget: _CoinAmount(
                      amount: effectiveCoins,
                      fontSize: 16,
                      iconSize: 16,
                      color: const Color(0xFFE9E0D0),
                    ),
                    label: s.pouchRewardLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.bolt),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s.playCardPrefix),
                    _CoinAmount(
                      amount: effectiveCoins,
                      fontSize: 14,
                      iconSize: 15,
                      color: const Color(0xFFE9E0D0),
                    ),
                    const Text(')'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  if (confirmed == true && context.mounted) {
    final played = store.playCard(chore);
    if (played != null) {
      SoundService.instance.playCard();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.cardPlayedSnackbar(played.coinsAwarded)),
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}

// =============================================================================
// 3. Bank & Hand Exchange Approval View
// =============================================================================

class BankPage extends StatelessWidget {
  const BankPage({super.key, required this.store});

  final MansionStore store;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final member = store.currentMember!;
    final bankCards = store.bankCardsFor(member.id);
    final pendingMine = store.pendingCardsFor(member.id);
    final bankCoins = store.bankCoinsFor(member.id);

    return ListView(
      key: const PageStorageKey('bank'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(
          s.pouchEyebrow,
          style: const TextStyle(
            color: Color(0xFFC6A15B),
            letterSpacing: 2,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(s.pouchHeading, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF17171A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFC6A15B)),
          ),
          child: Column(
            children: [
              _CoinAmount(
                amount: bankCoins,
                fontSize: 38,
                iconSize: 34,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: bankCards.isEmpty
                      ? null
                      : () {
                          final req = store.requestExchange();
                          if (req != null) {
                            SoundService.instance.playConvertCoins();
                          }
                          if (req != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  s.exchangeRequestedSnackbar(req.totalCoins),
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.front_hand_outlined),
                  label: Text(
                    bankCards.isEmpty
                        ? s.pouchEmpty
                        : s.requestExchangeBtn(bankCards.length),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (bankCards.isNotEmpty) ...[
          _SectionTitle(s.playedCardsInPouchSection),
          ...bankCards.map(
            (card) => Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    ThemeScope.of(context).cardAssetPath(card.chore.id),
                    width: 40,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(card.chore.title),
                subtitle: Text(
                  DateFormat('d. M. • HH:mm').format(card.playedAt),
                ),
                trailing: _CoinAmount(
                  amount: card.coinsAwarded,
                  prefix: '+',
                  fontSize: 14,
                  iconSize: 16,
                ),
              ),
            ),
          ),
        ],
        if (pendingMine.isNotEmpty) ...[
          _SectionTitle(s.pendingCardsSection),
          ...pendingMine.map(
            (card) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.hourglass_top,
                  color: Color(0xFFC6A15B),
                ),
                title: Text(card.chore.title),
                trailing: _CoinAmount(
                  amount: card.coinsAwarded,
                  fontSize: 13,
                  iconSize: 15,
                ),
              ),
            ),
          ),
        ],
        if (store.isCurrentUserHand) ...[
          const Divider(height: 36),
          _SectionTitle(s.handManagementSection),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final created = store.closeMonth();
                    if (created > 0) {
                      SoundService.instance.playConvertCoins();
                    } else {
                      SoundService.instance.playButtonTap();
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(s.monthClosedSnackbar(created)),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.event_available),
                  label: Text(s.closeMonthBtn),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (store.pendingExchanges.isEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(s.noPendingExchanges),
              ),
            )
          else
            ...store.pendingExchanges.map(
              (req) => _PendingExchangeCard(store: store, req: req),
            ),
        ],
      ],
    );
  }
}

class _PendingExchangeCard extends StatelessWidget {
  const _PendingExchangeCard({required this.store, required this.req});

  final MansionStore store;
  final ExchangeRequest req;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cards = store.playedCards
        .where((c) => req.cardIds.contains(c.id))
        .toList();
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFC6A15B)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    req.memberNickname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _CoinAmount(
                  amount: req.totalCoins,
                  fontSize: 16,
                  iconSize: 17,
                ),
              ],
            ),
            if (req.isAutoMonthEnd)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  s.autoMonthEndLabel,
                  style: const TextStyle(color: Color(0xFF968C80), fontSize: 11),
                ),
              ),
            const Divider(),
            ...cards.map(
              (c) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(c.chore.title),
                subtitle: _CoinAmount(
                  amount: c.coinsAwarded,
                  fontSize: 12,
                  iconSize: 13,
                  color: const Color(0xFF968C80),
                  fontWeight: FontWeight.normal,
                ),
                trailing: IconButton(
                  tooltip: s.rejectCardTooltip,
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: withButtonSound(
                    () => store.rejectCardInRequest(req.id, c.id),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  SoundService.instance.playConvertCoins();
                  store.approveExchange(req.id);
                },
                icon: const Icon(Icons.verified_outlined),
                label: Text(s.approveExchangeBtn(req.totalCoins)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 4. Leaderboard (Collectible Player Cards with Heat Aura)
// =============================================================================

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key, required this.store});

  final MansionStore store;

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  LeaderboardSort _sort = LeaderboardSort.mostActive;
  LeaderboardPeriod _period = LeaderboardPeriod.currentMonth;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final rows = widget.store.buildLeaderboard(period: _period, sort: _sort);
    return ListView(
      key: const PageStorageKey('leaderboard'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(
          s.leaderboardEyebrow,
          style: const TextStyle(
            color: Color(0xFFC6A15B),
            letterSpacing: 2,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(s.leaderboardHeading, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        const Text(
          'Počítají se výhradně karty potvrzené směnou u Ruky.',
          style: TextStyle(color: Color(0xFF968C80), fontSize: 12),
        ),
        const SizedBox(height: 14),
        SegmentedButton<LeaderboardPeriod>(
          segments: [
            for (final p in LeaderboardPeriod.values)
              ButtonSegment(value: p, label: Text(p.label)),
          ],
          selected: {_period},
          onSelectionChanged: (s) => setState(() => _period = s.first),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final s in LeaderboardSort.values) ...[
                ChoiceChip(
                  label: Text(s.label),
                  selected: _sort == s,
                  onSelected: (_) => setState(() => _sort = s),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          rows.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _PlayerLeaderboardCard(rank: i + 1, data: rows[i]),
          ),
        ),
      ],
    );
  }
}

class _PlayerLeaderboardCard extends StatelessWidget {
  const _PlayerLeaderboardCard({required this.rank, required this.data});

  final int rank;
  final PlayerLeaderboardCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);
    final auraColor = _heatColor(context, data.heatLevel);
    final auraGlow = theme.heatGlowRadius(data.heatLevel);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17171A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: auraColor,
          width: data.heatLevel == HeatLevel.coldAsh ? 1 : 2,
        ),
        boxShadow: auraGlow > 0
            ? [
                BoxShadow(
                  color: auraColor.withValues(alpha: 0.45),
                  blurRadius: auraGlow,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: auraColor.withValues(alpha: 0.2),
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: auraColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            data.member.nickname,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (data.member.isHand) ...[
                          const SizedBox(width: 6),
                          const Tooltip(
                            message: 'Zakladatel = Ruka',
                            child: Icon(
                              Icons.front_hand,
                              size: 16,
                              color: Color(0xFFC6A15B),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${data.monthlyLevel.label} (${data.monthlyLevel.utCallout})',
                      style: const TextStyle(
                        color: Color(0xFFC6A15B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                avatar: Icon(
                  _heatIcon(context, data.heatLevel),
                  size: 16,
                  color: auraColor,
                ),
                label: Text(
                  '${data.heatLevel.label} (+${data.heatLevel.bonusPercent} %)',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'ÚKOLY',
                  value: '${data.approvedTaskCount}',
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'COINY',
                  value: '${data.approvedCoins}',
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'STREAK',
                  value: '${data.streakDays} d',
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'ČAS',
                  value: '${data.approvedMinutes} m',
                ),
              ),
            ],
          ),
          if (data.inBankCount > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'V Mešci čeká: ${data.inBankCount} karet (',
                  style: const TextStyle(color: Color(0xFF968C80), fontSize: 11),
                ),
                _CoinAmount(
                  amount: data.inBankCoins,
                  fontSize: 11,
                  iconSize: 12,
                  color: const Color(0xFF968C80),
                  fontWeight: FontWeight.normal,
                ),
                const Text(
                  ')',
                  style: TextStyle(color: Color(0xFF968C80), fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 1.2,
            color: Color(0xFF968C80),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 4. Mansion Tab (Avatar, My Mansions, App Updates)
// =============================================================================

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({
    super.key,
    required this.store,
    this.updateService,
    this.pendingUpdate,
  });

  final MansionStore store;
  final DistributionUpdateService? updateService;
  final UpdateCheckResult? pendingUpdate;

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late final TextEditingController _renameController = TextEditingController(
    text: widget.store.currentMember?.nickname ??
        widget.store.avatarNickname ??
        '',
  );
  late MemberSex _selectedSex =
      widget.store.currentMember?.sex ?? widget.store.avatarSex;

  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = ThemeScope.of(context);
    final store = widget.store;
    final activeGang = store.gang;
    final gangs = store.myGangs;
    final updateService = widget.updateService;
    final pendingUpdate = widget.pendingUpdate;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        // 1. Your Avatar (Nickname & Sex)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF17171A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF3B3329)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.yourAvatarSection,
                    style: const TextStyle(
                      color: Color(0xFFC6A15B),
                      letterSpacing: 1.6,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (store.authUserEmail != null)
                    Flexible(
                      child: Text(
                        store.authUserEmail!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF968C80),
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _renameController,
                decoration: InputDecoration(
                  labelText: s.nicknameLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              MemberSexSelector(
                selected: _selectedSex,
                onChanged: (sex) => setState(() => _selectedSex = sex),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: withButtonSound(() {
                    store.updateCurrentAvatar(
                      nickname: _renameController.text,
                      sex: _selectedSex,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.avatarSavedSnackbar)),
                    );
                  }),
                  icon: const Icon(Icons.save_outlined, size: 17),
                  label: Text(s.saveBtn),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. My Mansions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${s.myMansionsSection} (${gangs.length})',
              style: const TextStyle(
                color: Color(0xFFC6A15B),
                letterSpacing: 1.6,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: withButtonSound(
                    () => showCreateGangDialog(context, store),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(s.createMansionBtn),
                ),
                TextButton.icon(
                  onPressed: withButtonSound(
                    () => showAcceptInviteDialog(context, store),
                  ),
                  icon: const Icon(Icons.vpn_key_outlined, size: 15),
                  label: Text(s.joinMansionBtn),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final g in gangs)
          _MansionListCard(
            mansion: g,
            isActive: g.id == activeGang?.id,
            isOwner: store.isOwnerOf(g.id),
            memberCount: store.memberCountIn(g.id),
            imageAsset: theme.onboardingWorldArt,
            onTap: withButtonSound(() {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ManageGangPage(store: store, gangId: g.id),
                ),
              );
            })!,
          ),

        // 3. App Updates & Notifications
        if (updateService != null) ...[
          const SizedBox(height: 16),
          const Divider(),
          if (pendingUpdate != null && pendingUpdate.isUpdateAvailable) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6E1830).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFC6A15B)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_outlined,
                    color: Color(0xFFC6A15B),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.newVersionTitle(
                        pendingUpdate.info.latestVersion,
                        pendingUpdate.info.latestBuildNumber,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  FilledButton(
                    onPressed: () =>
                        updateService.openUpdateUrl(pendingUpdate.info),
                    child: Text(s.updateNowBtn),
                  ),
                ],
              ),
            ),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.system_update_alt,
              color: Color(0xFFC6A15B),
            ),
            title: Text(s.appUpdatesTitle),
            subtitle: FutureBuilder<({String version, int buildNumber})>(
              future: updateService.currentAppVersion(),
              builder: (context, snapshot) {
                final v = snapshot.data;
                return Text(
                  v == null
                      ? s.checkNewVersion
                      : s.currentVersionLine(v.version, v.buildNumber),
                );
              },
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final result = await updateService.checkForUpdate();
              if (result != null && result.isUpdateAvailable) {
                await updateService.openUpdateUrl(result.info);
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(s.latestVersionSnackbar),
                  ),
                );
              }
            },
          ),
        ],
      ],
    );
  }
}

class _MansionListCard extends StatelessWidget {
  const _MansionListCard({
    required this.mansion,
    required this.isActive,
    required this.isOwner,
    required this.memberCount,
    required this.imageAsset,
    required this.onTap,
  });

  final Gang mansion;
  final bool isActive;
  final bool isOwner;
  final int memberCount;
  final String imageAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF17171A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? const Color(0xFFC6A15B) : const Color(0xFF3B3329),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFC6A15B).withValues(alpha: 0.14),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imageAsset,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6E1830),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFC6A15B),
                              ),
                            ),
                            child: Text(
                              s.activeMansionBadge,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            mansion.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.membersCountLabel(memberCount)} • ${isOwner ? s.roleHandSubtitle : s.roleMemberSubtitle}',
                      style: const TextStyle(
                        color: Color(0xFF968C80),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mansion.inviteCode,
                      style: const TextStyle(
                        color: Color(0xFFC6A15B),
                        fontSize: 11,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF968C80),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.valueWidget,
  });

  final IconData icon;
  final String value;
  final String label;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF3B3329)),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Column(
      children: [
        Icon(icon, size: 19, color: const Color(0xFFC6A15B)),
        const SizedBox(height: 6),
        valueWidget ??
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            letterSpacing: 1.2,
            color: Color(0xFF776F66),
          ),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8E8170),
        letterSpacing: 1.8,
        fontSize: 10,
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.text,
    this.imageAsset,
  });

  final IconData icon;
  final String title;
  final String text;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageAsset != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                imageAsset!,
                height: 220,
                fit: BoxFit.contain,
              ),
            )
          else
            Icon(icon, size: 52, color: const Color(0xFF5A4931)),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF968C80)),
          ),
        ],
      ),
    ),
  );
}
