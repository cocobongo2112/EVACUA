import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/evacuation_exit.dart';
import '../../models/evacuation_route.dart';
import '../../models/meeting_point.dart';

class EvacuationRouteService {
  EvacuationRouteService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _building(
    String buildingId,
  ) {
    return _firestore.collection('buildings').doc(buildingId);
  }

  CollectionReference<Map<String, dynamic>> _exits(
    String buildingId,
  ) {
    return _building(buildingId).collection('exits');
  }

  CollectionReference<Map<String, dynamic>> _meetingPoints(
    String buildingId,
  ) {
    return _building(buildingId).collection('meetingPoints');
  }

  CollectionReference<Map<String, dynamic>> _routes(
    String buildingId,
  ) {
    return _building(buildingId).collection('routes');
  }

  Stream<List<EvacuationExit>> watchExits(
    String buildingId, {
    bool onlyActive = false,
  }) {
    Query<Map<String, dynamic>> query = _exits(buildingId);

    if (onlyActive) {
      query = query.where('active', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map(
            (doc) => EvacuationExit.fromMap(
              doc.id,
              buildingId,
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

  Stream<List<MeetingPoint>> watchMeetingPoints(
    String buildingId, {
    bool onlyActive = false,
  }) {
    Query<Map<String, dynamic>> query = _meetingPoints(buildingId);

    if (onlyActive) {
      query = query.where('active', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map(
            (doc) => MeetingPoint.fromMap(
              doc.id,
              buildingId,
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

  Stream<List<EvacuationRoute>> watchRoutes(
    String buildingId, {
    bool onlyActive = false,
  }) {
    Query<Map<String, dynamic>> query = _routes(buildingId);

    if (onlyActive) {
      query = query.where('active', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map(
            (doc) => EvacuationRoute.fromMap(
              doc.id,
              buildingId,
              doc.data(),
            ),
          )
          .toList();

      items.sort((a, b) {
        final byLevel = a.levelName.toLowerCase().compareTo(
              b.levelName.toLowerCase(),
            );
        if (byLevel != 0) {
          return byLevel;
        }

        return a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            );
      });

      return items;
    });
  }

  Future<String> createExit({
    required String buildingId,
    required String levelId,
    required String levelName,
    required String name,
    required String description,
  }) async {
    final document = await _exits(buildingId).add({
      'levelId': levelId.trim(),
      'levelName': levelName.trim(),
      'name': name.trim(),
      'description': description.trim(),
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Future<void> updateExit(
    EvacuationExit exit,
  ) {
    return _exits(exit.buildingId).doc(exit.id).update({
      ...exit.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setExitActive({
    required String buildingId,
    required String exitId,
    required bool active,
  }) {
    return _exits(buildingId).doc(exitId).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> createMeetingPoint({
    required String buildingId,
    required String name,
    required String location,
    required String description,
  }) async {
    final document = await _meetingPoints(buildingId).add({
      'name': name.trim(),
      'location': location.trim(),
      'description': description.trim(),
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Future<void> updateMeetingPoint(
    MeetingPoint point,
  ) {
    return _meetingPoints(point.buildingId).doc(point.id).update({
      ...point.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setMeetingPointActive({
    required String buildingId,
    required String pointId,
    required bool active,
  }) {
    return _meetingPoints(buildingId).doc(pointId).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> createRoute({
    required String buildingId,
    required String levelId,
    required String levelName,
    required String name,
    required String origin,
    required String instructions,
    required String exitId,
    required String exitName,
    required String meetingPointId,
    required String meetingPointName,
  }) async {
    final document = await _routes(buildingId).add({
      'levelId': levelId.trim(),
      'levelName': levelName.trim(),
      'name': name.trim(),
      'origin': origin.trim(),
      'instructions': instructions.trim(),
      'exitId': exitId.trim(),
      'exitName': exitName.trim(),
      'meetingPointId': meetingPointId.trim(),
      'meetingPointName': meetingPointName.trim(),
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Future<void> updateRoute(
    EvacuationRoute route,
  ) {
    return _routes(route.buildingId).doc(route.id).update({
      ...route.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setRouteActive({
    required String buildingId,
    required String routeId,
    required bool active,
  }) {
    return _routes(buildingId).doc(routeId).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
