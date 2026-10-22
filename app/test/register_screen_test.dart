import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/routes/app_routes.dart';
import 'package:evacua/screens/register/register_screen.dart';
import 'package:evacua/services/firebase/auth_service.dart';
import 'package:evacua/services/firebase/user_profile_service.dart';

Widget _buildRegisterApp({
  required AuthService authService,
  required UserProfileService profileService,
}) {
  return MaterialApp(
    home: RegisterScreen(
      authService: authService,
      profileService: profileService,
    ),
    routes: {
      AppRoutes.home: (_) => const Scaffold(
            body: Text('HOME_TEST'),
          ),
      AppRoutes.login: (_) => const Scaffold(
            body: Text('LOGIN_TEST'),
          ),
    },
  );
}

void main() {
  testWidgets('Registro valida contraseñas diferentes', (
    WidgetTester tester,
  ) async {
    final authService = AuthService(
      auth: MockFirebaseAuth(),
    );

    final profileService = UserProfileService(
      firestore: FakeFirebaseFirestore(),
    );

    await tester.pumpWidget(
      _buildRegisterApp(
        authService: authService,
        profileService: profileService,
      ),
    );

    final fields = find.byType(TextFormField);

    await tester.enterText(
      fields.at(0),
      'José Felipe',
    );
    await tester.enterText(
      fields.at(1),
      'felipe@evacua.mx',
    );
    await tester.enterText(
      fields.at(2),
      'Evacua123!',
    );
    await tester.enterText(
      fields.at(3),
      'Otra123!',
    );

    await tester.tap(
      find.widgetWithText(
        ElevatedButton,
        'Crear cuenta',
      ),
    );

    await tester.pump();

    expect(
      find.text('Las contraseñas no coinciden.'),
      findsOneWidget,
    );
  });

  testWidgets('Registro válido navega al Home', (
    WidgetTester tester,
  ) async {
    final mockUser = MockUser(
      uid: 'nuevo-1',
      email: 'nuevo@evacua.mx',
      displayName: 'Nuevo Usuario',
    );

    final authService = AuthService(
      auth: MockFirebaseAuth(
        mockUser: mockUser,
        signedIn: false,
      ),
    );

    final firestore = FakeFirebaseFirestore();

    final profileService = UserProfileService(
      firestore: firestore,
    );

    await tester.pumpWidget(
      _buildRegisterApp(
        authService: authService,
        profileService: profileService,
      ),
    );

    final fields = find.byType(TextFormField);

    await tester.enterText(
      fields.at(0),
      'Nuevo Usuario',
    );
    await tester.enterText(
      fields.at(1),
      'nuevo@evacua.mx',
    );
    await tester.enterText(
      fields.at(2),
      'Evacua123!',
    );
    await tester.enterText(
      fields.at(3),
      'Evacua123!',
    );

    await tester.tap(
      find.widgetWithText(
        ElevatedButton,
        'Crear cuenta',
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('HOME_TEST'),
      findsOneWidget,
    );

    final users = await firestore.collection('users').get();

    expect(
      users.docs.length,
      1,
    );
    expect(
      users.docs.first.data()['role'],
      'user',
    );
    expect(
      users.docs.first.data()['active'],
      true,
    );
  });
}
