import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/routes/app_routes.dart';
import 'package:evacua/screens/home/home_screen.dart';
import 'package:evacua/screens/welcome/welcome_screen.dart';
import 'package:evacua/services/firebase/auth_service.dart';

void main() {
  testWidgets('Home muestra funciones iniciales de EVACUA', (
    WidgetTester tester,
  ) async {
    final authService = AuthService(
      auth: MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'usuario-1',
          email: 'usuario@evacua.mx',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          authService: authService,
        ),
      ),
    );

    expect(find.text('Escanear ubicación'), findsOneWidget);
    expect(find.text('Mi zona'), findsOneWidget);
    expect(find.text('Consultar ruta'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Modo de emergencia'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Modo de emergencia'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Equipos de emergencia'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Equipos de emergencia'), findsOneWidget);
  });

  testWidgets('Cerrar sesión regresa a Bienvenida', (
    WidgetTester tester,
  ) async {
    final mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(
        uid: 'usuario-1',
        email: 'usuario@evacua.mx',
      ),
    );

    final authService = AuthService(auth: mockAuth);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/home-test',
        routes: {
          '/home-test': (_) => HomeScreen(
                authService: authService,
              ),
          AppRoutes.welcome: (_) => const WelcomeScreen(),
        },
      ),
    );

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(authService.currentUser, isNull);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });
}
