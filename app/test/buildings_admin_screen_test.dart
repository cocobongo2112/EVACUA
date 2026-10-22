import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/screens/admin/buildings_admin_screen.dart';
import 'package:evacua/services/firebase/building_service.dart';

void main() {
  testWidgets('administrador puede ver edificios registrados', (
    WidgetTester tester,
  ) async {
    final firestore = FakeFirebaseFirestore();

    await firestore.collection('buildings').doc('edificio-a').set({
      'name': 'Edificio Administrativo',
      'address': 'Campus EVACUA',
      'description': '',
      'active': true,
    });

    final service = BuildingService(
      firestore: firestore,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BuildingsAdminScreen(
          service: service,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Edificios y planos'),
      findsOneWidget,
    );
    expect(
      find.text('Edificio Administrativo'),
      findsOneWidget,
    );
    expect(
      find.text('Niveles y planos'),
      findsOneWidget,
    );
  });
}
