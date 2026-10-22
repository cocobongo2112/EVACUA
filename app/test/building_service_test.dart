import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/services/firebase/building_service.dart';

void main() {
  test('createBuilding registra edificio activo', () async {
    final firestore = FakeFirebaseFirestore();
    final service = BuildingService(
      firestore: firestore,
    );

    final id = await service.createBuilding(
      name: 'Edificio A',
      address: 'Campus principal',
      description: 'Edificio de prueba',
    );

    final document = await firestore.collection('buildings').doc(id).get();

    expect(document.exists, isTrue);
    expect(document.data()?['name'], 'Edificio A');
    expect(document.data()?['active'], isTrue);
  });

  test('watchBuildings filtra edificios inactivos', () async {
    final firestore = FakeFirebaseFirestore();

    await firestore.collection('buildings').doc('a').set({
      'name': 'Activo',
      'address': '',
      'description': '',
      'active': true,
    });

    await firestore.collection('buildings').doc('b').set({
      'name': 'Inactivo',
      'address': '',
      'description': '',
      'active': false,
    });

    final service = BuildingService(
      firestore: firestore,
    );

    final buildings = await service.watchBuildings(onlyActive: true).first;

    expect(buildings.length, 1);
    expect(buildings.first.name, 'Activo');
  });

  test('createLevel registra nivel dentro del edificio', () async {
    final firestore = FakeFirebaseFirestore();
    final service = BuildingService(
      firestore: firestore,
    );

    await firestore.collection('buildings').doc('edificio-1').set({
      'name': 'Edificio 1',
      'address': '',
      'description': '',
      'active': true,
    });

    final levelId = await service.createLevel(
      buildingId: 'edificio-1',
      name: 'Planta baja',
      number: 0,
      description: 'Acceso principal',
      planUrl: 'https://example.com/plano.png',
    );

    final document = await firestore
        .collection('buildings')
        .doc('edificio-1')
        .collection('levels')
        .doc(levelId)
        .get();

    expect(document.exists, isTrue);
    expect(document.data()?['name'], 'Planta baja');
    expect(document.data()?['number'], 0);
    expect(document.data()?['active'], isTrue);
  });

  test('watchLevels ordena niveles por número', () async {
    final firestore = FakeFirebaseFirestore();

    final levels = firestore
        .collection('buildings')
        .doc('edificio-1')
        .collection('levels');

    await levels.doc('nivel-2').set({
      'name': 'Nivel 2',
      'number': 2,
      'description': '',
      'planUrl': '',
      'active': true,
    });

    await levels.doc('pb').set({
      'name': 'Planta baja',
      'number': 0,
      'description': '',
      'planUrl': '',
      'active': true,
    });

    final service = BuildingService(
      firestore: firestore,
    );

    final result = await service.watchLevels('edificio-1').first;

    expect(result.length, 2);
    expect(result.first.name, 'Planta baja');
    expect(result.last.name, 'Nivel 2');
  });
}
