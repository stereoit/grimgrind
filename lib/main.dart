import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_strings.dart';
import 'features/mansion/mansion_shell.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/onboarding/splash_screen.dart';
import 'l10n/app_localizations.dart';
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

class _GrimGrindAppState extends State<GrimGrindApp> with WidgetsBindingObserver {
  late final MansionStore store = widget.store ?? MansionStore();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final initialUri = Uri.tryParse(
      WidgetsBinding.instance.platformDispatcher.defaultRouteName,
    );
    if (initialUri != null) {
      _handleIncomingUri(initialUri);
    }
    if (widget.store == null) {
      store.syncFromFirebase();
    } else if (store.pendingInviteCode != null) {
      store.acceptPendingInviteIfEligible();
    }
  }

  bool _handleIncomingUri(Uri uri) {
    final code = MansionStore.parseInviteCodeFromUri(uri);
    if (code == null || code.isEmpty) return false;
    store.setPendingInviteCode(code);
    store.acceptPendingInviteIfEligible();
    return true;
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    if (_handleIncomingUri(routeInformation.uri)) {
      return true;
    }
    return super.didPushRouteInformation(routeInformation);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
              AppLocalizations.delegate,
              AppStrings.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            onGenerateInitialRoutes: (_) => [
              MaterialPageRoute<void>(
                settings: const RouteSettings(name: '/'),
                builder: (_) => _GrimGrindHome(
                  store: store,
                  updateService: widget.updateService,
                  showSplash: widget.showSplash ?? (widget.store == null),
                ),
              ),
            ],
            onGenerateRoute: (settings) => MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => _GrimGrindHome(
                store: store,
                updateService: widget.updateService,
                showSplash: false,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GrimGrindHome extends StatefulWidget {
  const _GrimGrindHome({
    required this.store,
    required this.showSplash,
    this.updateService,
  });

  final MansionStore store;
  final DistributionUpdateService? updateService;
  final bool showSplash;

  @override
  State<_GrimGrindHome> createState() => _GrimGrindHomeState();
}

class _GrimGrindHomeState extends State<_GrimGrindHome> {
  late bool _showingSplash = widget.showSplash;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: _showingSplash
              ? SplashScreen(
                  key: const ValueKey('splash'),
                  onFinished: () => setState(() => _showingSplash = false),
                )
              : !widget.store.isReady
                  ? OnboardingFlow(
                      key: const ValueKey('onboarding'),
                      store: widget.store,
                    )
                  : MansionShell(
                      key: const ValueKey('shell'),
                      store: widget.store,
                      updateService: widget.updateService,
                    ),
        );
      },
    );
  }
}
