import 'package:flutter/material.dart';

import '../../app_strings.dart';
import '../../gangs_screens.dart';
import '../../mansion_store.dart';
import '../../models.dart';
import '../../sound_service.dart';
import '../../theme_package.dart';
import '../../update_checker.dart';

class MansionPage extends StatefulWidget {
  const MansionPage({
    super.key,
    required this.store,
    this.updateService,
    this.pendingUpdate,
  });

  final MansionStore store;
  final DistributionUpdateService? updateService;
  final UpdateCheckResult? pendingUpdate;

  @override
  State<MansionPage> createState() => _MansionPageState();
}

class _MansionPageState extends State<MansionPage> {
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

  Future<void> _confirmLogout(BuildContext context, MansionStore store) async {
    final s = AppStrings.of(context);
    final email = store.authUserEmail;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.logoutConfirmTitle),
        content: Text(
          email != null ? s.logoutConfirmBodyEmail(email) : s.logoutConfirmBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancelBtn),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.logoutBtn),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await store.signOutAsync();
    }
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
              Row(
                mainAxisAlignment: store.isSignedIn
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  if (store.isSignedIn)
                    OutlinedButton.icon(
                      onPressed: withButtonSound(
                        () => _confirmLogout(context, store),
                      ),
                      icon: const Icon(Icons.logout, size: 17),
                      label: Text(s.logoutBtn),
                    ),
                  FilledButton.icon(
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
                ],
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
