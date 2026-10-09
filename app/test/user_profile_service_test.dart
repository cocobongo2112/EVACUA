import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/services/firebase/user_profile_service.dart';

void main() {
  test('createProfile crea usuario con rol user', () async {
    final firestore = FakeFirebaseFirestore();
    final service = UserProfileService(firestore: firestore);

    final profile = await service.createProfile(
      uid: 'uid-1',
      name: 'José Felipe',
      email: 'felipe@evacua.mx',
    );

    expect(profile.role, 'user');
    expect(profile.active, isTrue);

    final document = await firestore.collection('users').doc('uid-1').get();
    expect(document.exists, isTrue);
    expect(document.data()?['role'], 'user');
  });

  test('getProfile devuelve perfil existente', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('admin-1').set({
      'name': 'Administrador',
      'email': 'admin@evacua.mx',
      'role': 'admin',
      'active': true,
    });

    final service = UserProfileService(firestore: firestore);
    final profile = await service.getProfile('admin-1');

    expect(profile, isNotNull);
    expect(profile!.isAdmin, isTrue);
  });

  test('getProfile devuelve null cuando no existe', () async {
    final firestore = FakeFirebaseFirestore();
    final service = UserProfileService(firestore: firestore);

    final profile = await service.getProfile('missing');
    expect(profile, isNull);
  });

  test('ensureProfile conserva perfil existente', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('uid-2').set({
      'name': 'Karol',
      'email': 'karol@evacua.mx',
      'role': 'admin',
      'active': true,
    });

    final service = UserProfileService(firestore: firestore);
    final profile = await service.ensureProfile(
      uid: 'uid-2',
      email: 'karol@evacua.mx',
    );

    expect(profile.role, 'admin');
    expect(profile.name, 'Karol');
  });

  test('ensureProfile crea perfil para cuenta antigua', () async {
    final firestore = FakeFirebaseFirestore();
    final service = UserProfileService(firestore: firestore);

    final profile = await service.ensureProfile(
      uid: 'uid-3',
      email: 'gabino@evacua.mx',
    );

    expect(profile.role, 'user');
    expect(profile.name, 'gabino');
  });
}
