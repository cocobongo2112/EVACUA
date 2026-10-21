class EvacuationRoute {
  const EvacuationRoute({
    required this.id,
    required this.buildingId,
    required this.levelId,
    required this.levelName,
    required this.name,
    required this.origin,
    required this.instructions,
    required this.exitId,
    required this.exitName,
    required this.meetingPointId,
    required this.meetingPointName,
    required this.active,
  });

  final String id;
  final String buildingId;
  final String levelId;
  final String levelName;
  final String name;
  final String origin;
  final String instructions;
  final String exitId;
  final String exitName;
  final String meetingPointId;
  final String meetingPointName;
  final bool active;

  factory EvacuationRoute.fromMap(
    String id,
    String buildingId,
    Map<String, dynamic> data,
  ) {
    return EvacuationRoute(
      id: id,
      buildingId: buildingId,
      levelId: (data['levelId'] as String?)?.trim() ?? '',
      levelName: (data['levelName'] as String?)?.trim() ?? '',
      name: (data['name'] as String?)?.trim() ?? '',
      origin: (data['origin'] as String?)?.trim() ?? '',
      instructions: (data['instructions'] as String?)?.trim() ?? '',
      exitId: (data['exitId'] as String?)?.trim() ?? '',
      exitName: (data['exitName'] as String?)?.trim() ?? '',
      meetingPointId: (data['meetingPointId'] as String?)?.trim() ?? '',
      meetingPointName: (data['meetingPointName'] as String?)?.trim() ?? '',
      active: data['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId.trim(),
      'levelName': levelName.trim(),
      'name': name.trim(),
      'origin': origin.trim(),
      'instructions': instructions.trim(),
      'exitId': exitId.trim(),
      'exitName': exitName.trim(),
      'meetingPointId': meetingPointId.trim(),
      'meetingPointName': meetingPointName.trim(),
      'active': active,
    };
  }
}
