import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/routes/app_routes.dart';
import 'package:evacua/screens/welcome/welcome_screen.dart';

Widget _buildWelcomeApp() {
  return MaterialApp(
    home: const WelcomeScreen(),
    routes: {
      AppRoutes.login: (_) => const Scaffold(
            body: Text('LOGIN_DESTINATION'),
          ),
      AppRoutes.register: (_) => const Scaffold(
            body: Text('REGISTER_DESTINATION'),
          ),
    },
  );
}

void main() {
  testWidgets('Bienvenida navega al inicio de sesión', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildWelcomeApp(),
    );

    expect(
      find.text('Iniciar sesión'),
      findsOneWidget,
    );

    await tester.tap(
      find.text('Iniciar sesión'),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('LOGIN_DESTINATION'),
      findsOneWidget,
    );
  });

  testWidgets('Bienvenida navega al registro', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildWelcomeApp(),
    );

    expect(
      find.text('Crear cuenta'),
      findsOneWidget,
    );

    await tester.tap(
      find.text('Crear cuenta'),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('REGISTER_DESTINATION'),
      findsOneWidget,
    );
  });
}
