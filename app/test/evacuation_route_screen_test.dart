import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/screens/route/evacuation_route_screen.dart';
import 'package:evacua/services/firebase/building_service.dart';
import 'package:evacua/services/firebase/evacuation_route_service.dart';

void main() {
  testWidgets('usuario consulta una ruta configurada', (
    WidgetTester tester,
  ) async {
    final firestore = FakeFirebaseFirestore();

    await firestore.collection('buildings').doc('building-1').set({
      'name': 'Edificio A',
      'address': 'Campus EVACUA',
      'description': '',
      'active': true,
    });

    await firestore
        .collection('buildings')
        .doc('building-1')
        .collection('routes')
        .doc('route-1')
        .set({
      'levelId': 'level-1',
      'levelName': 'Planta baja',
      'name': 'Ruta Norte',
      'origin': 'Recepción',
      'instructions': 'Pasillo principal → corredor norte',
      'exitId': 'exit-1',
      'exitName': 'Salida Norte',
      'meetingPointId': 'point-1',
      'meetingPointName': 'Punto A',
      'active': true,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: EvacuationRouteScreen(
          buildingService: BuildingService(
            firestore: firestore,
          ),
          routeService: EvacuationRouteService(
            firestore: firestore,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Edificio A'), findsOneWidget);

    await tester.tap(find.text('Edificio A'));
    await tester.pumpAndSettle();

    expect(find.text('Rutas disponibles'), findsOneWidget);
    expect(find.text('Ruta Norte'), findsOneWidget);
    expect(find.textContaining('Salida Norte'), findsOneWidget);
    expect(find.textContaining('Punto A'), findsOneWidget);
  });
}
