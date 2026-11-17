import 'package:flutter/material.dart';

import '../../app_strings.dart';
import '../../gangs_screens.dart';
import '../../mansion_store.dart';
import '../../models.dart';
import '../../sound_service.dart';

class CreateAvatarScreen extends StatefulWidget {
  const CreateAvatarScreen({super.key, required this.store});

  final MansionStore store;

  @override
  State<CreateAvatarScreen> createState() => _CreateAvatarScreenState();
}

class _CreateAvatarScreenState extends State<CreateAvatarScreen> {
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
                      s.createAvatarTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: _boneText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.createAvatarSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _mutedStone, fontSize: 13),
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
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _voidBg,
                          labelText: s.createAvatarNicknameLabel,
                          hintText: s.nicknameExampleHint,
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: _mutedStone,
                            size: 18,
                          ),
                          border: const OutlineInputBorder(),
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
