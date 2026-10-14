import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/routes/app_routes.dart';
import 'package:evacua/screens/login/login_screen.dart';
import 'package:evacua/services/firebase/auth_service.dart';
import 'package:evacua/services/firebase/user_profile_service.dart';

Widget _buildLoginApp({
  required AuthService authService,
  required UserProfileService profileService,
}) {
  return MaterialApp(
    home: LoginScreen(
      authService: authService,
      profileService: profileService,
    ),
    routes: {
      AppRoutes.home: (_) => const Scaffold(
            body: Text('HOME_TEST'),
          ),
      AppRoutes.adminHome: (_) => const Scaffold(
            body: Text('ADMIN_HOME_TEST'),
          ),
      AppRoutes.register: (_) => const Scaffold(
            body: Text('REGISTER_TEST'),
          ),
    },
  );
}

void main() {
  testWidgets('Login valida campos vacíos', (
    WidgetTester tester,
  ) async {
    final authService = AuthService(
      auth: MockFirebaseAuth(),
    );

    final profileService = UserProfileService(
      firestore: FakeFirebaseFirestore(),
    );

    await tester.pumpWidget(
      _buildLoginApp(
        authService: authService,
        profileService: profileService,
      ),
    );

    await tester.tap(
      find.widgetWithText(
        ElevatedButton,
        'Iniciar sesión',
      ),
    );

    await tester.pump();

    expect(
      find.text('Ingresa tu correo electrónico.'),
      findsOneWidget,
    );
    expect(
      find.text('Ingresa tu contraseña.'),
      findsOneWidget,
    );
  });

  testWidgets('Login válido navega al Home de usuario', (
    WidgetTester tester,
  ) async {
    final mockUser = MockUser(
      uid: 'user-1',
      email: 'usuario@evacua.mx',
      displayName: 'Usuario EVACUA',
    );

    final mockAuth = MockFirebaseAuth(
      mockUser: mockUser,
      signedIn: false,
    );

    final firestore = FakeFirebaseFirestore();

    await firestore.collection('users').doc('user-1').set({
      'name': 'Usuario EVACUA',
      'email': 'usuario@evacua.mx',
      'role': 'user',
      'active': true,
    });

    final authService = AuthService(
      auth: mockAuth,
    );

    final profileService = UserProfileService(
      firestore: firestore,
    );

    await tester.pumpWidget(
      _buildLoginApp(
        authService: authService,
        profileService: profileService,
      ),
    );

    final fields = find.byType(TextFormField);

    await tester.enterText(
      fields.at(0),
      'usuario@evacua.mx',
    );
    await tester.enterText(
      fields.at(1),
      'Evacua123!',
    );

    await tester.tap(
      find.widgetWithText(
        ElevatedButton,
        'Iniciar sesión',
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('HOME_TEST'),
      findsOneWidget,
    );
  });

  testWidgets('Login de administrador navega al panel admin', (
    WidgetTester tester,
  ) async {
    final mockUser = MockUser(
      uid: 'admin-1',
      email: 'admin@evacua.mx',
      displayName: 'Administrador EVACUA',
    );

    final mockAuth = MockFirebaseAuth(
      mockUser: mockUser,
      signedIn: false,
    );

    final firestore = FakeFirebaseFirestore();

    await firestore.collection('users').doc('admin-1').set({
      'name': 'Administrador EVACUA',
      'email': 'admin@evacua.mx',
      'role': 'admin',
      'active': true,
    });

    final authService = AuthService(
      auth: mockAuth,
    );

    final profileService = UserProfileService(
      firestore: firestore,
    );

    await tester.pumpWidget(
      _buildLoginApp(
        authService: authService,
        profileService: profileService,
      ),
    );

    final fields = find.byType(TextFormField);

    await tester.enterText(
      fields.at(0),
      'admin@evacua.mx',
    );
    await tester.enterText(
      fields.at(1),
      'Evacua123!',
    );

    await tester.tap(
      find.widgetWithText(
        ElevatedButton,
        'Iniciar sesión',
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('ADMIN_HOME_TEST'),
      findsOneWidget,
    );
  });
}
