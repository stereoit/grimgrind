import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_strings.dart';
import 'features/mansion/mansion_shell.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/onboarding/splash_screen.dart';
import 'mansion_store.dart';
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
  const GrimGrindApp({
    super.key,
    this.store,
    this.updateService,
    this.showSplash,
  });

  final MansionStore? store;
  final DistributionUpdateService? updateService;
  final bool? showSplash;

  @override
  State<GrimGrindApp> createState() => _GrimGrindAppState();
}

class _GrimGrindAppState extends State<GrimGrindApp> {
  late final MansionStore store = widget.store ?? MansionStore();
  late bool _showingSplash = widget.showSplash ?? (widget.store == null);

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
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: _showingSplash
                  ? SplashScreen(
                      key: const ValueKey('splash'),
                      onFinished: () => setState(() => _showingSplash = false),
                    )
                  : !store.isReady
                      ? OnboardingFlow(key: const ValueKey('onboarding'), store: store)
                      : MansionShell(
                          key: const ValueKey('shell'),
                          store: store,
                          updateService: widget.updateService,
                        ),
            ),
          ),
        );
      },
    );
  }
}
