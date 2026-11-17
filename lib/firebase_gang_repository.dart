import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'models.dart';

/// Cloud Firestore & Firebase Auth service for multi-gang management,
/// shareable invite links (`invites/{code}`), and owner-only gang deletion.
///
/// Gracefully no-ops when Firebase is not configured (local demo / tests).
class FirebaseGangRepository {
  FirebaseGangRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  bool _googleSignInInitialized = false;

  bool get isFirebaseReady => Firebase.apps.isNotEmpty;

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  User? get currentUser => isFirebaseReady ? _firebaseAuth.currentUser : null;

  Stream<User?> get authStateChanges => isFirebaseReady
      ? _firebaseAuth.authStateChanges()
      : const Stream<User?>.empty();

  Future<User?> ensureSignedIn() async {
    if (!isFirebaseReady) return null;
    final existing = _firebaseAuth.currentUser;
    if (existing != null) return existing;
    final cred = await _firebaseAuth.signInAnonymously();
    return cred.user;
  }

  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isFirebaseReady) return null;
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isFirebaseReady) return null;
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.sendEmailVerification();
    return cred;
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleSignInInitialized = true;
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (!isFirebaseReady) return null;
    if (kIsWeb) {
      try {
        return await _firebaseAuth.signInWithProvider(GoogleAuthProvider());
      } on FirebaseAuthException catch (e) {
        if (e.code == 'popup-closed-by-user' ||
            e.code == 'cancelled-popup-request' ||
            e.code == 'user-cancelled') {
          return null;
        }
        rethrow;
      }
    }
    await _ensureGoogleSignInInitialized();
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-google-id-token',
          message: 'Google Sign-In did not return an ID token.',
        );
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await _firebaseAuth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!isFirebaseReady) return;
    if (!kIsWeb && _googleSignInInitialized) {
      await GoogleSignIn.instance.signOut();
    }
    await _firebaseAuth.signOut();
  }

  Future<Map<String, dynamic>?> lookupInvite(String inviteCode) async {
    if (!isFirebaseReady) return null;
    final cleanCode = inviteCode.trim().toUpperCase();
    if (cleanCode.isEmpty) return null;
    final doc = await _db.collection('invites').doc(cleanCode).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null || data['active'] == false) return null;
    return data;
  }

  Future<String?> createGang({
    required String gangName,
    required String founderNickname,
    required MemberSex founderSex,
    required String inviteCode,
    int coinsPerCzk = 10,
    String themeId = Gang.defaultThemeId,
  }) async {
    final user = currentUser;
    if (!isFirebaseReady || user == null) return null;

    final cleanCode = inviteCode.trim().toUpperCase();
    final gangRef = _db.collection('gangs').doc();
    final batch = _db.batch();

    batch.set(gangRef, {
      'name': gangName.trim(),
      'inviteCode': cleanCode,
      'founderId': user.uid,
      'coinsPerCzk': coinsPerCzk.clamp(1, 1000),
      'themeId': themeId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(gangRef.collection('members').doc(user.uid), {
      'nickname': founderNickname.trim(),
      'sex': founderSex.name,
      'isHand': true,
      'heatPeakDays': 0,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_db.collection('invites').doc(cleanCode), {
      'gangId': gangRef.id,
      'gangName': gangName.trim(),
      'founderId': user.uid,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(
      _db.collection('users').doc(user.uid).collection('gangs').doc(gangRef.id),
      {
        'gangId': gangRef.id,
        'gangName': gangName.trim(),
        'isHand': true,
        'nickname': founderNickname.trim(),
        'sex': founderSex.name,
        'joinedAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
    return gangRef.id;
  }

  Future<String?> acceptInvite({
    required String inviteCode,
    required String nickname,
    required MemberSex sex,
  }) async {
    final user = currentUser;
    if (!isFirebaseReady || user == null) return null;

    final invite = await lookupInvite(inviteCode);
    if (invite == null) return null;
    final gangId = invite['gangId'] as String?;
    final gangName = (invite['gangName'] as String?) ?? 'Mansion';
    if (gangId == null || gangId.isEmpty) return null;

    final batch = _db.batch();
    batch.set(
      _db.collection('gangs').doc(gangId).collection('members').doc(user.uid),
      {
        'nickname': nickname.trim(),
        'sex': sex.name,
        'isHand': false,
        'heatPeakDays': 0,
        'joinedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.set(
      _db.collection('users').doc(user.uid).collection('gangs').doc(gangId),
      {
        'gangId': gangId,
        'gangName': gangName,
        'isHand': false,
        'nickname': nickname.trim(),
        'sex': sex.name,
        'joinedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
    return gangId;
  }

  Future<void> regenerateInviteCode({
    required String gangId,
    required String gangName,
    required String oldCode,
    required String newCode,
  }) async {
    final user = currentUser;
    if (!isFirebaseReady || user == null) return;

    final batch = _db.batch();
    batch.delete(_db.collection('invites').doc(oldCode.trim().toUpperCase()));
    batch.set(_db.collection('invites').doc(newCode.trim().toUpperCase()), {
      'gangId': gangId,
      'gangName': gangName,
      'founderId': user.uid,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(_db.collection('gangs').doc(gangId), {
      'inviteCode': newCode.trim().toUpperCase(),
    });
    await batch.commit();
  }

  Future<void> updateGangTheme({
    required String gangId,
    required String themeId,
  }) async {
    final user = currentUser;
    if (!isFirebaseReady || user == null) return;
    await _db.collection('gangs').doc(gangId).update({
      'themeId': themeId,
    });
  }

  Future<void> updateFavoriteChores({
    required String gangId,
    required List<String> favoriteChoreIds,
  }) async {
    final user = currentUser;
    if (!isFirebaseReady || user == null) return;
    await _db
        .collection('gangs')
        .doc(gangId)
        .collection('members')
        .doc(user.uid)
        .set(
          {'favoriteChoreIds': favoriteChoreIds},
          SetOptions(merge: true),
        );
  }

  Future<void> deleteGang({required String gangId}) async {
    final user = currentUser;
    if (!isFirebaseReady || user == null) return;
    // Deleting the gang document triggers Cloud Function `onGangDeleted`
    // which cascades deletion of subcollections, invite index, and user links.
    await _db.collection('gangs').doc(gangId).delete();
  }

  Future<void> leaveGang({
    required String gangId,
    required String memberId,
  }) async {
    final user = currentUser;
    if (!isFirebaseReady || user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('gangs')
        .doc(gangId)
        .delete();
    await _db
        .collection('gangs')
        .doc(gangId)
        .collection('members')
        .doc(memberId)
        .delete();
  }

  Future<Map<String, dynamic>?> fetchGang(String gangId) async {
    if (!isFirebaseReady) return null;
    final doc = await _db.collection('gangs').doc(gangId).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return {'id': doc.id, ...data};
  }

  Future<List<Map<String, dynamic>>> fetchGangMembers(String gangId) async {
    if (!isFirebaseReady) return const [];
    final snap = await _db
        .collection('gangs')
        .doc(gangId)
        .collection('members')
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<List<String>> fetchUserGangIds() async {
    final user = currentUser;
    if (!isFirebaseReady || user == null) return const [];
    final snap = await _db
        .collection('users')
        .doc(user.uid)
        .collection('gangs')
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  Stream<List<Map<String, dynamic>>> watchGangMembers(String gangId) {
    if (!isFirebaseReady) return const Stream.empty();
    return _db
        .collection('gangs')
        .doc(gangId)
        .collection('members')
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> watchPlayedCards(String gangId) {
    if (!isFirebaseReady) return const Stream.empty();
    return _db
        .collection('gangs')
        .doc(gangId)
        .collection('played_cards')
        .orderBy('playedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> watchExchanges(String gangId) {
    if (!isFirebaseReady) return const Stream.empty();
    return _db
        .collection('gangs')
        .doc(gangId)
        .collection('exchanges')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> watchChronicle(String gangId) {
    if (!isFirebaseReady) return const Stream.empty();
    return _db
        .collection('gangs')
        .doc(gangId)
        .collection('chronicle')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> recordPlayedCard({
    required String gangId,
    required PlayedCard card,
    required MemberSex memberSex,
    required int heatPeakDays,
    required DateTime? lastActiveDay,
    required ChronicleEntry chronicleEntry,
  }) async {
    final user = currentUser;
    if (!isFirebaseReady || user == null) return;

    final gangRef = _db.collection('gangs').doc(gangId);
    final batch = _db.batch();

    batch.set(gangRef.collection('played_cards').doc(card.id), {
      'choreId': card.chore.id,
      'choreTitle': card.chore.title,
      'choreSymbol': card.chore.symbol,
      'choreBaseCoins': card.chore.baseCoins,
      'choreDifficulty': card.chore.difficulty.name,
      'choreMinutes': card.chore.minutes,
      'memberId': card.memberId,
      'memberNickname': card.memberNickname,
      'memberSex': memberSex.name,
      'coinsAwarded': card.coinsAwarded,
      'playedAt': Timestamp.fromDate(card.playedAt),
      'monthKey': card.monthKey,
      'levelAtPlay': card.levelAtPlay.name,
      'heatAtPlay': card.heatAtPlay.name,
      'status': card.status.name,
    });

    batch.set(
      gangRef.collection('members').doc(card.memberId),
      {
        'heatPeakDays': heatPeakDays,
        if (lastActiveDay != null)
          'lastActiveDay': Timestamp.fromDate(lastActiveDay),
      },
      SetOptions(merge: true),
    );

    await batch.commit();

    try {
      await _writeChronicleDoc(gangId: gangId, entry: chronicleEntry);
    } catch (_) {
      // Ignore if rules/functions handle chronicle separately.
    }
  }

  Future<void> createExchangeRequest({
    required String gangId,
    required ExchangeRequest request,
  }) async {
    final user = currentUser;
    if (!isFirebaseReady || user == null) return;

    final gangRef = _db.collection('gangs').doc(gangId);
    final batch = _db.batch();

    batch.set(gangRef.collection('exchanges').doc(request.id), {
      'memberId': request.memberId,
      'memberNickname': request.memberNickname,
      'cardIds': request.cardIds,
      'totalCoins': request.totalCoins,
      'coinsPerCzk': request.coinsPerCzk,
      'requestedAt': Timestamp.fromDate(request.requestedAt),
      'monthKey': request.monthKey,
      'isAutoMonthEnd': request.isAutoMonthEnd,
      'status': request.status.name,
    });

    for (final cardId in request.cardIds) {
      batch.update(gangRef.collection('played_cards').doc(cardId), {
        'status': PlayedCardStatus.pendingExchange.name,
        'exchangeId': request.id,
      });
    }

    await batch.commit();
  }

  Future<void> rejectCardInExchange({
    required String gangId,
    required String cardId,
  }) async {
    final user = currentUser;
    if (!isFirebaseReady || user == null) return;

    await _db
        .collection('gangs')
        .doc(gangId)
        .collection('played_cards')
        .doc(cardId)
        .update({'status': PlayedCardStatus.rejected.name});
  }

  Future<void> approveExchange({
    required String gangId,
    required ExchangeRequest request,
    required List<String> approvedCardIds,
    required ChronicleEntry chronicleEntry,
  }) async {
    final user = currentUser;
    if (!isFirebaseReady || user == null) return;

    final gangRef = _db.collection('gangs').doc(gangId);
    final batch = _db.batch();
    final approvedAt = request.approvedAt ?? DateTime.now();

    batch.update(gangRef.collection('exchanges').doc(request.id), {
      'status': ExchangeStatus.approved.name,
      'approvedAt': Timestamp.fromDate(approvedAt),
      'approvedByNickname': request.approvedByNickname,
      'totalCoins': request.totalCoins,
    });

    for (final cardId in approvedCardIds) {
      batch.update(gangRef.collection('played_cards').doc(cardId), {
        'status': PlayedCardStatus.exchanged.name,
        'exchangedAt': Timestamp.fromDate(approvedAt),
      });
    }

    await batch.commit();

    try {
      await _writeChronicleDoc(gangId: gangId, entry: chronicleEntry);
    } catch (_) {
      // Ignore if rules/functions handle chronicle separately.
    }
  }

  Future<void> addChronicleEntry({
    required String gangId,
    required ChronicleEntry entry,
  }) async {
    final user = currentUser;
    if (!isFirebaseReady || user == null) return;
    try {
      await _writeChronicleDoc(gangId: gangId, entry: entry);
    } catch (_) {
      // Ignore if rules disallow client chronicle writes.
    }
  }

  Future<void> _writeChronicleDoc({
    required String gangId,
    required ChronicleEntry entry,
  }) {
    return _db
        .collection('gangs')
        .doc(gangId)
        .collection('chronicle')
        .doc(entry.id)
        .set({
          'type': entry.type.name,
          'actorNickname': entry.actorNickname,
          'title': entry.title,
          'message': entry.message,
          'createdAt': Timestamp.fromDate(entry.createdAt),
          'monthKey': entry.monthKey,
          if (entry.choreId != null) 'choreId': entry.choreId,
          if (entry.symbol != null) 'symbol': entry.symbol,
          if (entry.coins != null) 'coins': entry.coins,
          if (entry.czkAmount != null) 'czkAmount': entry.czkAmount,
          if (entry.cardCount != null) 'cardCount': entry.cardCount,
          if (entry.winnerNickname != null)
            'winnerNickname': entry.winnerNickname,
          if (entry.levelAtEvent != null)
            'levelAtEvent': entry.levelAtEvent!.name,
          if (entry.heatAtEvent != null) 'heatAtEvent': entry.heatAtEvent!.name,
        }, SetOptions(merge: true));
  }
}
