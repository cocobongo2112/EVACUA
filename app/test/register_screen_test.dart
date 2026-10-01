import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/routes/app_routes.dart';
import 'package:evacua/screens/home/home_screen.dart';
import 'package:evacua/screens/register/register_screen.dart';
import 'package:evacua/services/firebase/auth_service.dart';

void main() {
  testWidgets('Registro valida contraseñas diferentes', (
    WidgetTester tester,
  ) async {
    final authService = AuthService(
      auth: MockFirebaseAuth(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RegisterScreen(
          authService: authService,
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'usuario@evacua.mx',
    );

    await tester.enterText(
      find.byType(TextFormField).at(1),
      '123456',
    );

    await tester.enterText(
      find.byType(TextFormField).at(2),
      '654321',
    );

    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Crear cuenta'),
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
    final authService = AuthService(
      auth: MockFirebaseAuth(),
    );

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          AppRoutes.home: (_) => const HomeScreen(),
        },
        home: RegisterScreen(
          authService: authService,
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'nuevo@evacua.mx',
    );

    await tester.enterText(
      find.byType(TextFormField).at(1),
      '123456',
    );

    await tester.enterText(
      find.byType(TextFormField).at(2),
      '123456',
    );

    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Crear cuenta'),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Sistema de evacuación y gestión de emergencias'),
      findsOneWidget,
    );
  });
}
