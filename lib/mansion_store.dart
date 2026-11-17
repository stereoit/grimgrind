import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'app_strings.dart';
import 'firebase_gang_repository.dart';
import 'l10n/app_localizations.dart';
import 'models.dart';
import 'theme_package.dart';

class GangWorkspace {
  GangWorkspace({
    required this.gang,
    required this.currentMemberId,
    List<GangMember>? members,
    List<PlayedCard>? playedCards,
    List<ExchangeRequest>? exchangeRequests,
    List<ChronicleEntry>? chronicleEntries,
  }) : members = members ?? [],
       playedCards = playedCards ?? [],
       exchangeRequests = exchangeRequests ?? [],
       chronicleEntries = chronicleEntries ?? [],
       remoteChronicleEntries = [];

  final Gang gang;
  String? currentMemberId;
  final List<GangMember> members;
  final List<PlayedCard> playedCards;
  final List<ExchangeRequest> exchangeRequests;
  final List<ChronicleEntry> chronicleEntries;
  final List<ChronicleEntry> remoteChronicleEntries;
}

class MansionStore extends ChangeNotifier {
  MansionStore({
    DateTime Function()? clock,
    bool seedDemo = false,
    FirebaseGangRepository? gangRepository,
  }) : _clock = clock ?? DateTime.now,
       _gangRepo = gangRepository ?? FirebaseGangRepository() {
    if (seedDemo) {
      _seedSampleMansion();
    }
  }

  final DateTime Function() _clock;
  final FirebaseGangRepository _gangRepo;
  int _idSeq = 100;

  bool hasSeenIntro = false;
  bool isSignedIn = false;
  bool isAnonymousAuth = false;
  String? authUserEmail;
  String? pendingVerificationEmail;
  String? avatarNickname;
  MemberSex avatarSex = MemberSex.male;
  String? pendingInviteCode;
  String? pendingWelcomeMansionName;
  String? lastSyncError;
  bool _isAcceptingPendingInvite = false;
  String? _autoAttemptedInviteCode;

  bool get hasAvatar =>
      avatarNickname != null && avatarNickname!.trim().isNotEmpty;
  bool get isFirebaseReady => _gangRepo.isFirebaseReady;

  final List<GangWorkspace> _workspaces = [];
  String? _activeGangId;
  String? _subscribedGangId;
  StreamSubscription<List<Map<String, dynamic>>>? _membersSub;
  StreamSubscription<List<Map<String, dynamic>>>? _playedCardsSub;
  StreamSubscription<List<Map<String, dynamic>>>? _exchangesSub;
  StreamSubscription<List<Map<String, dynamic>>>? _chronicleSub;

  final List<GangMember> _emptyMembers = [];
  final List<PlayedCard> _emptyPlayedCards = [];
  final List<ExchangeRequest> _emptyExchangeRequests = [];
  final List<ChronicleEntry> _emptyChronicleEntries = [];

  @override
  void dispose() {
    _cancelActiveGangListeners();
    super.dispose();
  }

  GangWorkspace? get _activeWorkspace {
    final id = _activeGangId;
    if (id == null) return null;
    for (final ws in _workspaces) {
      if (ws.gang.id == id) return ws;
    }
    return null;
  }

  AppLocalizations get _l10n => lookupAppLocalizations(
    AppStrings.resolveLocale(
      PlatformDispatcher.instance.locale,
      AppStrings.supportedLocales,
    ),
  );

  List<Gang> get myGangs => _workspaces.map((w) => w.gang).toList();

  Gang? get gang => _activeWorkspace?.gang;

  String? get currentMemberId => _activeWorkspace?.currentMemberId;
  set currentMemberId(String? value) {
    final ws = _activeWorkspace;
    if (ws != null) {
      ws.currentMemberId = value;
    }
  }

  List<GangMember> get members => _activeWorkspace?.members ?? _emptyMembers;
  List<PlayedCard> get playedCards =>
      _activeWorkspace?.playedCards ?? _emptyPlayedCards;
  List<ExchangeRequest> get exchangeRequests =>
      _activeWorkspace?.exchangeRequests ?? _emptyExchangeRequests;
  List<ChronicleEntry> get chronicleEntries =>
      _activeWorkspace?.chronicleEntries ?? _emptyChronicleEntries;

  List<ChoreDefinition> get deck => choreCatalog;

  GameThemePackage get activeTheme => ThemeRegistry.resolve(gang?.themeId);

  GameThemePackage themeForGang(Gang targetGang) =>
      ThemeRegistry.resolve(targetGang.themeId);

  bool get isReady => gang != null && currentMember != null;

  GangMember? get currentMember {
    final id = currentMemberId;
    if (id == null) return null;
    for (final member in members) {
      if (member.id == id) return member;
    }
    return null;
  }

  bool get isCurrentUserHand => currentMember?.isHand ?? false;

  bool isOwnerOf(String gangId) {
    for (final ws in _workspaces) {
      if (ws.gang.id == gangId) {
        final memberId = ws.currentMemberId;
        if (memberId == null) return false;
        return ws.members.any((m) => m.id == memberId && m.isHand);
      }
    }
    return false;
  }

  String? memberNicknameIn(String gangId) {
    for (final ws in _workspaces) {
      if (ws.gang.id == gangId) {
        final memberId = ws.currentMemberId;
        for (final m in ws.members) {
          if (m.id == memberId) return m.nickname;
        }
      }
    }
    return null;
  }

  int memberCountIn(String gangId) {
    for (final ws in _workspaces) {
      if (ws.gang.id == gangId) return ws.members.length;
    }
    return 0;
  }

  String monthKeyFor(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}';

  String get currentMonthKey => monthKeyFor(_clock());

  String get previousMonthKey {
    final now = _clock();
    final prev = DateTime(now.year, now.month - 1, 1);
    return monthKeyFor(prev);
  }

  String _nextId(String prefix) => '$prefix-${++_idSeq}';

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // ---------------------------------------------------------------------------
  // Onboarding, Deep Links & Multi-Gang Lifecycle
  // ---------------------------------------------------------------------------

  void completeIntro() {
    if (hasSeenIntro) return;
    hasSeenIntro = true;
    notifyListeners();
  }

