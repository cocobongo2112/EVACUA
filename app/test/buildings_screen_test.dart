import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/screens/buildings/buildings_screen.dart';
import 'package:evacua/services/firebase/building_service.dart';

void main() {
  testWidgets('consulta muestra edificio activo', (
    WidgetTester tester,
  ) async {
    final firestore = FakeFirebaseFirestore();

    await firestore.collection('buildings').doc('edificio-a').set({
      'name': 'Edificio A',
      'address': 'Campus EVACUA',
      'description': 'Edificio de prueba',
      'active': true,
    });

    final service = BuildingService(
      firestore: firestore,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BuildingsScreen(
          service: service,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Consulta de inmuebles'),
      findsOneWidget,
    );
    expect(
      find.text('Edificio A'),
      findsOneWidget,
    );
    expect(
      find.text('Campus EVACUA'),
      findsOneWidget,
    );
  });

  testWidgets('consulta oculta edificio inactivo', (
    WidgetTester tester,
  ) async {
    final firestore = FakeFirebaseFirestore();

    await firestore.collection('buildings').doc('inactivo').set({
      'name': 'Edificio inactivo',
      'address': '',
      'description': '',
      'active': false,
    });

    final service = BuildingService(
      firestore: firestore,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BuildingsScreen(
          service: service,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Edificio inactivo'),
      findsNothing,
    );
    expect(
      find.text('Aún no hay edificios disponibles'),
      findsOneWidget,
    );
  });
}
