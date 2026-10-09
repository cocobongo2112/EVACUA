import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/routes/app_routes.dart';
import 'package:evacua/screens/emergency/emergency_screen.dart';
import 'package:evacua/screens/equipment/emergency_equipment_screen.dart';
import 'package:evacua/screens/home/home_screen.dart';
import 'package:evacua/screens/qr/qr_scanner_screen.dart';
import 'package:evacua/screens/route/evacuation_route_screen.dart';
import 'package:evacua/screens/zone/my_zone_screen.dart';
import 'package:evacua/services/firebase/auth_service.dart';

Widget _buildTestApp() {
  final authService = AuthService(
    auth: MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(
        uid: 'sprint2-user',
        email: 'sprint2@evacua.mx',
      ),
    ),
  );

  return MaterialApp(
    home: HomeScreen(authService: authService),
    routes: {
      AppRoutes.qrScanner: (_) => const QrScannerScreen(),
      AppRoutes.myZone: (_) => const MyZoneScreen(),
      AppRoutes.evacuationRoute: (_) => const EvacuationRouteScreen(),
      AppRoutes.emergency: (_) => const EmergencyScreen(),
      AppRoutes.equipment: (_) => const EmergencyEquipmentScreen(),
    },
  );
}

Future<void> _tapHomeOption(
  WidgetTester tester,
  String option,
) async {
  final finder = find.text(option);

  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).first,
  );

  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Home navega a Escanear ubicación', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());

    await _tapHomeOption(tester, 'Escanear ubicación');

    expect(
      find.text('Identifica tu zona mediante un código QR'),
      findsOneWidget,
    );
  });

  testWidgets('Home navega a Mi zona', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());

    await _tapHomeOption(tester, 'Mi zona');

    expect(find.text('Zona identificada'), findsOneWidget);
    expect(find.text('Vista previa del plano'), findsOneWidget);
  });

  testWidgets('Home navega a Ruta de evacuación', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());

    await _tapHomeOption(tester, 'Consultar ruta');

    expect(find.text('Ruta de demostración'), findsOneWidget);
    expect(find.text('Punto de reunión'), findsOneWidget);
  });

  testWidgets('Home navega a Modo de emergencia', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());

    await _tapHomeOption(tester, 'Modo de emergencia');

    expect(
      find.text('Selecciona el tipo de emergencia'),
      findsOneWidget,
    );
    expect(find.text('Incendio'), findsOneWidget);
    expect(find.text('Sismo'), findsOneWidget);
  });

  testWidgets('Home navega a Equipos de emergencia', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());

    await _tapHomeOption(tester, 'Equipos de emergencia');

    expect(find.text('Recursos disponibles'), findsOneWidget);
    expect(find.text('Extintor'), findsOneWidget);
    expect(find.text('Botiquín'), findsOneWidget);
  });
}
