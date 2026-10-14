import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/app_user.dart';

class UserProfileService {
  UserProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<AppUser?> getProfile(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    return AppUser.fromMap(snapshot.id, data);
  }

  Future<AppUser> createProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    final profile = AppUser(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      role: 'user',
      active: true,
    );

    await _users.doc(uid).set({
      ...profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return profile;
  }

  Future<AppUser> ensureProfile({
    required String uid,
    required String email,
    String? name,
  }) async {
    final existing = await getProfile(uid);
    if (existing != null) return existing;

    final fallbackName = (name?.trim().isNotEmpty ?? false)
        ? name!.trim()
        : _nameFromEmail(email);

    return createProfile(
      uid: uid,
      name: fallbackName,
      email: email,
    );
  }

  String _nameFromEmail(String email) {
    final trimmed = email.trim();
    final atIndex = trimmed.indexOf('@');
    if (atIndex <= 0) return 'Usuario EVACUA';
    return trimmed.substring(0, atIndex);
  }
}
