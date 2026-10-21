import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/screens/admin/evacuation_routes_admin_screen.dart';
import 'package:evacua/services/firebase/building_service.dart';
import 'package:evacua/services/firebase/evacuation_route_service.dart';

void main() {
  testWidgets('administrador ve edificio para gestionar rutas', (
    WidgetTester tester,
  ) async {
    final firestore = FakeFirebaseFirestore();

    await firestore.collection('buildings').doc('building-1').set({
      'name': 'Edificio Administrativo',
      'address': '',
      'description': '',
      'active': true,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: EvacuationRoutesAdminScreen(
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

    expect(
      find.text('Rutas, salidas y puntos de reunión'),
      findsOneWidget,
    );
    expect(
      find.text('Edificio Administrativo'),
      findsOneWidget,
    );
  });
}
