import 'package:flutter/material.dart';

import '../../app_strings.dart';
import '../../mansion_store.dart';
import '../../sound_service.dart';
import '../../theme_package.dart';
import 'auth_gate_screen.dart';
import 'create_avatar_screen.dart';
import 'email_verification_screen.dart';
import 'gang_setup_screen.dart';

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
      return AuthGateScreen(store: widget.store);
    }
    if (widget.store.pendingVerificationEmail != null) {
      return EmailVerificationNoticeScreen(store: widget.store);
    }
    if (!widget.store.hasAvatar) {
      return CreateAvatarScreen(store: widget.store);
    }
    return GangSetupScreen(store: widget.store);
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
