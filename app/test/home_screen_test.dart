import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/screens/home/home_screen.dart';

void main() {
  testWidgets('Home muestra funciones iniciales de EVACUA', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('EVACUA'), findsOneWidget);
    expect(
      find.text('Sistema de evacuación y gestión de emergencias'),
      findsOneWidget,
    );

    // Primeras opciones visibles.
    expect(find.text('Edificios y planos'), findsOneWidget);
    expect(find.text('Escanear ubicación'), findsOneWidget);
    expect(find.text('Mi zona'), findsOneWidget);

    // Desde Sprint 4 el Home tiene una opción adicional y las tarjetas
    // inferiores pueden quedar fuera del viewport del test.
    final scrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.text('Consultar ruta'),
      250,
      scrollable: scrollable,
    );
    expect(find.text('Consultar ruta'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Modo de emergencia'),
      250,
      scrollable: scrollable,
    );
    expect(find.text('Modo de emergencia'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Equipos de emergencia'),
      250,
      scrollable: scrollable,
    );
    expect(find.text('Equipos de emergencia'), findsOneWidget);
  });
}