  static String? parseInviteCodeFromUri(Uri uri) {
    final queryCode = uri.queryParameters['code']?.trim();
    if (queryCode != null && queryCode.isNotEmpty) {
      return queryCode.toUpperCase();
    }
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length >= 2 && segments.first == 'join') {
      return segments[1].trim().toUpperCase();
    }
    if (uri.scheme == 'grimgrind' &&
        uri.host == 'join' &&
        segments.isNotEmpty) {
      return segments.first.trim().toUpperCase();
    }
    return null;
  }

  void setPendingInviteCode(String? code) {
    final clean = code?.trim().toUpperCase();
    pendingInviteCode = (clean == null || clean.isEmpty) ? null : clean;
    _autoAttemptedInviteCode = null;
    notifyListeners();
  }

  void clearPendingInviteCode() {
    if (pendingInviteCode == null) return;
    pendingInviteCode = null;
    _autoAttemptedInviteCode = null;
    notifyListeners();
  }

  String? consumePendingWelcomeMansionName() {
    final name = pendingWelcomeMansionName;
    pendingWelcomeMansionName = null;
    return name;
  }

  String _defaultInviteNickname() {
    if (hasAvatar) return avatarNickname!.trim();
    final displayName = _gangRepo.currentUser?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final email = authUserEmail?.trim();
    if (email != null && email.contains('@')) {
      final prefix = email.split('@').first.trim();
      if (prefix.isNotEmpty) return prefix;
    }
    return 'Shadow';
  }

  Future<bool> acceptPendingInviteIfEligible() async {
    final code = pendingInviteCode?.trim().toUpperCase();
    if (code == null || code.isEmpty) return false;
    if (!isSignedIn || pendingVerificationEmail != null) return false;
    if (isReady) return false;
    if (_isAcceptingPendingInvite || _autoAttemptedInviteCode == code) {
      return false;
    }

    _isAcceptingPendingInvite = true;
    _autoAttemptedInviteCode = code;
    try {
      final nickname = _defaultInviteNickname();
      if (!hasAvatar) {
        avatarNickname = nickname;
      }
      final ok = await joinGangByCodeAsync(
        inviteCode: code,
        nickname: nickname,
        sex: avatarSex,
      );
      if (ok) {
        pendingWelcomeMansionName =
            gang?.name ?? _l10n.defaultMansionFallbackName;
        notifyListeners();
      } else {
        hasSeenIntro = true;
        notifyListeners();
      }
      return ok;
    } finally {
      _isAcceptingPendingInvite = false;
    }
  }

  Gang? findGangByInviteCode(String inviteCode) {
    final cleanCode = inviteCode.trim().toUpperCase();
    if (cleanCode.isEmpty) return null;
    for (final ws in _workspaces) {
      if (ws.gang.inviteCode.toUpperCase() == cleanCode) {
        return ws.gang;
      }
    }
    return null;
  }

  bool switchGang(String gangId) {
    if (!_workspaces.any((w) => w.gang.id == gangId)) return false;
    _activeGangId = gangId;
    _attachActiveGangListeners();
    notifyListeners();
    return true;
  }

  String _generateInviteCode(DateTime now) {
    final suffix = 10 + (now.minute + now.second + _idSeq) % 89;
    return 'GRIM-$suffix';
  }

  void createGang({
    required String gangName,
    required String founderNickname,
    MemberSex founderSex = MemberSex.male,
    int coinsPerCzk = 10,
    String themeId = ThemeRegistry.defaultThemeId,
    bool includeStarterFamily = false,
  }) {
    final cleanGang = gangName.trim().isEmpty
        ? _l10n.defaultShadowMansionName
        : gangName.trim();
    final cleanNick = founderNickname.trim().isEmpty
        ? 'Dark Lord'
        : founderNickname.trim();
    final resolvedThemeId = ThemeRegistry.resolve(themeId).id;
    final now = _clock();
    final founder = GangMember(
      id: _nextId('member'),
      nickname: cleanNick,
      isHand: true,
      sex: founderSex,
    );

    final newGang = Gang(
      id: _nextId('gang'),
      name: cleanGang,
      inviteCode: _generateInviteCode(now),
      founderId: founder.id,
      coinsPerCzk: coinsPerCzk.clamp(1, 1000),
      themeId: resolvedThemeId,
    );
    final ws = GangWorkspace(
      gang: newGang,
      currentMemberId: founder.id,
      members: [founder],
    );
    _workspaces.add(ws);
    _activeGangId = newGang.id;
    hasSeenIntro = true;
    isSignedIn = true;
    avatarNickname ??= cleanNick;
    if (avatarNickname != null && avatarNickname!.isEmpty) {
      avatarNickname = cleanNick;
    }

    if (includeStarterFamily) {
      _populateGangWithSampleHistory(founder);
    }
    notifyListeners();
  }

  bool joinGangByCode({
    required String inviteCode,
    required String nickname,
    MemberSex sex = MemberSex.male,
  }) {
    final cleanCode = inviteCode.trim().toUpperCase();
    final cleanNick = nickname.trim().isEmpty ? 'Shadow' : nickname.trim();
    if (cleanCode.isEmpty) return false;

    GangWorkspace? target;
    for (final ws in _workspaces) {
      if (ws.gang.inviteCode.toUpperCase() == cleanCode) {
        target = ws;
        break;
      }
    }

    if (target == null) {
      if (_workspaces.isEmpty) {
        // Allow local/offline joining into a demo mansion when user enters a code.
        _seedSampleMansion(overrideInviteCode: cleanCode);
        target = _activeWorkspace;
      } else {
        return false;
      }
    }

    if (target == null) return false;
    _activeGangId = target.gang.id;

    final existing = target.members.where(
      (m) => m.nickname.toLowerCase() == cleanNick.toLowerCase(),
    );
    if (existing.isNotEmpty) {
      existing.first.sex = sex;
      target.currentMemberId = existing.first.id;
    } else {
      final newcomer = GangMember(
        id: _nextId('member'),
        nickname: cleanNick,
        isHand: false,
        sex: sex,
      );
      target.members.add(newcomer);
      target.currentMemberId = newcomer.id;
    }
    hasSeenIntro = true;
    isSignedIn = true;
    avatarNickname ??= cleanNick;
    pendingInviteCode = null;
    notifyListeners();
    return true;
  }

  String? regenerateInviteCode(String gangId) {
    if (!isOwnerOf(gangId)) return null;
    for (final ws in _workspaces) {
      if (ws.gang.id == gangId) {
        var nextCode = _generateInviteCode(_clock());
        if (nextCode == ws.gang.inviteCode) {
          _idSeq++;
          nextCode = _generateInviteCode(_clock());
        }
        final oldCode = ws.gang.inviteCode;
        ws.gang.inviteCode = nextCode;
        if (isFirebaseReady) {
          unawaited(
            _gangRepo
                .regenerateInviteCode(
                  gangId: gangId,
                  gangName: ws.gang.name,
                  oldCode: oldCode,
                  newCode: nextCode,
                )
                .catchError((_) {}),
          );
        }
        notifyListeners();
        return nextCode;
      }
    }
    return null;
  }

  bool deleteGang(String gangId, {required String confirmationName}) {
    if (!isOwnerOf(gangId)) return false;
    final index = _workspaces.indexWhere((w) => w.gang.id == gangId);
    if (index < 0) return false;
    final target = _workspaces[index];
    if (confirmationName.trim() != target.gang.name.trim()) {
      return false;
    }
    _workspaces.removeAt(index);
    if (_activeGangId == gangId) {
      _activeGangId = _workspaces.isEmpty ? null : _workspaces.first.gang.id;
      _attachActiveGangListeners();
    }
    if (isFirebaseReady) {
      unawaited(_gangRepo.deleteGang(gangId: gangId).catchError((_) {}));
    }
    notifyListeners();
    return true;
  }

  List<GangMember> membersOf(String gangId) {
    for (final ws in _workspaces) {
      if (ws.gang.id == gangId) {
        return List.unmodifiable(ws.members);
      }
    }
    return const [];
  }

  bool leaveGang(String gangId) {
    final index = _workspaces.indexWhere((w) => w.gang.id == gangId);
    if (index < 0) return false;
    final target = _workspaces[index];
    final memberId = target.currentMemberId;
    _workspaces.removeAt(index);
    if (_activeGangId == gangId) {
      _activeGangId = _workspaces.isEmpty ? null : _workspaces.first.gang.id;
      _attachActiveGangListeners();
    }
    if (isFirebaseReady && memberId != null) {
      unawaited(
        _gangRepo
            .leaveGang(gangId: gangId, memberId: memberId)
            .catchError((_) {}),
      );
    }
    notifyListeners();
    return true;
  }

  void startSampleMansion() {
    _seedSampleMansion();
    isSignedIn = true;
    avatarNickname ??= currentMember?.nickname ?? 'Dark Lord';
    notifyListeners();
  }

  Future<Map<String, dynamic>?> lookupRemoteInvite(String inviteCode) async {
    if (!isFirebaseReady) return null;
    try {
      return await _gangRepo.lookupInvite(inviteCode);
    } catch (_) {
      return null;
    }
  }

  Future<bool> signInWithEmailAsync({
    required String email,
    required String password,
  }) async {
    lastSyncError = null;
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.isEmpty) {
      lastSyncError = 'Zadej e-mail a heslo.';
      return false;
    }
    if (!isFirebaseReady) {
      isSignedIn = true;
      isAnonymousAuth = false;
      authUserEmail = cleanEmail;
      notifyListeners();
      return true;
    }
    try {
      final cred = await _gangRepo.signInWithEmail(
        email: cleanEmail,
        password: password,
      );
      isSignedIn = true;
      isAnonymousAuth = cred?.user?.isAnonymous ?? false;
      authUserEmail = cred?.user?.email ?? cleanEmail;
      await syncFromFirebase();
      notifyListeners();
      return true;
    } catch (e) {
      lastSyncError = _l10n.errorSignInFailed('$e');
      return false;
    }
  }

  Future<bool> registerWithEmailAsync({
    required String email,
    required String password,
  }) async {
    lastSyncError = null;
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.length < 6) {
      lastSyncError = _l10n.errorInvalidEmailPassword;
      return false;
    }
    if (!isFirebaseReady) {
      isSignedIn = true;
      isAnonymousAuth = false;
      authUserEmail = cleanEmail;
      pendingVerificationEmail = cleanEmail;
      notifyListeners();
      return true;
    }
    try {
      final cred = await _gangRepo.registerWithEmail(
        email: cleanEmail,
        password: password,
      );
      isSignedIn = true;
      isAnonymousAuth = cred?.user?.isAnonymous ?? false;
      authUserEmail = cred?.user?.email ?? cleanEmail;
      pendingVerificationEmail = authUserEmail;
      await syncFromFirebase();
      notifyListeners();
      return true;
    } catch (e) {
      lastSyncError = _l10n.errorRegistrationFailed('$e');
      return false;
    }
  }

  void acknowledgeVerificationEmail() {
    if (pendingVerificationEmail == null) return;
    pendingVerificationEmail = null;
    notifyListeners();
  }

  Future<bool> signInWithGoogleAsync() async {
    lastSyncError = null;
    if (!isFirebaseReady) {
      isSignedIn = true;
      isAnonymousAuth = false;
      authUserEmail = 'google@demo.local';
      notifyListeners();
      return true;
    }
    try {
      final cred = await _gangRepo.signInWithGoogle();
      if (cred?.user == null) {
        lastSyncError = _l10n.errorGoogleSignInCancelled;
        return false;
      }
      isSignedIn = true;
      isAnonymousAuth = cred!.user!.isAnonymous;
      authUserEmail = cred.user!.email;
      await syncFromFirebase();
      notifyListeners();
      return true;
    } catch (e) {
      lastSyncError = _l10n.errorGoogleSignInFailed('$e');
      return false;
    }
  }

  Future<bool> continueAnonymouslyAsync() async {
    lastSyncError = null;
    if (!isFirebaseReady) {
      isSignedIn = true;
      isAnonymousAuth = true;
      authUserEmail = null;
      notifyListeners();
      return true;
    }
    try {
      final user = await _gangRepo.ensureSignedIn();
      if (user == null) {
        lastSyncError = _l10n.errorAnonymousSignInFailed;
        return false;
      }
      isSignedIn = true;
      isAnonymousAuth = user.isAnonymous;
      authUserEmail = user.email;
      await syncFromFirebase();
      notifyListeners();
      return true;
    } catch (e) {
      lastSyncError = _l10n.errorAnonymousSignInException('$e');
      return false;
    }
  }

  void saveAvatar({required String nickname, required MemberSex sex}) {
    avatarNickname = nickname.trim().isEmpty ? 'Dark Lord' : nickname.trim();
    avatarSex = sex;
    notifyListeners();
  }

  Future<void> signOutAsync() async {
    lastSyncError = null;
    try {
      await _gangRepo.signOut();
    } catch (_) {
      // Clear local session state even if remote sign-out fails offline.
    }
    isSignedIn = false;
    isAnonymousAuth = false;
    authUserEmail = null;
    pendingVerificationEmail = null;
    avatarNickname = null;
    avatarSex = MemberSex.male;
    pendingInviteCode = null;
    pendingWelcomeMansionName = null;
    _autoAttemptedInviteCode = null;
    _cancelActiveGangListeners();
    _workspaces.clear();
    _activeGangId = null;
    notifyListeners();
  }

  Future<void> syncFromFirebase() async {
    if (!isFirebaseReady) return;
    try {
      final user = _gangRepo.currentUser;
      if (user == null) return;
      isSignedIn = true;
      isAnonymousAuth = user.isAnonymous;
      authUserEmail = user.email;
      final gangIds = await _gangRepo.fetchUserGangIds();
      for (final gangId in gangIds) {
        final gangData = await _gangRepo.fetchGang(gangId);
        if (gangData == null) continue;
        final membersData = await _gangRepo.fetchGangMembers(gangId);
        _upsertRemoteWorkspace(
          gangId: gangId,
          gangData: gangData,
          membersData: membersData,
          currentUid: user.uid,
        );
      }
      if (_activeGangId == null && _workspaces.isNotEmpty) {
        _activeGangId = _workspaces.first.gang.id;
      }
      _attachActiveGangListeners();
      if (_workspaces.isNotEmpty) {
        hasSeenIntro = true;
        if (!hasAvatar && currentMember != null) {
          avatarNickname = currentMember!.nickname;
          avatarSex = currentMember!.sex;
        }
      }
      notifyListeners();
      await acceptPendingInviteIfEligible();
    } catch (_) {
      // Gracefully ignore startup sync errors when offline.
    }
  }

  Future<bool> createGangAsync({
    required String gangName,
    required String founderNickname,
    MemberSex founderSex = MemberSex.male,
    int coinsPerCzk = 10,
    String themeId = ThemeRegistry.defaultThemeId,
    bool includeStarterFamily = false,
  }) async {
    lastSyncError = null;
    if (!isSignedIn) {
      lastSyncError = _l10n.errorSignInFirst;
      return false;
    }
    final cleanGang = gangName.trim().isEmpty
        ? _l10n.defaultShadowMansionName
        : gangName.trim();
    final cleanNick = founderNickname.trim().isEmpty
        ? 'Dark Lord'
        : founderNickname.trim();
    final resolvedThemeId = ThemeRegistry.resolve(themeId).id;
    final clampedRate = coinsPerCzk.clamp(1, 1000);

    if (!isFirebaseReady) {
      createGang(
        gangName: cleanGang,
        founderNickname: cleanNick,
        founderSex: founderSex,
        coinsPerCzk: clampedRate,
        themeId: resolvedThemeId,
        includeStarterFamily: includeStarterFamily,
      );
      return true;
    }

    try {
      final user = _gangRepo.currentUser;
      if (user == null || user.isAnonymous) {
        lastSyncError = _l10n.errorAccountRequiredToCreate;
        return false;
      }
      final inviteCode = _generateInviteCode(_clock());
      final gangId = await _gangRepo.createGang(
        gangName: cleanGang,
        founderNickname: cleanNick,
        founderSex: founderSex,
        inviteCode: inviteCode,
        coinsPerCzk: clampedRate,
        themeId: resolvedThemeId,
      );
      if (gangId == null) {
        lastSyncError = _l10n.errorCreateMansionServer;
        return false;
      }

      final founder = GangMember(
        id: user.uid,
        nickname: cleanNick,
        isHand: true,
        sex: founderSex,
      );
      final newGang = Gang(
        id: gangId,
        name: cleanGang,
        inviteCode: inviteCode,
        founderId: user.uid,
        coinsPerCzk: clampedRate,
        themeId: resolvedThemeId,
      );
      final ws = GangWorkspace(
        gang: newGang,
        currentMemberId: founder.id,
        members: [founder],
      );
      _workspaces.add(ws);
      _activeGangId = newGang.id;
      hasSeenIntro = true;
      _attachActiveGangListeners();

      if (includeStarterFamily) {
        _populateGangWithSampleHistory(founder);
      }
      notifyListeners();
      return true;
    } catch (e) {
      lastSyncError = _l10n.errorCreateMansionException('$e');
      return false;
    }
  }

  Future<bool> joinGangByCodeAsync({
    required String inviteCode,
    required String nickname,
    MemberSex sex = MemberSex.male,
  }) async {
    lastSyncError = null;
    if (!isSignedIn) {
      lastSyncError = _l10n.errorSignInFirst;
      return false;
    }
    final cleanCode = inviteCode.trim().toUpperCase();
    final cleanNick = nickname.trim().isEmpty ? 'Shadow' : nickname.trim();
    if (cleanCode.isEmpty) {
      lastSyncError = _l10n.errorEnterInviteCode;
      return false;
    }

    // 1. Check local workspaces first.
    for (final ws in _workspaces) {
      if (ws.gang.inviteCode.toUpperCase() == cleanCode) {
        return joinGangByCode(
          inviteCode: cleanCode,
          nickname: cleanNick,
          sex: sex,
        );
      }
    }

    // 2. If Firebase is not configured (e.g. unit tests), use local fallback.
    if (!isFirebaseReady) {
      return joinGangByCode(
        inviteCode: cleanCode,
        nickname: cleanNick,
        sex: sex,
      );
    }

    // 3. Look up and join via Firestore.
    try {
      final user = _gangRepo.currentUser;
      if (user == null || user.isAnonymous) {
        lastSyncError = _l10n.errorAccountRequiredToJoin;
        return false;
      }

      final gangId = await _gangRepo.acceptInvite(
        inviteCode: cleanCode,
        nickname: cleanNick,
        sex: sex,
      );
      if (gangId == null) {
        lastSyncError = _l10n.errorInviteNotFound(cleanCode);
        return false;
      }

      final gangData = await _gangRepo.fetchGang(gangId);
      if (gangData == null) {
        lastSyncError = _l10n.errorLoadMansionFailed(cleanCode);
        return false;
      }
      final membersData = await _gangRepo.fetchGangMembers(gangId);
      _upsertRemoteWorkspace(
        gangId: gangId,
        gangData: gangData,
        membersData: membersData,
        currentUid: user.uid,
      );
      _activeGangId = gangId;
      hasSeenIntro = true;
      pendingInviteCode = null;
      _attachActiveGangListeners();
      notifyListeners();
      return true;
    } catch (e) {
      lastSyncError = _l10n.errorJoinMansionException('$e');
      return false;
    }
  }

  void _upsertRemoteWorkspace({
    required String gangId,
    required Map<String, dynamic> gangData,
    required List<Map<String, dynamic>> membersData,
    required String currentUid,
  }) {
    final gang = Gang(
      id: gangId,
      name: (gangData['name'] as String?) ?? _l10n.defaultMansionFallbackName,
      inviteCode: (gangData['inviteCode'] as String?) ?? '',
      founderId: (gangData['founderId'] as String?) ?? '',
      coinsPerCzk: (gangData['coinsPerCzk'] as num?)?.toInt() ?? 10,
      themeId: ThemeRegistry.resolve(gangData['themeId'] as String?).id,
    );

    final members = _parseRemoteMembers(membersData);

    final existingIdx = _workspaces.indexWhere((w) => w.gang.id == gangId);
    if (existingIdx >= 0) {
      final existing = _workspaces[existingIdx];
      existing.gang.name = gang.name;
      existing.gang.inviteCode = gang.inviteCode;
      existing.gang.coinsPerCzk = gang.coinsPerCzk;
      existing.gang.themeId = gang.themeId;
      existing.members
        ..clear()
        ..addAll(members);
      existing.currentMemberId = currentUid;
    } else {
      _workspaces.add(
        GangWorkspace(
          gang: gang,
          currentMemberId: currentUid,
          members: members,
        ),
      );
    }
  }

  List<GangMember> _parseRemoteMembers(List<Map<String, dynamic>> membersData) {
    return membersData.map((m) {
      final sexName = m['sex'] as String?;
      final sex = MemberSex.values.firstWhere(
        (s) => s.name == sexName,
        orElse: () => MemberSex.male,
      );
      final rawFavorites = m['favoriteChoreIds'];
      final favoriteChoreIds = rawFavorites is Iterable
          ? rawFavorites.whereType<String>().toSet()
          : <String>{};
      return GangMember(
        id: (m['id'] as String?) ?? '',
        nickname: (m['nickname'] as String?) ?? 'Shadow',
        isHand: (m['isHand'] as bool?) ?? false,
        sex: sex,
        heatPeakDays: (m['heatPeakDays'] as num?)?.toInt() ?? 0,
        lastActiveDay: _parseDateTime(m['lastActiveDay']),
        favoriteChoreIds: favoriteChoreIds,
      );
    }).toList();
  }

  DateTime? _parseDateTime(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  ChoreDefinition _resolveChore(Map<String, dynamic> data) {
    final choreId = data['choreId'] as String?;
    if (choreId != null) {
      for (final c in choreCatalog) {
        if (c.id == choreId) return c;
      }
    }
    final difficultyName = data['choreDifficulty'] as String?;
    final difficulty = ChoreDifficulty.values.firstWhere(
      (d) => d.name == difficultyName,
      orElse: () => ChoreDifficulty.easy,
    );
    return ChoreDefinition(
      id: choreId ?? 'custom',
      title: (data['choreTitle'] as String?) ?? 'Chore',
      symbol: (data['choreSymbol'] as String?) ?? '✦',
      baseCoins: (data['choreBaseCoins'] as num?)?.toInt() ?? 10,
      difficulty: difficulty,
      minutes: (data['choreMinutes'] as num?)?.toInt() ?? 10,
    );
  }

  GangWorkspace? _workspaceById(String gangId) {
    for (final ws in _workspaces) {
      if (ws.gang.id == gangId) return ws;
    }
    return null;
  }

  void _attachActiveGangListeners() {
    if (!isFirebaseReady || !isSignedIn) {
      _cancelActiveGangListeners();
      return;
    }
    final gangId = _activeGangId;
    if (gangId == null) {
      _cancelActiveGangListeners();
      return;
    }
    if (_subscribedGangId == gangId) return;

    _cancelActiveGangListeners();
    _subscribedGangId = gangId;

    _membersSub = _gangRepo.watchGangMembers(gangId).listen(
      (data) => _applyRemoteMembers(gangId, data),
      onError: (_) {},
    );
    _playedCardsSub = _gangRepo.watchPlayedCards(gangId).listen(
      (data) => _applyRemotePlayedCards(gangId, data),
      onError: (_) {},
    );
    _exchangesSub = _gangRepo.watchExchanges(gangId).listen(
      (data) => _applyRemoteExchanges(gangId, data),
      onError: (_) {},
    );
    _chronicleSub = _gangRepo.watchChronicle(gangId).listen(
      (data) => _applyRemoteChronicle(gangId, data),
      onError: (_) {},
    );
  }

  void _cancelActiveGangListeners() {
    _subscribedGangId = null;
    _membersSub?.cancel();
    _membersSub = null;
    _playedCardsSub?.cancel();
    _playedCardsSub = null;
    _exchangesSub?.cancel();
    _exchangesSub = null;
    _chronicleSub?.cancel();
    _chronicleSub = null;
  }

  void _applyRemoteMembers(
    String gangId,
    List<Map<String, dynamic>> membersData,
  ) {
    final ws = _workspaceById(gangId);
    if (ws == null) return;
    ws.members
      ..clear()
      ..addAll(_parseRemoteMembers(membersData));
    notifyListeners();
  }

  void _applyRemotePlayedCards(
    String gangId,
    List<Map<String, dynamic>> cardsData,
  ) {
    final ws = _workspaceById(gangId);
    if (ws == null) return;

    final parsed = cardsData.map((d) {
      final playedAt = _parseDateTime(d['playedAt']) ?? _clock();
      final levelName = d['levelAtPlay'] as String?;
      final level = MonthlyLevel.values.firstWhere(
        (l) => l.name == levelName,
        orElse: () => MonthlyLevel.awakened,
      );
      final heatName = d['heatAtPlay'] as String?;
      final heat = HeatLevel.values.firstWhere(
        (h) => h.name == heatName,
        orElse: () => HeatLevel.coldAsh,
      );
      final statusName = d['status'] as String?;
      final status = PlayedCardStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => PlayedCardStatus.inBank,
      );
      return PlayedCard(
        id: (d['id'] as String?) ?? '',
        chore: _resolveChore(d),
        memberId: (d['memberId'] as String?) ?? '',
        memberNickname: (d['memberNickname'] as String?) ?? 'Shadow',
        coinsAwarded: (d['coinsAwarded'] as num?)?.toInt() ?? 0,
        playedAt: playedAt,
        monthKey: (d['monthKey'] as String?) ?? monthKeyFor(playedAt),
        levelAtPlay: level,
        heatAtPlay: heat,
        status: status,
        exchangeId: d['exchangeId'] as String?,
        exchangedAt: _parseDateTime(d['exchangedAt']),
      );
    }).toList();

    ws.playedCards
      ..clear()
      ..addAll(parsed);
    _rebuildChronicleEntries(ws);
    notifyListeners();
  }

  void _applyRemoteExchanges(
    String gangId,
    List<Map<String, dynamic>> exchangesData,
  ) {
    final ws = _workspaceById(gangId);
    if (ws == null) return;

    final parsed = exchangesData.map((d) {
      final requestedAt = _parseDateTime(d['requestedAt']) ?? _clock();
      final statusName = d['status'] as String?;
      final status = ExchangeStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => ExchangeStatus.pending,
      );
      final rawCardIds = d['cardIds'];
      final cardIds = rawCardIds is Iterable
          ? rawCardIds.whereType<String>().toList()
          : <String>[];
      return ExchangeRequest(
        id: (d['id'] as String?) ?? '',
        memberId: (d['memberId'] as String?) ?? '',
        memberNickname: (d['memberNickname'] as String?) ?? 'Shadow',
        cardIds: cardIds,
        totalCoins: (d['totalCoins'] as num?)?.toInt() ?? 0,
        coinsPerCzk: (d['coinsPerCzk'] as num?)?.toInt() ?? ws.gang.coinsPerCzk,
        requestedAt: requestedAt,
        monthKey: (d['monthKey'] as String?) ?? monthKeyFor(requestedAt),
        isAutoMonthEnd: (d['isAutoMonthEnd'] as bool?) ?? false,
        status: status,
        approvedAt: _parseDateTime(d['approvedAt']),
        approvedByNickname: d['approvedByNickname'] as String?,
      );
    }).toList();

    ws.exchangeRequests
      ..clear()
      ..addAll(parsed);
    notifyListeners();
  }

  void _applyRemoteChronicle(
    String gangId,
    List<Map<String, dynamic>> chronicleData,
  ) {
    final ws = _workspaceById(gangId);
    if (ws == null) return;

    final parsed = chronicleData.map((d) {
      final createdAt = _parseDateTime(d['createdAt']) ?? _clock();
      final typeName = d['type'] as String?;
      final type = ChronicleEntryType.values.firstWhere(
        (t) => t.name == typeName,
        orElse: () => ChronicleEntryType.cardPlayed,
      );
      final levelName = d['levelAtEvent'] as String?;
      final level = levelName == null
          ? null
          : MonthlyLevel.values.cast<MonthlyLevel?>().firstWhere(
              (l) => l?.name == levelName,
              orElse: () => null,
            );
      final heatName = d['heatAtEvent'] as String?;
      final heat = heatName == null
          ? null
          : HeatLevel.values.cast<HeatLevel?>().firstWhere(
              (h) => h?.name == heatName,
              orElse: () => null,
            );
      return ChronicleEntry(
        id: (d['id'] as String?) ?? '',
        type: type,
        actorNickname: (d['actorNickname'] as String?) ?? 'Shadow',
        title: (d['title'] as String?) ?? '',
        message: (d['message'] as String?) ?? '',
        createdAt: createdAt,
        monthKey: (d['monthKey'] as String?) ?? monthKeyFor(createdAt),
        choreId: d['choreId'] as String?,
        symbol: d['symbol'] as String?,
        coins: (d['coins'] as num?)?.toInt(),
        czkAmount: (d['czkAmount'] as num?)?.toInt(),
        cardCount: (d['cardCount'] as num?)?.toInt(),
        winnerNickname: d['winnerNickname'] as String?,
        levelAtEvent: level,
        heatAtEvent: heat,
      );
    }).toList();

    ws.remoteChronicleEntries
      ..clear()
      ..addAll(parsed);
    _rebuildChronicleEntries(ws);
    notifyListeners();
  }

  void _rebuildChronicleEntries(GangWorkspace ws) {
    final byId = <String, ChronicleEntry>{
      for (final entry in ws.remoteChronicleEntries) entry.id: entry,
    };

    for (final card in ws.playedCards) {
      final entryId = 'card_${card.id}';
      if (!byId.containsKey(entryId)) {
        final member = ws.members
            .where((m) => m.id == card.memberId)
            .cast<GangMember?>()
            .firstWhere((_) => true, orElse: () => null);
        final sex = member?.sex ?? MemberSex.male;
        byId[entryId] = ChronicleEntry(
          id: entryId,
          type: ChronicleEntryType.cardPlayed,
          actorNickname: card.memberNickname,
          title: card.chore.title,
          message:
              '${sex.playedVerb} kartu „${card.chore.title}“ a ${sex.storedVerb} ${card.coinsAwarded} Coinů do Banku.',
          createdAt: card.playedAt,
          monthKey: card.monthKey,
          choreId: card.chore.id,
          symbol: card.chore.symbol,
          coins: card.coinsAwarded,
          levelAtEvent: card.levelAtPlay,
          heatAtEvent: card.heatAtPlay,
        );
      }
    }

    final merged = byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    ws.chronicleEntries
      ..clear()
      ..addAll(merged);
  }

  void addMember(
    String nickname, {
    bool isHand = false,
    MemberSex sex = MemberSex.male,
  }) {
    final clean = nickname.trim();
    if (clean.isEmpty || gang == null) return;
    members.add(
      GangMember(
        id: _nextId('member'),
        nickname: clean,
        isHand: isHand,
        sex: sex,
      ),
    );
    notifyListeners();
  }

  void switchActiveMember(String memberId) {
    if (!members.any((m) => m.id == memberId)) return;
    currentMemberId = memberId;
    notifyListeners();
  }

  void renameCurrentMember(String value) {
    final member = currentMember;
    final clean = value.trim();
    if (member == null || clean.isEmpty || clean == member.nickname) return;
    member.nickname = clean;
    for (final card in playedCards.where((c) => c.memberId == member.id)) {
      card.memberNickname = clean;
    }
    for (final req in exchangeRequests.where((r) => r.memberId == member.id)) {
      req.memberNickname = clean;
    }
    notifyListeners();
  }

  void updateCurrentAvatar({
    required String nickname,
    required MemberSex sex,
  }) {
    final clean = nickname.trim();
    if (clean.isNotEmpty) {
      avatarNickname = clean;
    }
    avatarSex = sex;
    final member = currentMember;
    if (member != null) {
      member.sex = sex;
      if (clean.isNotEmpty && clean != member.nickname) {
        renameCurrentMember(clean);
        return;
      }
    }
    notifyListeners();
  }

  void updateCoinsPerCzk(int coinsPerCzk) {
    if (!isCurrentUserHand || gang == null) return;
    gang!.coinsPerCzk = coinsPerCzk.clamp(1, 1000);
    notifyListeners();
  }

  /// Allows the Gang owner (Hand) to set the active theme package.
  bool updateGangTheme(String gangId, String themeId) {
    if (!isOwnerOf(gangId) || !ThemeRegistry.contains(themeId)) {
      return false;
    }
    for (final ws in _workspaces) {
      if (ws.gang.id == gangId) {
        if (ws.gang.themeId == themeId) return true;
        ws.gang.themeId = themeId;
        if (isFirebaseReady) {
          unawaited(
            _gangRepo
                .updateGangTheme(gangId: gangId, themeId: themeId)
                .catchError((_) {}),
          );
        }
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  bool isFavoriteChore(String choreId) {
    final member = currentMember;
    if (member == null) return false;
    return member.favoriteChoreIds.contains(choreId);
  }

  void toggleFavoriteChore(String choreId) {
    final member = currentMember;
    final currentGang = gang;
    if (member == null || currentGang == null) return;
    if (!member.favoriteChoreIds.add(choreId)) {
      member.favoriteChoreIds.remove(choreId);
    }
    if (isFirebaseReady) {
      unawaited(
        _gangRepo
            .updateFavoriteChores(
              gangId: currentGang.id,
              favoriteChoreIds: member.favoriteChoreIds.toList(),
            )
            .catchError((_) {}),
      );
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Monthly Level & Cooling Heat calculations
  // ---------------------------------------------------------------------------

  int playedCardCountInMonth(String memberId, String monthKey) => playedCards
      .where(
        (c) =>
            c.memberId == memberId &&
            c.monthKey == monthKey &&
            c.status != PlayedCardStatus.rejected,
      )
      .length;

  MonthlyLevel monthlyLevelFor(String memberId, {String? monthKey}) {
    final key = monthKey ?? currentMonthKey;
    return MonthlyLevelData.fromCardCount(
      playedCardCountInMonth(memberId, key),
    );
  }

  HeatLevel heatLevelFor(GangMember member, {DateTime? at}) {
    final last = member.lastActiveDay;
    if (last == null || member.heatPeakDays <= 0) {
      return HeatLevel.coldAsh;
    }
    final nowDay = _dateOnly(at ?? _clock());
    final gap = nowDay.difference(_dateOnly(last)).inDays;

    HeatLevel rawHeat;
    if (member.heatPeakDays >= 7) {
      rawHeat = HeatLevel.hellfire;
    } else if (member.heatPeakDays >= 4) {
      rawHeat = HeatLevel.blazingForge;
    } else if (member.heatPeakDays >= 2) {
      rawHeat = HeatLevel.glowingEmbers;
    } else {
      rawHeat = HeatLevel.coldAsh;
    }

    if (gap <= 0) return rawHeat;

    if (rawHeat == HeatLevel.hellfire) {
      if (gap <= 1) return HeatLevel.hellfire;
      if (gap <= 3) return HeatLevel.blazingForge;
      return HeatLevel.coldAsh;
    }

    if (gap <= 3) return rawHeat;
    return HeatLevel.coldAsh;
  }

  int streakDaysFor(GangMember member, {DateTime? at}) {
    final heat = heatLevelFor(member, at: at);
    if (heat == HeatLevel.coldAsh) {
      final last = member.lastActiveDay;
      if (last == null) return 0;
      final gap = _dateOnly(at ?? _clock()).difference(_dateOnly(last)).inDays;
      return gap <= 3 ? member.heatPeakDays : 0;
    }
    return member.heatPeakDays;
  }

  int effectiveCoinsFor(ChoreDefinition chore, GangMember member) {
    final level = monthlyLevelFor(member.id);
    final heat = heatLevelFor(member);
    final multiplier = 1.0 + level.bonusRate + heat.bonusRate;
    return (chore.baseCoins * multiplier).round();
  }

  int czkForCoins(int coins) {
    final rate = gang?.coinsPerCzk ?? 10;
    return (coins / rate).round();
  }

  // ---------------------------------------------------------------------------
  // Playing Cards, Bank, Exchange Requests & Month Closing
  // ---------------------------------------------------------------------------

  PlayedCard? playCard(ChoreDefinition chore) {
    final member = currentMember;
    final activeGang = gang;
    if (member == null || activeGang == null) return null;

    final now = _clock();
    final coins = effectiveCoinsFor(chore, member);
    final level = monthlyLevelFor(member.id);
    final heat = heatLevelFor(member, at: now);
    final cardId = isFirebaseReady
        ? '${now.microsecondsSinceEpoch}_${member.id}_${_idSeq++}'
        : _nextId('card');

    final played = PlayedCard(
      id: cardId,
      chore: chore,
      memberId: member.id,
      memberNickname: member.nickname,
      coinsAwarded: coins,
      playedAt: now,
      monthKey: monthKeyFor(now),
      levelAtPlay: level,
      heatAtPlay: heat,
      status: PlayedCardStatus.inBank,
    );
    playedCards.insert(0, played);
    _recordActivityForHeat(member, now);

    final entry = ChronicleEntry(
      id: 'card_${played.id}',
      type: ChronicleEntryType.cardPlayed,
      actorNickname: member.nickname,
      title: chore.title,
      message:
          '${member.sex.playedVerb} kartu „${chore.title}“ a ${member.sex.storedVerb} $coins Coinů do Banku.',
      createdAt: now,
      monthKey: played.monthKey,
      choreId: chore.id,
      symbol: chore.symbol,
      coins: coins,
      levelAtEvent: monthlyLevelFor(member.id),
      heatAtEvent: heatLevelFor(member, at: now),
    );
    chronicleEntries.insert(0, entry);

    if (isFirebaseReady && isSignedIn) {
      unawaited(
        _gangRepo
            .recordPlayedCard(
              gangId: activeGang.id,
              card: played,
              memberSex: member.sex,
              heatPeakDays: member.heatPeakDays,
              lastActiveDay: member.lastActiveDay,
              chronicleEntry: entry,
            )
            .catchError((_) {}),
      );
    }

    notifyListeners();
    return played;
  }

  void _recordActivityForHeat(GangMember member, DateTime at) {
    final today = _dateOnly(at);
    final last = member.lastActiveDay;
    if (last == null) {
      member
        ..heatPeakDays = 1
        ..lastActiveDay = today;
      return;
    }

    final gap = today.difference(_dateOnly(last)).inDays;
    if (gap <= 0) {
      return;
    }

    final currentHeat = heatLevelFor(member, at: at);
    if (currentHeat == HeatLevel.coldAsh) {
      member.heatPeakDays = gap <= 3 ? member.heatPeakDays + 1 : 1;
    } else if (member.heatPeakDays >= 7 && gap >= 2 && gap <= 3) {
      // Dropped from Hellfire to Blazing Forge; resume progression from Forge tier.
      member.heatPeakDays = 5;
    } else {
      member.heatPeakDays += 1;
    }
    member.lastActiveDay = today;
  }

  List<PlayedCard> bankCardsFor(String memberId) => playedCards
      .where(
        (c) => c.memberId == memberId && c.status == PlayedCardStatus.inBank,
      )
      .toList();

  List<PlayedCard> pendingCardsFor(String memberId) => playedCards
      .where(
        (c) =>
            c.memberId == memberId &&
            c.status == PlayedCardStatus.pendingExchange,
      )
      .toList();

  int bankCoinsFor(String memberId) =>
      bankCardsFor(memberId).fold(0, (sum, c) => sum + c.coinsAwarded);

  List<ExchangeRequest> get pendingExchanges =>
      exchangeRequests
          .where((r) => r.status == ExchangeStatus.pending)
          .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

  ExchangeRequest? requestExchange({
    String? memberId,
    bool isAutoMonthEnd = false,
  }) {
    final targetId = memberId ?? currentMemberId;
    if (targetId == null || gang == null) return null;

    GangMember? targetMember;
    for (final m in members) {
      if (m.id == targetId) {
        targetMember = m;
        break;
      }
    }
    if (targetMember == null) return null;

    final cards = bankCardsFor(targetId);
    if (cards.isEmpty) return null;

    final now = _clock();
    final totalCoins = cards.fold(0, (sum, c) => sum + c.coinsAwarded);
    final reqId = isFirebaseReady
        ? '${now.microsecondsSinceEpoch}_${targetMember.id}_${_idSeq++}'
        : _nextId('ex');
    final req = ExchangeRequest(
      id: reqId,
      memberId: targetMember.id,
      memberNickname: targetMember.nickname,
      cardIds: cards.map((c) => c.id).toList(),
      totalCoins: totalCoins,
      coinsPerCzk: gang!.coinsPerCzk,
      requestedAt: now,
      monthKey: cards.first.monthKey,
      isAutoMonthEnd: isAutoMonthEnd,
    );

    for (final c in cards) {
      c
        ..status = PlayedCardStatus.pendingExchange
        ..exchangeId = req.id;
    }
    exchangeRequests.add(req);
    if (isFirebaseReady && isSignedIn && gang != null) {
      unawaited(
        _gangRepo
            .createExchangeRequest(gangId: gang!.id, request: req)
            .catchError((_) {}),
      );
    }
    notifyListeners();
    return req;
  }

  bool rejectCardInRequest(String requestId, String cardId) {
    if (!isCurrentUserHand) return false;
    final reqIndex = exchangeRequests.indexWhere((r) => r.id == requestId);
    if (reqIndex < 0) return false;
    final req = exchangeRequests[reqIndex];
    if (req.status != ExchangeStatus.pending) return false;

    final cardIndex = playedCards.indexWhere((c) => c.id == cardId);
    if (cardIndex < 0) return false;
    final card = playedCards[cardIndex];
    if (card.exchangeId != req.id) return false;

    card.status = PlayedCardStatus.rejected;
    req.cardIds.remove(cardId);
    req.totalCoins = req.cardIds.fold(0, (sum, id) {
      final found = playedCards.firstWhere((c) => c.id == id);
      return sum + found.coinsAwarded;
    });

    if (req.cardIds.isEmpty) {
      exchangeRequests.removeAt(reqIndex);
    }
    if (isFirebaseReady && isSignedIn && gang != null) {
      unawaited(
        _gangRepo
            .rejectCardInExchange(gangId: gang!.id, cardId: cardId)
            .catchError((_) {}),
      );
    }
    notifyListeners();
    return true;
  }

  bool approveExchange(String requestId) {
    final hand = currentMember;
    if (hand == null || !hand.isHand) return false;

    ExchangeRequest? req;
    for (final r in exchangeRequests) {
      if (r.id == requestId) {
        req = r;
        break;
      }
    }
    if (req == null || req.status != ExchangeStatus.pending) return false;

    final now = _clock();
    final approvedCards = playedCards
        .where(
          (c) =>
              req!.cardIds.contains(c.id) &&
              c.status == PlayedCardStatus.pendingExchange,
        )
        .toList();

    for (final c in approvedCards) {
      c
        ..status = PlayedCardStatus.exchanged
        ..exchangedAt = now;
    }

    req
      ..status = ExchangeStatus.approved
      ..approvedAt = now
      ..approvedByNickname = hand.nickname
      ..totalCoins = approvedCards.fold(0, (sum, c) => sum + c.coinsAwarded);

    final requester = members
        .where((m) => m.id == req!.memberId)
        .cast<GangMember?>()
        .firstWhere((_) => true, orElse: () => null);
    final exchangedVerb = requester?.sex.exchangedVerb ?? 'směnili';

    final entry = ChronicleEntry(
      id: 'exchange_${req.id}',
      type: ChronicleEntryType.exchangeApproved,
      actorNickname: req.memberNickname,
      title: 'Směna schválena Rukou',
      message:
          '${req.memberNickname} $exchangedVerb ${approvedCards.length} karet za ${req.totalCoins} Coinů (${req.czkAmount} Kč).',
      createdAt: now,
      monthKey: req.monthKey,
      symbol: '☞',
      coins: req.totalCoins,
      czkAmount: req.czkAmount,
      cardCount: approvedCards.length,
    );
    chronicleEntries.insert(0, entry);

    if (isFirebaseReady && isSignedIn && gang != null) {
      unawaited(
        _gangRepo
            .approveExchange(
              gangId: gang!.id,
              request: req,
              approvedCardIds: approvedCards.map((c) => c.id).toList(),
              chronicleEntry: entry,
            )
            .catchError((_) {}),
      );
    }

    notifyListeners();
    return true;
  }

  /// Closes the specified (or current) month:
  /// 1. Automatically converts all remaining Bank cards into pending exchange requests.
  /// 2. Inserts a visual Month Proclamation divider card into the Feed.
  /// 3. Monthly levels reset naturally because they are computed per monthKey.
  int closeMonth({String? monthKey}) {
    if (!isCurrentUserHand) return 0;
    final key = monthKey ?? currentMonthKey;
    final now = _clock();

    var createdRequests = 0;
    for (final member in members) {
      final hasBankInMonth = playedCards.any(
        (c) =>
            c.memberId == member.id &&
            c.monthKey == key &&
            c.status == PlayedCardStatus.inBank,
      );
      if (hasBankInMonth) {
        final req = requestExchange(memberId: member.id, isAutoMonthEnd: true);
        if (req != null) createdRequests++;
      }
    }

    final board = buildLeaderboard(
      period: LeaderboardPeriod.allTime,
      sort: LeaderboardSort.mostHardWorking,
      explicitMonthKey: key,
    );
    final winner = board.isNotEmpty && board.first.approvedCoins > 0
        ? board.first
        : null;

    final entry = ChronicleEntry(
      id: 'month_${key}_${now.microsecondsSinceEpoch}',
      type: ChronicleEntryType.monthProclamation,
      actorNickname: 'Ruka sídla',
      title: 'Měsíční vyhlášení • $key',
      message: winner == null
          ? 'Měsíc $key byl uzavřen. Levely se s novým měsícem resetují na Probuzený.'
          : '${winner.member.sex.winnerRole} měsíce $key ${winner.member.sex.becameVerb} ${winner.member.nickname} (${winner.approvedCoins} Coinů, ${winner.approvedTaskCount} úkolů).',
      createdAt: now,
      monthKey: key,
      symbol: '♛',
      coins: winner?.approvedCoins,
      cardCount: winner?.approvedTaskCount,
      winnerNickname: winner?.member.nickname,
    );
    chronicleEntries.insert(0, entry);

    if (isFirebaseReady && isSignedIn && gang != null) {
      unawaited(
        _gangRepo
            .addChronicleEntry(gangId: gang!.id, entry: entry)
            .catchError((_) {}),
      );
    }

    notifyListeners();
    return createdRequests;
  }

  // ---------------------------------------------------------------------------
  // Leaderboard (Approved exchanges only!)
  // ---------------------------------------------------------------------------

  List<PlayerLeaderboardCardData> buildLeaderboard({
    required LeaderboardPeriod period,
    required LeaderboardSort sort,
    String? explicitMonthKey,
  }) {
    final targetMonth = switch (period) {
      LeaderboardPeriod.currentMonth => explicitMonthKey ?? currentMonthKey,
      LeaderboardPeriod.previousMonth => previousMonthKey,
      LeaderboardPeriod.allTime => explicitMonthKey,
    };

    final now = _clock();
    final list = members.map((member) {
      final approved = playedCards.where((c) {
        if (c.memberId != member.id) return false;
        if (c.status != PlayedCardStatus.exchanged) return false;
        if (targetMonth != null && c.monthKey != targetMonth) return false;
        return true;
      }).toList();

      final inBank = bankCardsFor(member.id);

      return PlayerLeaderboardCardData(
        member: member,
        monthlyLevel: monthlyLevelFor(
          member.id,
          monthKey: targetMonth ?? currentMonthKey,
        ),
        heatLevel: heatLevelFor(member, at: now),
        streakDays: streakDaysFor(member, at: now),
        approvedTaskCount: approved.length,
        approvedCoins: approved.fold(0, (sum, c) => sum + c.coinsAwarded),
        approvedMinutes: approved.fold(0, (sum, c) => sum + c.chore.minutes),
        inBankCoins: inBank.fold(0, (sum, c) => sum + c.coinsAwarded),
        inBankCount: inBank.length,
      );
    }).toList();

    list.sort((a, b) {
      final cmp = switch (sort) {
        LeaderboardSort.mostActive => b.approvedTaskCount.compareTo(
          a.approvedTaskCount,
        ),
        LeaderboardSort.mostHardWorking => b.approvedCoins.compareTo(
          a.approvedCoins,
        ),
        LeaderboardSort.byStreakLevel => _compareByHeat(a, b),
      };
      if (cmp != 0) return cmp;
      return b.approvedCoins.compareTo(a.approvedCoins);
    });
    return list;
  }

  int _compareByHeat(PlayerLeaderboardCardData a, PlayerLeaderboardCardData b) {
    final heatCmp = b.heatLevel.index.compareTo(a.heatLevel.index);
    if (heatCmp != 0) return heatCmp;
    return b.streakDays.compareTo(a.streakDays);
  }

  // ---------------------------------------------------------------------------
  // Sample Mansion Seeding
  // ---------------------------------------------------------------------------

  void _seedSampleMansion({String? overrideInviteCode}) {
    final now = _clock();
    final founder = GangMember(
      id: 'member-1',
      nickname: 'Dark Lord',
      isHand: true,
      sex: MemberSex.male,
    );

    final demoGang = Gang(
      id: 'gang-demo',
      name: _l10n.defaultMansionName,
      inviteCode: overrideInviteCode ?? 'GRIM-42',
      founderId: founder.id,
      coinsPerCzk: 10,
    );
    _workspaces.removeWhere((w) => w.gang.id == demoGang.id);
    _workspaces.add(
      GangWorkspace(
        gang: demoGang,
        currentMemberId: founder.id,
        members: [founder],
      ),
    );
    _activeGangId = demoGang.id;
    hasSeenIntro = true;

    _populateGangWithSampleHistory(founder, referenceNow: now);
  }

  void _populateGangWithSampleHistory(
    GangMember founder, {
    DateTime? referenceNow,
  }) {
    final now = referenceNow ?? _clock();
    final prevMonth = DateTime(now.year, now.month - 1, 20, 18, 0);
    final prevKey = monthKeyFor(prevMonth);
    final currKey = monthKeyFor(now);

    final queen = GangMember(
      id: _nextId('member'),
      nickname: _l10n.sampleQueenNickname,
      isHand: false,
      sex: MemberSex.female,
      heatPeakDays: 7,
      lastActiveDay: _dateOnly(now),
    );
    final shadow = GangMember(
      id: _nextId('member'),
      nickname: 'Shadow Master',
      isHand: false,
      sex: MemberSex.male,
      heatPeakDays: 3,
      lastActiveDay: _dateOnly(now.subtract(const Duration(days: 1))),
    );
    founder
      ..heatPeakDays = 4
      ..lastActiveDay = _dateOnly(now);

    members.addAll([queen, shadow]);

    // Previous month approved records + Month Proclamation divider
    final prevCard1 = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[16], // room 1000
      memberId: queen.id,
      memberNickname: queen.nickname,
      coinsAwarded: 1200,
      playedAt: prevMonth,
      monthKey: prevKey,
      levelAtPlay: MonthlyLevel.restlessSpirit,
      heatAtPlay: HeatLevel.glowingEmbers,
      status: PlayedCardStatus.exchanged,
      exchangedAt: prevMonth.add(const Duration(days: 2)),
    );
    final prevCard2 = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[14], // cooking 700
      memberId: founder.id,
      memberNickname: founder.nickname,
      coinsAwarded: 770,
      playedAt: prevMonth.add(const Duration(hours: 3)),
      monthKey: prevKey,
      levelAtPlay: MonthlyLevel.awakened,
      heatAtPlay: HeatLevel.glowingEmbers,
      status: PlayedCardStatus.exchanged,
      exchangedAt: prevMonth.add(const Duration(days: 2)),
    );
    playedCards.addAll([prevCard1, prevCard2]);

    // Current month approved records (count into Leaderboard!)
    final currApproved1 = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[11], // bathroom 600
      memberId: queen.id,
      memberNickname: queen.nickname,
      coinsAwarded: 780,
      playedAt: now.subtract(const Duration(days: 2, hours: 3)),
      monthKey: currKey,
      levelAtPlay: MonthlyLevel.awakened,
      heatAtPlay: HeatLevel.hellfire,
      status: PlayedCardStatus.exchanged,
      exchangedAt: now.subtract(const Duration(days: 1, hours: 5)),
    );
    final currApproved2 = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[5], // queenie 300
      memberId: queen.id,
      memberNickname: queen.nickname,
      coinsAwarded: 390,
      playedAt: now.subtract(const Duration(days: 2)),
      monthKey: currKey,
      levelAtPlay: MonthlyLevel.awakened,
      heatAtPlay: HeatLevel.hellfire,
      status: PlayedCardStatus.exchanged,
      exchangedAt: now.subtract(const Duration(days: 1, hours: 5)),
    );
    final currApproved3 = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[10], // evening 450
      memberId: shadow.id,
      memberNickname: shadow.nickname,
      coinsAwarded: 495,
      playedAt: now.subtract(const Duration(days: 1, hours: 8)),
      monthKey: currKey,
      levelAtPlay: MonthlyLevel.awakened,
      heatAtPlay: HeatLevel.glowingEmbers,
      status: PlayedCardStatus.exchanged,
      exchangedAt: now.subtract(const Duration(hours: 20)),
    );

    // Pending exchange request from Shadow Master for the Hand to approve
    final pendingCard = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[12], // mop 500
      memberId: shadow.id,
      memberNickname: shadow.nickname,
      coinsAwarded: 550,
      playedAt: now.subtract(const Duration(hours: 6)),
      monthKey: currKey,
      levelAtPlay: MonthlyLevel.awakened,
      heatAtPlay: HeatLevel.glowingEmbers,
      status: PlayedCardStatus.pendingExchange,
    );
    final pendingReq = ExchangeRequest(
      id: _nextId('ex'),
      memberId: shadow.id,
      memberNickname: shadow.nickname,
      cardIds: [pendingCard.id],
      totalCoins: pendingCard.coinsAwarded,
      coinsPerCzk: gang!.coinsPerCzk,
      requestedAt: now.subtract(const Duration(hours: 4)),
      monthKey: currKey,
    );
    pendingCard.exchangeId = pendingReq.id;
    exchangeRequests.add(pendingReq);

    // Founder's own card waiting in Bank
    final founderBankCard = PlayedCard(
      id: _nextId('card'),
      chore: choreCatalog[0], // trash 100
      memberId: founder.id,
      memberNickname: founder.nickname,
      coinsAwarded: 120,
      playedAt: now.subtract(const Duration(hours: 2)),
      monthKey: currKey,
      levelAtPlay: MonthlyLevel.awakened,
      heatAtPlay: HeatLevel.blazingForge,
      status: PlayedCardStatus.inBank,
    );

    playedCards.addAll([
      currApproved1,
      currApproved2,
      currApproved3,
      pendingCard,
      founderBankCard,
    ]);

    // Chronological Chronicle (newest first) with Month Proclamation divider!
    chronicleEntries.addAll([
      ChronicleEntry(
        id: _nextId('chronicle'),
        type: ChronicleEntryType.cardPlayed,
        actorNickname: founder.nickname,
        title: founderBankCard.chore.title,
        message:
            'zahrál kartu „${founderBankCard.chore.title}“ a uložil ${founderBankCard.coinsAwarded} Coinů do Banku.',
        createdAt: founderBankCard.playedAt,
        monthKey: currKey,
        choreId: founderBankCard.chore.id,
        symbol: founderBankCard.chore.symbol,
        coins: founderBankCard.coinsAwarded,
        levelAtEvent: MonthlyLevel.awakened,
        heatAtEvent: HeatLevel.blazingForge,
      ),
      ChronicleEntry(
        id: _nextId('chronicle'),
        type: ChronicleEntryType.cardPlayed,
        actorNickname: shadow.nickname,
        title: pendingCard.chore.title,
        message:
            'zahrál kartu „${pendingCard.chore.title}“ a uložil ${pendingCard.coinsAwarded} Coinů do Banku.',
        createdAt: pendingCard.playedAt,
        monthKey: currKey,
        choreId: pendingCard.chore.id,
        symbol: pendingCard.chore.symbol,
        coins: pendingCard.coinsAwarded,
        levelAtEvent: MonthlyLevel.awakened,
        heatAtEvent: HeatLevel.glowingEmbers,
      ),
      ChronicleEntry(
        id: _nextId('chronicle'),
        type: ChronicleEntryType.exchangeApproved,
        actorNickname: queen.nickname,
        title: 'Směna schválena Rukou',
        message: '${queen.nickname} směnila 2 karty za 1 170 Coinů (117 Kč).',
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
        monthKey: currKey,
        symbol: '☞',
        coins: 1170,
        czkAmount: 117,
        cardCount: 2,
      ),
      ChronicleEntry(
        id: _nextId('chronicle'),
        type: ChronicleEntryType.cardPlayed,
        actorNickname: queen.nickname,
        title: currApproved1.chore.title,
        message:
            'zahrála kartu „${currApproved1.chore.title}“ a uložila ${currApproved1.coinsAwarded} Coinů do Banku.',
        createdAt: currApproved1.playedAt,
        monthKey: currKey,
        choreId: currApproved1.chore.id,
        symbol: currApproved1.chore.symbol,
        coins: currApproved1.coinsAwarded,
        levelAtEvent: MonthlyLevel.awakened,
        heatAtEvent: HeatLevel.hellfire,
      ),
      ChronicleEntry(
        id: _nextId('chronicle'),
        type: ChronicleEntryType.monthProclamation,
        actorNickname: 'Ruka sídla',
        title: 'Měsíční vyhlášení • $prevKey',
        message:
            'Vládkyní minulého měsíce se stala ${queen.nickname} (1 200 Coinů). Levely se resetovaly na Probuzený.',
        createdAt: DateTime(now.year, now.month, 1, 0, 1),
        monthKey: prevKey,
        symbol: '♛',
        coins: 1200,
        cardCount: 1,
        winnerNickname: queen.nickname,
      ),
      ChronicleEntry(
        id: _nextId('chronicle'),
        type: ChronicleEntryType.cardPlayed,
        actorNickname: queen.nickname,
        title: prevCard1.chore.title,
        message:
            'zahrála kartu „${prevCard1.chore.title}“ a uložila ${prevCard1.coinsAwarded} Coinů do Banku.',
        createdAt: prevCard1.playedAt,
        monthKey: prevKey,
        choreId: prevCard1.chore.id,
        symbol: prevCard1.chore.symbol,
        coins: prevCard1.coinsAwarded,
        levelAtEvent: MonthlyLevel.restlessSpirit,
        heatAtEvent: HeatLevel.glowingEmbers,
      ),
    ]);
  }
}

