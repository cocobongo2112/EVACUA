import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/services/firebase/auth_service.dart';
import 'package:evacua/services/firebase/user_profile_service.dart';
import 'package:evacua/widgets/role_guard.dart';

void main() {
  testWidgets('RoleGuard permite acceso al administrador', (
    WidgetTester tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('admin-1').set({
      'name': 'Administrador',
      'email': 'admin@evacua.mx',
      'role': 'admin',
      'active': true,
    });

    final authService = AuthService(
      auth: MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'admin-1',
          email: 'admin@evacua.mx',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RoleGuard(
          requiredRole: 'admin',
          authService: authService,
          profileService: UserProfileService(firestore: firestore),
          child: const Scaffold(body: Text('Contenido admin')),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Contenido admin'), findsOneWidget);
    expect(find.text('Acceso restringido'), findsNothing);
  });

  testWidgets('RoleGuard bloquea a usuario normal', (
    WidgetTester tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('user-1').set({
      'name': 'Usuario',
      'email': 'user@evacua.mx',
      'role': 'user',
      'active': true,
    });

    final authService = AuthService(
      auth: MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'user-1',
          email: 'user@evacua.mx',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RoleGuard(
          requiredRole: 'admin',
          authService: authService,
          profileService: UserProfileService(firestore: firestore),
          child: const Scaffold(body: Text('Contenido admin')),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Acceso restringido'), findsOneWidget);
    expect(find.text('Contenido admin'), findsNothing);
  });
}
