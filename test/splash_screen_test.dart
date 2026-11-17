import 'package:chore_cash/features/onboarding/splash_screen.dart';
import 'package:chore_cash/theme_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SplashScreen displays branding and invokes onFinished',
      (tester) async {
    var finished = false;

    await tester.pumpWidget(
      ThemeScope(
        theme: ThemeRegistry.gothicMansion,
        child: MaterialApp(
          locale: const Locale('en'),
          home: SplashScreen(
            duration: const Duration(milliseconds: 500),
            onFinished: () => finished = true,
          ),
        ),
      ),
    );

    expect(find.text('GRIMGRIND'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(finished, isFalse);

    await tester.pump(const Duration(milliseconds: 600));
    expect(finished, isTrue);
  });
}
