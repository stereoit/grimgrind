import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_strings.dart';
import 'mansion_store.dart';
import 'models.dart';
import 'sound_service.dart';
import 'theme_package.dart';

const _voidBg = Color(0xFF0B0B0D);
const _coalSurface = Color(0xFF17171A);
const _gothBorder = Color(0xFF3B3329);
const _boneText = Color(0xFFE9E0D0);
const _goldAccent = Color(0xFFC6A15B);
const _bloodWine = Color(0xFF6E1830);
const _bloodBorder = Color(0xFF9B3B48);
const _mutedStone = Color(0xFF968C80);

class _GothicModalFrame extends StatelessWidget {
  const _GothicModalFrame({
    required this.child,
    this.borderColor = _gothBorder,
    this.borderWidth = 1,
  });

  final Widget child;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: _coalSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: const [
            BoxShadow(
              color: Color(0xCC000000),
              blurRadius: 32,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 10,
              child: Text(
                '╔═',
                style: TextStyle(
                  color: _goldAccent.withValues(alpha: 0.35),
                  fontSize: 10,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 10,
              child: Text(
                '═╗',
                style: TextStyle(
                  color: _goldAccent.withValues(alpha: 0.35),
                  fontSize: 10,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 10,
              child: Text(
                '╚═',
                style: TextStyle(
                  color: _goldAccent.withValues(alpha: 0.35),
                  fontSize: 10,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 10,
              child: Text(
                '═╝',
                style: TextStyle(
                  color: _goldAccent.withValues(alpha: 0.35),
                  fontSize: 10,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: SingleChildScrollView(child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _GothicCrest extends StatelessWidget {
  const _GothicCrest({
    required this.icon,
    this.color = _goldAccent,
    this.fillColor = _voidBg,
  });

  final IconData icon;
  final Color color;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fillColor,
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _BloodWineButton extends StatelessWidget {
  const _BloodWineButton({
    required this.onPressed,
    required this.label,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: _bloodWine,
        disabledBackgroundColor: _bloodWine.withValues(alpha: 0.35),
        foregroundColor: _boneText,
        disabledForegroundColor: _mutedStone,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: onPressed != null
                ? _bloodBorder
                : _bloodBorder.withValues(alpha: 0.3),
          ),
        ),
      ),
      onPressed: withButtonSound(onPressed),
      icon: icon != null
          ? Icon(icon, size: 17, color: onPressed != null ? _goldAccent : _mutedStone)
          : const SizedBox.shrink(),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

class MemberSexSelector extends StatelessWidget {
  const MemberSexSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final MemberSex selected;
  final ValueChanged<MemberSex> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'POHLAVÍ (PRO SPRÁVNÉ SKLOŇOVÁNÍ V KRONICE)',
          style: TextStyle(
            color: _goldAccent,
            fontSize: 10,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _voidBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _gothBorder),
          ),
          child: Row(
            children: [
              for (final sex in MemberSex.values)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(sex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected == sex ? _bloodWine : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: selected == sex
                            ? Border.all(color: _bloodBorder)
                            : null,
                      ),
                      child: Text(
                        sex.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected == sex ? _boneText : _mutedStone,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<bool> showAcceptInviteDialog(
  BuildContext context,
  MansionStore store, {
  String? initialCodeOrLink,
}) async {
  final joined = await showDialog<bool>(
    context: context,
    builder: (ctx) => _AcceptInviteDialog(
      store: store,
      initialCodeOrLink: initialCodeOrLink,
    ),
  );
  return joined ?? false;
}

class _AcceptInviteDialog extends StatefulWidget {
  const _AcceptInviteDialog({
    required this.store,
    this.initialCodeOrLink,
  });

  final MansionStore store;
  final String? initialCodeOrLink;

  @override
  State<_AcceptInviteDialog> createState() => _AcceptInviteDialogState();
}

class _AcceptInviteDialogState extends State<_AcceptInviteDialog> {
  late final TextEditingController _codeController = TextEditingController(
    text: widget.initialCodeOrLink?.trim().toUpperCase() ?? '',
  );
  final TextEditingController _nicknameController = TextEditingController();
  MemberSex _selectedSex = MemberSex.male;
  String? _errorText;
  bool _isSubmitting = false;
  String? _remoteMatchedGangName;
  String? _lastLookedUpCode;

  @override
  void initState() {
    super.initState();
    _maybeLookupRemoteInvite(_resolveCode(_codeController.text));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  String _resolveCode(String raw) {
    final rawInput = raw.trim();
    final parsedUri = Uri.tryParse(rawInput);
    return (parsedUri != null && rawInput.contains('://'))
        ? (MansionStore.parseInviteCodeFromUri(parsedUri) ?? rawInput)
        : rawInput.toUpperCase();
  }

  Future<void> _maybeLookupRemoteInvite(String resolvedCode) async {
    if (!widget.store.isFirebaseReady || resolvedCode.length < 4) {
      if (_remoteMatchedGangName != null) {
        setState(() => _remoteMatchedGangName = null);
      }
      return;
    }
    if (widget.store.findGangByInviteCode(resolvedCode) != null) return;
    if (_lastLookedUpCode == resolvedCode) return;
    _lastLookedUpCode = resolvedCode;
    final data = await widget.store.lookupRemoteInvite(resolvedCode);
    if (!mounted) return;
    if (_resolveCode(_codeController.text) != resolvedCode) return;
    setState(() {
      _remoteMatchedGangName = data?['gangName'] as String?;
    });
  }

  @override
  Widget build(BuildContext context) {
    final resolvedCode = _resolveCode(_codeController.text);
    final matchedGang = widget.store.findGangByInviteCode(resolvedCode);
    final matchedGangName = matchedGang?.name ?? _remoteMatchedGangName;
    final matchedCount =
        matchedGang != null ? widget.store.memberCountIn(matchedGang.id) : null;

    return _GothicModalFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Column(
            children: [
              _GothicCrest(icon: Icons.mail_outline),
              SizedBox(height: 6),
              Text(
                'VSTUP DO SPOLEČENSTVA',
                style: TextStyle(
                  color: _goldAccent,
                  fontSize: 10,
                  letterSpacing: 2.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Přijmout pozvánku do Sídla',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Text(
                'Ověřte kód brány a podepište se do rodové knihy.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _mutedStone, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: _gothBorder, height: 1),
          const SizedBox(height: 10),
          if (matchedGangName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: _voidBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _goldAccent.withValues(alpha: 0.65)),
              ),
              child: Column(
                children: [
                  Text(
                    'Pozvánka do: $matchedGangName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _goldAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (matchedCount != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$matchedCount stávajících členů',
                      style: const TextStyle(color: _mutedStone, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            onChanged: (value) {
              setState(() {
                _errorText = null;
                if (widget.store.findGangByInviteCode(_resolveCode(value)) == null) {
                  _remoteMatchedGangName = null;
                }
              });
              _maybeLookupRemoteInvite(_resolveCode(value));
            },
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              fillColor: _voidBg,
              labelText: 'Zvací kód nebo odkaz',
              hintText: 'GRIM-42 nebo https://grim-grind.web.app/join?code=...',
              suffixIcon: Icon(
                matchedGangName != null
                    ? Icons.verified
                    : Icons.vpn_key_outlined,
                color: matchedGangName != null ? _goldAccent : _mutedStone,
                size: 18,
              ),
              border: const OutlineInputBorder(),
              errorText: _errorText,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nicknameController,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              fillColor: _voidBg,
              labelText: 'Tvoje přezdívka v tomto Sídle',
              hintText: 'Např. Shadow Master',
              suffixIcon: Icon(
                Icons.badge_outlined,
                color: _mutedStone,
                size: 18,
              ),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          MemberSexSelector(
            selected: _selectedSex,
            onChanged: (sex) => setState(() => _selectedSex = sex),
          ),
          const SizedBox(height: 12),
          const Divider(color: _gothBorder, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Zrušit',
                    style: TextStyle(color: _mutedStone),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _BloodWineButton(
                  icon: Icons.login,
                  label: _isSubmitting ? 'Připojuji se...' : 'Připojit se',
                  onPressed: _isSubmitting
                      ? () {}
                      : () async {
                          final navigator = Navigator.of(context);
                          setState(() {
                            _isSubmitting = true;
                            _errorText = null;
                          });
                          final ok = await widget.store.joinGangByCodeAsync(
                            inviteCode: resolvedCode,
                            nickname: _nicknameController.text,
                            sex: _selectedSex,
                          );
                          if (!mounted) return;
                          if (!ok) {
                            setState(() {
                              _isSubmitting = false;
                              _errorText = widget.store.lastSyncError ??
                                  'Neplatný zvací kód Sídla.';
                            });
                            return;
                          }
                          navigator.pop(true);
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<bool> showCreateGangDialog(
  BuildContext context,
  MansionStore store,
) async {
  final created = await showDialog<bool>(
    context: context,
    builder: (ctx) => _CreateGangDialog(store: store),
  );
  return created ?? false;
}

class _CreateGangDialog extends StatefulWidget {
  const _CreateGangDialog({required this.store});

  final MansionStore store;

  @override
  State<_CreateGangDialog> createState() => _CreateGangDialogState();
}

class _CreateGangDialogState extends State<_CreateGangDialog> {
  final TextEditingController _gangController = TextEditingController();
  late final TextEditingController _nickController = TextEditingController(
    text: widget.store.currentMember?.nickname ?? 'Dark Lord',
  );
  late MemberSex _founderSex =
      widget.store.currentMember?.sex ?? MemberSex.male;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _gangController.dispose();
    _nickController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GothicModalFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Column(
            children: [
              _GothicCrest(icon: Icons.castle_outlined),
              SizedBox(height: 10),
              Text(
                'ZAKLÁDACÍ LISTINA PANSTVÍ',
                style: TextStyle(
                  color: _goldAccent,
                  fontSize: 10,
                  letterSpacing: 2.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Založit nové Sídlo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Vytvořte nové panství sídla. Stanete se Rukou a pánem nad pravidly pokladnice.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _mutedStone, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _gothBorder, height: 1),
          const SizedBox(height: 14),
          TextField(
            controller: _gangController,
            decoration: const InputDecoration(
              filled: true,
              fillColor: _voidBg,
              labelText: 'Název Sídla',
              hintText: 'Např. Sídlo Havranů',
              suffixIcon: Icon(
                Icons.domain_outlined,
                color: _mutedStone,
                size: 18,
              ),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nickController,
            decoration: const InputDecoration(
              filled: true,
              fillColor: _voidBg,
              labelText: 'Tvoje přezdívka (Ruka)',
              suffixIcon: Icon(
                Icons.front_hand_outlined,
                color: _mutedStone,
                size: 18,
              ),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          MemberSexSelector(
            selected: _founderSex,
            onChanged: (sex) => setState(() => _founderSex = sex),
          ),
          const SizedBox(height: 16),
          if (_errorText != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _bloodWine.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _bloodBorder),
              ),
              child: Text(
                _errorText!,
                style: const TextStyle(color: _bloodBorder, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
          ],
          const Divider(color: _gothBorder, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Zrušit',
                    style: TextStyle(color: _mutedStone),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _BloodWineButton(
                  icon: Icons.castle_outlined,
                  label: _isSubmitting ? 'Zakládám...' : 'Založit',
                  onPressed: _isSubmitting
                      ? () {}
                      : () async {
                          final navigator = Navigator.of(context);
                          setState(() {
                            _isSubmitting = true;
                            _errorText = null;
                          });
                          final ok = await widget.store.createGangAsync(
                            gangName: _gangController.text,
                            founderNickname: _nickController.text,
                            founderSex: _founderSex,
                          );
                          if (!mounted) return;
                          if (!ok) {
                            setState(() {
                              _isSubmitting = false;
                              _errorText = widget.store.lastSyncError ??
                                  'Nepodařilo se založit Sídlo.';
                            });
                            return;
                          }
                          navigator.pop(true);
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyGangsPage extends StatelessWidget {
  const MyGangsPage({super.key, required this.store});

  final MansionStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final gangs = store.myGangs;
        final activeId = store.gang?.id;
        final activeNick = store.currentMember?.nickname;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            titleSpacing: 4,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPRÁVA SÍDEL',
                  style: TextStyle(
                    color: _goldAccent,
                    letterSpacing: 2.2,
                    fontSize: 10,
                  ),
                ),
                Text('Moje Sídla', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _BloodWineButton(
                      onPressed: () => showCreateGangDialog(context, store),
                      icon: Icons.castle_outlined,
                      label: 'Založit Sídlo',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _coalSurface,
                        foregroundColor: _boneText,
                        side: const BorderSide(color: _gothBorder),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: withButtonSound(
                        () => showAcceptInviteDialog(context, store),
                      ),
                      icon: const Icon(
                        Icons.vpn_key_outlined,
                        size: 17,
                        color: _goldAccent,
                      ),
                      label: const Text('Přijmout kód'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PŘEHLED SPOLEČENSTEV (${gangs.length})',
                    style: const TextStyle(
                      color: _mutedStone,
                      letterSpacing: 1.6,
                      fontSize: 11,
                    ),
                  ),
                  if (activeNick != null)
                    Text(
                      activeNick.toUpperCase(),
                      style: const TextStyle(
                        color: _goldAccent,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (gangs.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Zatím nejsi členem žádného Sídla.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                for (final gang in gangs)
                  _GangTile(
                    gang: gang,
                    isActive: gang.id == activeId,
                    isOwner: store.isOwnerOf(gang.id),
                    nickname: store.memberNicknameIn(gang.id) ?? '',
                    memberCount: store.memberCountIn(gang.id),
                    onSelect: () {
                      store.switchGang(gang.id);
                      Navigator.pop(context);
                    },
                    onManage: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ManageGangPage(store: store, gangId: gang.id),
                        ),
                      );
                    },
                  ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _coalSurface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _gothBorder.withValues(alpha: 0.7)),
                ),
                child: const Column(
                  children: [
                    Text(
                      '„Spolek bez pevného sídla je pouhým hloučkem poutníků ve vichřici. Ruka vládne tam, kde pečeť drží slovo.“',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: _goldAccent,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '— KÁNON ŘÁDU HAVRANŮ',
                      style: TextStyle(
                        color: _mutedStone,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GangTile extends StatelessWidget {
  const _GangTile({
    required this.gang,
    required this.isActive,
    required this.isOwner,
    required this.nickname,
    required this.memberCount,
    required this.onSelect,
    required this.onManage,
  });

  final Gang gang;
  final bool isActive;
  final bool isOwner;
  final String nickname;
  final int memberCount;
  final VoidCallback onSelect;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _coalSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? _goldAccent : _gothBorder,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: _goldAccent.withValues(alpha: 0.12),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isActive)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _bloodWine,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _bloodBorder),
                          ),
                          child: const Text(
                            'AKTIVNÍ',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _voidBg,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _gothBorder),
                          ),
                          child: const Text(
                            'ZÁLOŽNÍ',
                            style: TextStyle(
                              fontSize: 10,
                              color: _mutedStone,
                            ),
                          ),
                        ),
                      Text(
                        isOwner ? 'RUKA (VLASTNÍK)' : 'ČLEN',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1,
                          color: isOwner ? _goldAccent : _mutedStone,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 14,
                        color: isActive ? _goldAccent : _mutedStone,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$memberCount členů',
                        style: const TextStyle(color: _mutedStone, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gang.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Přezdívka: $nickname',
                          style: const TextStyle(
                            color: _mutedStone,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _voidBg,
                      foregroundColor: isActive ? _goldAccent : _boneText,
                      side: BorderSide(
                        color: isActive ? _goldAccent : _gothBorder,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: onManage,
                    child: const Text('Spravovat'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(child: Divider(color: _gothBorder, height: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      isActive ? '✦ GRIMGRIND ✦' : '✦',
                      style: TextStyle(
                        color: isActive ? _goldAccent : _mutedStone,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: _gothBorder, height: 1)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Zvací kód: ',
                        style: TextStyle(color: _mutedStone, fontSize: 11),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _voidBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _gothBorder),
                        ),
                        child: Text(
                          gang.inviteCode,
                          style: TextStyle(
                            color: isActive ? _goldAccent : _boneText,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Směna: ${gang.coinsPerCzk} Zl = 1 Kč',
                    style: const TextStyle(color: _mutedStone, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManageGangPage extends StatelessWidget {
  const ManageGangPage({
    super.key,
    required this.store,
    required this.gangId,
  });

  final MansionStore store;
  final String gangId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final gang = store.myGangs.cast<Gang?>().firstWhere(
          (g) => g?.id == gangId,
          orElse: () => null,
        );
        if (gang == null) {
          return Scaffold(
            appBar: AppBar(title: Text(AppStrings.of(context).navMansion)),
            body: Center(
              child: Text(
                AppStrings.of(context).isCs
                    ? 'Sídlo bylo smazáno.'
                    : 'Mansion was deleted.',
              ),
            ),
          );
        }

        final s = AppStrings.of(context);
        final theme = ThemeScope.of(context);
        final isOwner = store.isOwnerOf(gangId);
        final isActive = store.gang?.id == gangId;
        final members = store.membersOf(gangId);
        final inviteMessage = s.isCs
            ? 'Přidej se do mého Sídla „${gang.name}“ v GrimGrind! '
                'Otevři odkaz: ${gang.inviteUrl} (nebo zadej kód ${gang.inviteCode}).'
            : 'Join my Mansion "${gang.name}" in GrimGrind! '
                'Open link: ${gang.inviteUrl} (or enter code ${gang.inviteCode}).';

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gang.name.toUpperCase(),
                  style: const TextStyle(
                    color: _goldAccent,
                    letterSpacing: 2,
                    fontSize: 10,
                  ),
                ),
                const Text(
                  'Správa a Pozvánky',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _bloodWine.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _bloodBorder.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      isOwner ? 'RUKA' : 'ČLEN',
                      style: const TextStyle(
                        color: _bloodBorder,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _coalSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive ? _goldAccent : _gothBorder,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        Image.asset(
                          theme.onboardingWorldArt,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? _bloodWine
                                  : _voidBg.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isActive ? _goldAccent : _gothBorder,
                              ),
                            ),
                            child: Text(
                              isActive
                                  ? s.activeMansionBadge
                                  : (s.isCs ? 'NEAKTIVNÍ' : 'INACTIVE'),
                              style: TextStyle(
                                color: isActive ? _boneText : _mutedStone,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            gang.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.membersCountLabel(members.length),
                            style: const TextStyle(
                              color: _mutedStone,
                              fontSize: 12,
                            ),
                          ),
                          if (!isActive) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: withButtonSound(() {
                                store.switchGang(gangId);
                              }),
                              icon: const Icon(
                                Icons.castle_outlined,
                                size: 17,
                                color: _goldAccent,
                              ),
                              label: Text(s.setActiveMansionBtn),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _coalSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _gothBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'POZVÁNKA PRO PŘÁTELE (IM ODKAZ)',
                          style: TextStyle(
                            color: _goldAccent,
                            letterSpacing: 1.6,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.share_outlined, color: _goldAccent, size: 17),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _voidBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _gothBorder),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'UNIKÁTNÍ ZVACÍ KÓD',
                            style: TextStyle(
                              color: _mutedStone,
                              fontSize: 10,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            gang.inviteCode,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: _goldAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _voidBg.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _gothBorder.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              gang.inviteUrl,
                              style: const TextStyle(
                                color: _mutedStone,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.link,
                            color: _mutedStone,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _BloodWineButton(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: inviteMessage),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Zvací odkaz zkopírován pro odeslání v chatu.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icons.copy_outlined,
                      label: 'Zkopírovat zvací odkaz do zpráv',
                    ),
                    if (isOwner) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _voidBg,
                          foregroundColor: _boneText,
                          side: const BorderSide(color: _gothBorder),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          final next = store.regenerateInviteCode(gang.id);
                          if (next != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Nový zvací kód: $next'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.refresh,
                          size: 17,
                          color: _goldAccent,
                        ),
                        label: const Text('Obnovit zvací kód'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _coalSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _gothBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${s.membersSectionTitle} (${members.length})',
                          style: const TextStyle(
                            color: _goldAccent,
                            letterSpacing: 1.6,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.groups_outlined,
                          color: _goldAccent,
                          size: 17,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final member in members)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _voidBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: member.id == gang.founderId
                                ? _goldAccent.withValues(alpha: 0.45)
                                : _gothBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              switch (member.sex) {
                                MemberSex.male => Icons.male,
                                MemberSex.female => Icons.female,
                                MemberSex.neutral => Icons.person_outline,
                              },
                              size: 18,
                              color: member.isHand ? _goldAccent : _mutedStone,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.nickname,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    member.isHand
                                        ? s.roleHandSubtitle
                                        : s.roleMemberSubtitle,
                                    style: const TextStyle(
                                      color: _mutedStone,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (member.isHand)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _bloodWine.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: _bloodBorder),
                                ),
                                child: Text(
                                  s.isCs ? 'RUKA' : 'THE HAND',
                                  style: const TextStyle(
                                    color: _goldAccent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ThemePackageCard(
                store: store,
                gang: gang,
                isOwner: isOwner,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _coalSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _bloodWine, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: _bloodWine,
                              size: 17,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              s.isCs ? 'NEBEZPEČNÁ ZÓNA' : 'DANGER ZONE',
                              style: const TextStyle(
                                color: _bloodBorder,
                                letterSpacing: 1.6,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          isOwner
                              ? (s.isCs ? 'VLASTNÍK' : 'OWNER')
                              : (s.isCs ? 'ČLEN' : 'MEMBER'),
                          style: const TextStyle(
                            color: _mutedStone,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _boneText,
                        side: const BorderSide(color: _gothBorder),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: withButtonSound(
                        () => _showLeaveMansionDialog(context, store, gang),
                      ),
                      icon: const Icon(Icons.logout_outlined, size: 17),
                      label: Text(s.leaveMansionBtn),
                    ),
                    if (isOwner) ...[
                      const SizedBox(height: 12),
                      Text(
                        s.isCs
                            ? 'Smazáním Sídla trvale odstraníš celé panství, kroniku, karty v Mešci i všechny členy. Tato akce je nevratná.'
                            : 'Deleting the Mansion permanently removes the household, chronicle, pouch cards, and all members. This cannot be undone.',
                        style: const TextStyle(color: _mutedStone, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      _BloodWineButton(
                        onPressed: () =>
                            _showDeleteGangDialog(context, store, gang),
                        icon: Icons.delete_forever_outlined,
                        label: s.deleteMansionBtn,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLeaveMansionDialog(
    BuildContext context,
    MansionStore store,
    Gang gang,
  ) async {
    final s = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.leaveMansionConfirmTitle),
        content: Text(s.leaveMansionConfirmBody(gang.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.isCs ? 'Zrušit' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.leaveMansionBtn),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = store.leaveGang(gang.id);
      if (ok && context.mounted) {
        if (store.myGangs.isEmpty) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _showDeleteGangDialog(
    BuildContext context,
    MansionStore store,
    Gang gang,
  ) async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (ctx) => _DeleteGangDialog(store: store, gang: gang),
    );
    if (deleted == true && context.mounted) {
      if (store.myGangs.isEmpty) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        Navigator.pop(context);
      }
    }
  }
}

class _DeleteGangDialog extends StatefulWidget {
  const _DeleteGangDialog({required this.store, required this.gang});

  final MansionStore store;
  final Gang gang;

  @override
  State<_DeleteGangDialog> createState() => _DeleteGangDialogState();
}

class _DeleteGangDialogState extends State<_DeleteGangDialog> {
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _confirmController.text.trim() == widget.gang.name.trim();
    return _GothicModalFrame(
      borderColor: _bloodWine,
      borderWidth: 1.6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              _GothicCrest(
                icon: Icons.warning_amber_rounded,
                color: _bloodBorder,
                fillColor: _bloodWine.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 10),
              const Text(
                'KONEČNÉ ROZHODNUTÍ',
                style: TextStyle(
                  color: _bloodBorder,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.of(context).deleteMansionConfirmTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.of(context).isCs
                    ? 'Tato akce trvale smaže „${widget.gang.name}“ včetně všech karet a historie. Pro potvrzení napiš přesný název Sídla:'
                    : 'This permanently deletes "${widget.gang.name}" including all cards and history. Type the exact Mansion name to confirm:',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _mutedStone, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _confirmController,
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              filled: true,
              fillColor: _voidBg,
              labelText: 'Napiš: ${widget.gang.name}',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _voidBg,
                    foregroundColor: _boneText,
                    side: const BorderSide(color: _gothBorder),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    AppStrings.of(context).isCs
                        ? 'Ponechat Sídlo'
                        : 'Keep Mansion',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BloodWineButton(
                  icon: Icons.delete_forever_outlined,
                  label: AppStrings.of(context).isCs
                      ? 'Trvale smazat'
                      : 'Delete Forever',
                  onPressed: matches
                      ? () {
                          final ok = widget.store.deleteGang(
                            widget.gang.id,
                            confirmationName: _confirmController.text,
                          );
                          Navigator.pop(context, ok);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemePackageCard extends StatelessWidget {
  const _ThemePackageCard({
    required this.store,
    required this.gang,
    required this.isOwner,
  });

  final MansionStore store;
  final Gang gang;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final activeTheme = ThemeRegistry.resolve(gang.themeId);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _coalSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gothBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TÉMA / MOTIV SÍDLA',
                style: TextStyle(
                  color: _goldAccent,
                  letterSpacing: 1.6,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isOwner ? 'POUZE RUKA' : 'JEN ČTENÍ',
                style: const TextStyle(color: _mutedStone, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isOwner
                ? 'Vlastník může pro nové období zvolit balíček tématu. Výchozím tématem je Gothic Mansion.'
                : 'Aktivní téma nastavené vlastníkem Sídla.',
            style: const TextStyle(color: _mutedStone, fontSize: 12),
          ),
          const SizedBox(height: 12),
          for (final theme in ThemeRegistry.all)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isOwner
                  ? () => store.updateGangTheme(gang.id, theme.id)
                  : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _voidBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.id == activeTheme.id
                        ? _goldAccent
                        : _gothBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      theme.id == activeTheme.id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: theme.id == activeTheme.id
                          ? _goldAccent
                          : _mutedStone,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            theme.displayName,
                            style: const TextStyle(
                              color: _boneText,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            theme.subtitle,
                            style: const TextStyle(
                              color: _mutedStone,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

