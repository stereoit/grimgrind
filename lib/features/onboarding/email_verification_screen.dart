import 'package:flutter/material.dart';

import '../../app_strings.dart';
import '../../mansion_store.dart';
import '../../sound_service.dart';

class EmailVerificationNoticeScreen extends StatelessWidget {
  const EmailVerificationNoticeScreen({super.key, required this.store});

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
    final s = AppStrings.of(context);
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
                  Text(
                    s.sealSentEyebrow,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _goldAccent,
                      fontSize: 11,
                      letterSpacing: 2.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.verifyEmailTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _boneText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s.verifyEmailBody(email),
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
                    label: Text(s.continueToAvatar),
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
