import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:evacua/routes/app_routes.dart';
import 'package:evacua/screens/home/home_screen.dart';
import 'package:evacua/screens/login/login_screen.dart';
import 'package:evacua/services/firebase/auth_service.dart';

void main() {
  testWidgets('Login valida campos vacíos', (tester) async {
    final authService = AuthService(auth: MockFirebaseAuth());
    await tester
        .pumpWidget(MaterialApp(home: LoginScreen(authService: authService)));
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();
    expect(find.text('Ingresa tu correo.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
  });

  testWidgets('Login válido navega al Home', (tester) async {
    final user = MockUser(uid: 'usuario-1', email: 'usuario@evacua.mx');
    final authService = AuthService(auth: MockFirebaseAuth(mockUser: user));
    await tester.pumpWidget(MaterialApp(
      routes: {AppRoutes.home: (_) => const HomeScreen()},
      home: LoginScreen(authService: authService),
    ));
    await tester.enterText(
        find.byType(TextFormField).at(0), 'usuario@evacua.mx');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Sistema de evacuación y gestión de emergencias'),
        findsOneWidget);
  });
}
