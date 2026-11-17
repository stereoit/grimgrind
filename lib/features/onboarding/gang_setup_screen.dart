import 'package:flutter/material.dart';

import '../../app_strings.dart';
import '../../gangs_screens.dart';
import '../../mansion_store.dart';
import '../../models.dart';
import '../../sound_service.dart';
import '../../theme_package.dart';

class GangSetupScreen extends StatefulWidget {
  const GangSetupScreen({super.key, required this.store});

  final MansionStore store;

  @override
  State<GangSetupScreen> createState() => _GangSetupScreenState();
}

class _GangSetupScreenState extends State<GangSetupScreen> {
  bool _createMode = true;
  bool _includeStarterFamily = true;
  bool _isSubmitting = false;
  late MemberSex _selectedSex = widget.store.avatarSex;
  final _gangNameController = TextEditingController();
  bool _didInitGangName = false;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitGangName) {
      _didInitGangName = true;
      _gangNameController.text = AppStrings.of(context).defaultMansionName;
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
            Text(
              s.gangSetupEyebrow,
              style: const TextStyle(
                color: Color(0xFFC6A15B),
                letterSpacing: 2,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            Text(s.gangSetupTitle, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              s.gangSetupSubtitle,
              style: const TextStyle(color: Color(0xFF968C80), height: 1.4),
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
                  labelText: s.mansionNameLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: s.founderNicknameLabel,
                  border: const OutlineInputBorder(),
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
                title: Text(s.starterFamilyTitle),
                subtitle: Text(s.starterFamilySubtitle),
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
                                    s.createMansionFailedError,
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
                  labelText: s.mansionInviteCodeLabel,
                  hintText: s.inviteCodeExampleHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: s.createAvatarNicknameLabel,
                  border: const OutlineInputBorder(),
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
                                    s.invalidInviteCodeError,
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
