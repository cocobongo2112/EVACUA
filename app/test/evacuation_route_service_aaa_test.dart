import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/services/firebase/evacuation_route_service.dart';

void main() {
  group('EvacuationRouteService - pruebas automatizadas AAA', () {
    test('CP-AAA-01 registra una salida activa y normaliza sus datos',
        () async {
      // ARRANGE: preparar Firestore simulado y el servicio bajo prueba.
      final firestore = FakeFirebaseFirestore();
      final service = EvacuationRouteService(firestore: firestore);

      // ACT: registrar una salida con espacios adicionales.
      final exitId = await service.createExit(
        buildingId: 'building-1',
        levelId: ' level-1 ',
        levelName: ' Planta baja ',
        name: ' Salida Norte ',
        description: ' Puerta junto a recepción ',
      );
      final snapshot = await firestore
          .collection('buildings')
          .doc('building-1')
          .collection('exits')
          .doc(exitId)
          .get();

      // ASSERT: comprobar persistencia, limpieza de texto y estado activo.
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['levelId'], 'level-1');
      expect(snapshot.data()?['name'], 'Salida Norte');
      expect(snapshot.data()?['description'], 'Puerta junto a recepción');
      expect(snapshot.data()?['active'], isTrue);
    });

    test('CP-AAA-02 registra correctamente un punto de reunión', () async {
      // ARRANGE: preparar una base simulada sin información previa.
      final firestore = FakeFirebaseFirestore();
      final service = EvacuationRouteService(firestore: firestore);

      // ACT: crear el punto de reunión asociado al edificio.
      final pointId = await service.createMeetingPoint(
        buildingId: 'building-1',
        name: ' Punto A ',
        location: ' Estacionamiento principal ',
        description: ' Zona abierta y señalizada ',
      );
      final snapshot = await firestore
          .collection('buildings')
          .doc('building-1')
          .collection('meetingPoints')
          .doc(pointId)
          .get();

      // ASSERT: verificar los datos almacenados y el estado inicial.
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['name'], 'Punto A');
      expect(snapshot.data()?['location'], 'Estacionamiento principal');
      expect(snapshot.data()?['description'], 'Zona abierta y señalizada');
      expect(snapshot.data()?['active'], isTrue);
    });

    test('CP-AAA-03 registra una ruta con salida y punto de reunión', () async {
      // ARRANGE: crear las referencias requeridas por una ruta.
      final firestore = FakeFirebaseFirestore();
      final service = EvacuationRouteService(firestore: firestore);
      final exitId = await service.createExit(
        buildingId: 'building-1',
        levelId: 'level-1',
        levelName: 'Planta baja',
        name: 'Salida Norte',
        description: 'Puerta principal',
      );
      final pointId = await service.createMeetingPoint(
        buildingId: 'building-1',
        name: 'Punto A',
        location: 'Estacionamiento',
        description: 'Zona segura',
      );

      // ACT: registrar la ruta vinculada con ambas referencias.
      final routeId = await service.createRoute(
        buildingId: 'building-1',
        levelId: 'level-1',
        levelName: 'Planta baja',
        name: 'Ruta Norte',
        origin: 'Recepción',
        instructions: 'Avanzar por el pasillo principal',
        exitId: exitId,
        exitName: 'Salida Norte',
        meetingPointId: pointId,
        meetingPointName: 'Punto A',
      );
      final snapshot = await firestore
          .collection('buildings')
          .doc('building-1')
          .collection('routes')
          .doc(routeId)
          .get();

      // ASSERT: validar la relación y la información de la ruta.
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['origin'], 'Recepción');
      expect(snapshot.data()?['exitId'], exitId);
      expect(snapshot.data()?['meetingPointId'], pointId);
      expect(snapshot.data()?['active'], isTrue);
    });

    test('CP-AAA-04 devuelve únicamente las rutas activas', () async {
      // ARRANGE: almacenar una ruta activa y otra inactiva.
      final firestore = FakeFirebaseFirestore();
      final routes = firestore
          .collection('buildings')
          .doc('building-1')
          .collection('routes');
      await routes.doc('route-active').set(_routeData(
            name: 'Ruta activa',
            active: true,
          ));
      await routes.doc('route-inactive').set(_routeData(
            name: 'Ruta inactiva',
            active: false,
          ));
      final service = EvacuationRouteService(firestore: firestore);

      // ACT: consultar el flujo solicitando solo rutas activas.
      final result =
          await service.watchRoutes('building-1', onlyActive: true).first;

      // ASSERT: confirmar que la ruta inactiva fue excluida.
      expect(result, hasLength(1));
      expect(result.single.id, 'route-active');
      expect(result.single.name, 'Ruta activa');
      expect(result.single.active, isTrue);
    });

    test('CP-AAA-05 ordena rutas por nivel y después por nombre', () async {
      // ARRANGE: registrar rutas en un orden diferente al esperado.
      final firestore = FakeFirebaseFirestore();
      final routes = firestore
          .collection('buildings')
          .doc('building-1')
          .collection('routes');
      await routes.doc('route-b').set(_routeData(
            levelName: 'Planta baja',
            name: 'Ruta B',
          ));
      await routes.doc('route-z').set(_routeData(
            levelName: 'Planta alta',
            name: 'Ruta Z',
          ));
      await routes.doc('route-a').set(_routeData(
            levelName: 'Planta baja',
            name: 'Ruta A',
          ));
      final service = EvacuationRouteService(firestore: firestore);

      // ACT: recuperar todas las rutas mediante el servicio.
      final result = await service.watchRoutes('building-1').first;

      // ASSERT: validar el orden por nivel y, en empate, por nombre.
      expect(
        result.map((route) => route.name).toList(),
        <String>['Ruta Z', 'Ruta A', 'Ruta B'],
      );
    });
  });
}

Map<String, dynamic> _routeData({
  String levelName = 'Planta baja',
  required String name,
  bool active = true,
}) {
  return {
    'levelId': 'level-1',
    'levelName': levelName,
    'name': name,
    'origin': 'Recepción',
    'instructions': 'Seguir señalización',
    'exitId': 'exit-1',
    'exitName': 'Salida Norte',
    'meetingPointId': 'point-1',
    'meetingPointName': 'Punto A',
    'active': active,
  };
}
