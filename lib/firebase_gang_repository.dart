import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

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

  Future<UserCredential?> signInWithGoogle() async {
    if (!isFirebaseReady) return null;
    return _firebaseAuth.signInWithProvider(GoogleAuthProvider());
  }

  Future<void> signOut() async {
    if (!isFirebaseReady) return;
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
    final gangName = (invite['gangName'] as String?) ?? 'Sídlo';
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
}
