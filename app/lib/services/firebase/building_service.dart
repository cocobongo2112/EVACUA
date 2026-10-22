import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/building.dart';
import '../../models/building_level.dart';

class BuildingService {
  BuildingService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _buildings =>
      _firestore.collection('buildings');

  Stream<List<Building>> watchBuildings({
    bool onlyActive = false,
  }) {
    Query<Map<String, dynamic>> query = _buildings;

    if (onlyActive) {
      query = query.where(
        'active',
        isEqualTo: true,
      );
    }

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map(
            (doc) => Building.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();

      items.sort(
        (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
      );

      return items;
    });
  }

  Future<String> createBuilding({
    required String name,
    required String address,
    required String description,
  }) async {
    final document = await _buildings.add({
      'name': name.trim(),
      'address': address.trim(),
      'description': description.trim(),
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Future<void> updateBuilding(
    Building building,
  ) {
    return _buildings.doc(building.id).update({
      ...building.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setBuildingActive({
    required String buildingId,
    required bool active,
  }) {
    return _buildings.doc(buildingId).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  CollectionReference<Map<String, dynamic>> _levels(
    String buildingId,
  ) {
    return _buildings.doc(buildingId).collection('levels');
  }

  Stream<List<BuildingLevel>> watchLevels(
    String buildingId, {
    bool onlyActive = false,
  }) {
    Query<Map<String, dynamic>> query = _levels(buildingId);

    if (onlyActive) {
      query = query.where(
        'active',
        isEqualTo: true,
      );
    }

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map(
            (doc) => BuildingLevel.fromMap(
              doc.id,
              buildingId,
              doc.data(),
            ),
          )
          .toList();

      items.sort((a, b) {
        final byNumber = a.number.compareTo(b.number);
        if (byNumber != 0) {
          return byNumber;
        }

        return a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            );
      });

      return items;
    });
  }

  Future<String> createLevel({
    required String buildingId,
    required String name,
    required int number,
    required String description,
    required String planUrl,
  }) async {
    final document = await _levels(buildingId).add({
      'name': name.trim(),
      'number': number,
      'description': description.trim(),
      'planUrl': planUrl.trim(),
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Future<void> updateLevel(
    BuildingLevel level,
  ) {
    return _levels(level.buildingId).doc(level.id).update({
      ...level.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setLevelActive({
    required String buildingId,
    required String levelId,
    required bool active,
  }) {
    return _levels(buildingId).doc(levelId).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
