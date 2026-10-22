import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/services/firebase/evacuation_route_service.dart';

void main() {
  test('registra salida, punto de reunión y ruta', () async {
    final firestore = FakeFirebaseFirestore();
    final service = EvacuationRouteService(
      firestore: firestore,
    );

    final exitId = await service.createExit(
      buildingId: 'building-1',
      levelId: 'level-1',
      levelName: 'Planta baja',
      name: 'Salida Norte',
      description: 'Puerta junto a recepción',
    );

    final pointId = await service.createMeetingPoint(
      buildingId: 'building-1',
      name: 'Punto A',
      location: 'Estacionamiento',
      description: 'Zona abierta',
    );

    final routeId = await service.createRoute(
      buildingId: 'building-1',
      levelId: 'level-1',
      levelName: 'Planta baja',
      name: 'Ruta Norte',
      origin: 'Recepción',
      instructions: 'Avanzar por pasillo principal',
      exitId: exitId,
      exitName: 'Salida Norte',
      meetingPointId: pointId,
      meetingPointName: 'Punto A',
    );

    final route = await firestore
        .collection('buildings')
        .doc('building-1')
        .collection('routes')
        .doc(routeId)
        .get();

    expect(route.exists, isTrue);
    expect(route.data()?['exitName'], 'Salida Norte');
    expect(route.data()?['meetingPointName'], 'Punto A');
    expect(route.data()?['active'], isTrue);
  });

  test('watchRoutes filtra rutas inactivas', () async {
    final firestore = FakeFirebaseFirestore();

    final routes = firestore
        .collection('buildings')
        .doc('building-1')
        .collection('routes');

    await routes.doc('active').set({
      'levelId': 'l1',
      'levelName': 'PB',
      'name': 'Ruta activa',
      'origin': 'Recepción',
      'instructions': 'Pasillo',
      'exitId': 'e1',
      'exitName': 'Salida 1',
      'meetingPointId': 'p1',
      'meetingPointName': 'Punto 1',
      'active': true,
    });

    await routes.doc('inactive').set({
      'levelId': 'l1',
      'levelName': 'PB',
      'name': 'Ruta inactiva',
      'origin': 'Recepción',
      'instructions': 'Pasillo',
      'exitId': 'e1',
      'exitName': 'Salida 1',
      'meetingPointId': 'p1',
      'meetingPointName': 'Punto 1',
      'active': false,
    });

    final service = EvacuationRouteService(
      firestore: firestore,
    );

    final result = await service
        .watchRoutes(
          'building-1',
          onlyActive: true,
        )
        .first;

    expect(result.length, 1);
    expect(result.first.name, 'Ruta activa');
  });
}