const choreCatalog = <ChoreDefinition>[
  ChoreDefinition(
    id: 'trash',
    title: 'Vynést koš',
    baseCoins: 100,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 5,
  ),
  ChoreDefinition(
    id: 'shopping',
    title: 'Vyklidit nákup',
    baseCoins: 150,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 10,
  ),
  ChoreDefinition(
    id: 'dishwasher',
    title: 'Vyklidit myčku',
    baseCoins: 150,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 10,
  ),
  ChoreDefinition(
    id: 'laundry',
    title: 'Uklidit si prádlo',
    baseCoins: 200,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 15,
  ),
  ChoreDefinition(
    id: 'stairs',
    title: 'Vysát schodiště',
    baseCoins: 200,
    difficulty: ChoreDifficulty.easy,
    symbol: '♣',
    minutes: 15,
  ),
  ChoreDefinition(
    id: 'queenie',
    title: 'Vyčesat Queenie',
    baseCoins: 300,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 20,
  ),
  ChoreDefinition(
    id: 'toilet',
    title: 'Umýt toaletu',
    baseCoins: 400,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 20,
  ),
  ChoreDefinition(
    id: 'dogs',
    title: 'Příprava krmení pro psy',
    baseCoins: 350,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 20,
    note: 'Včetně nakrmení',
  ),
  ChoreDefinition(
    id: 'sport',
    title: 'Sportovní aktivita',
    baseCoins: 350,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 30,
  ),
  ChoreDefinition(
    id: 'garden',
    title: 'Zalít zahradu',
    baseCoins: 300,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 20,
    note: 'Péče o zeleň i masožravky',
  ),
  ChoreDefinition(
    id: 'evening',
    title: 'Večerní úklid',
    baseCoins: 450,
    difficulty: ChoreDifficulty.medium,
    symbol: '◆',
    minutes: 35,
    note: 'Kuchyň, předsíň a obývák',
  ),
  ChoreDefinition(
    id: 'bathroom',
    title: 'Umýt koupelnu',
    baseCoins: 600,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 40,
    note: 'Cena za jednu koupelnu',
  ),
  ChoreDefinition(
    id: 'mop',
    title: 'Vytřít parním mopem',
    baseCoins: 500,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 35,
  ),
  ChoreDefinition(
    id: 'ironing',
    title: 'Vyžehlit',
    baseCoins: 700,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 45,
  ),
  ChoreDefinition(
    id: 'cooking',
    title: 'Uvařit jídlo',
    baseCoins: 700,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 60,
  ),
  ChoreDefinition(
    id: 'school',
    title: 'Učení / Škola',
    baseCoins: 600,
    difficulty: ChoreDifficulty.hard,
    symbol: '♥',
    minutes: 45,
  ),
  ChoreDefinition(
    id: 'room',
    title: 'Vygruntovat pokojíček',
    baseCoins: 1000,
    difficulty: ChoreDifficulty.special,
    symbol: '★',
    minutes: 90,
    note: 'Velký hloubkový úklid',
  ),
];
