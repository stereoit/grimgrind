import 'package:flutter/material.dart';

import '../../app_strings.dart';
import '../../theme_package.dart';

/// Dedicated gothic loading/splash screen shown on app launch before entering
/// onboarding or the active Mansion shell.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onFinished,
    this.duration = const Duration(milliseconds: 1600),
  });

  final VoidCallback onFinished;
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 1.0, curve: Curves.easeInOut),
    );
    _controller.forward().whenComplete(() {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = ThemeScope.of(context);
    final tagline = s.splashTagline;
    final loadingLabel = s.splashLoading;

    return Scaffold(
      backgroundColor: theme.voidBackground,
      body: SafeArea(
        child: Stack(
          children: [
            _CornerFiligree(color: theme.primaryAccent.withValues(alpha: 0.35)),
            Center(
              child: FadeTransition(
                opacity: _fadeIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 228,
                        height: 228,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.secondaryAccent.withValues(
                                alpha: 0.32,
                              ),
                              blurRadius: 48,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/branding/splash_mark.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        theme.appWordmark,
                        style: TextStyle(
                          fontFamily: theme.fontFamily,
                          color: theme.onSurface,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 6.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.primaryAccent,
                          fontSize: 10,
                          letterSpacing: 2.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: 220,
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: _progress,
                              builder: (context, _) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: _progress.value,
                                    minHeight: 2,
                                    backgroundColor: theme.border,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.primaryAccent,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            Text(
                              loadingLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.mutedText,
                                fontSize: 10,
                                letterSpacing: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerFiligree extends StatelessWidget {
  const _CornerFiligree({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomPaint(
          painter: _CornerBracketPainter(color: color),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  _CornerBracketPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const len = 18.0;
    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, 0)
        ..lineTo(len, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, len),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height)
        ..lineTo(len, size.height),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) =>
      oldDelegate.color != color;
}
