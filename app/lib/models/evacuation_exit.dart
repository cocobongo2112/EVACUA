class EvacuationExit {
  const EvacuationExit({
    required this.id,
    required this.buildingId,
    required this.levelId,
    required this.levelName,
    required this.name,
    required this.description,
    required this.active,
  });

  final String id;
  final String buildingId;
  final String levelId;
  final String levelName;
  final String name;
  final String description;
  final bool active;

  factory EvacuationExit.fromMap(
    String id,
    String buildingId,
    Map<String, dynamic> data,
  ) {
    return EvacuationExit(
      id: id,
      buildingId: buildingId,
      levelId: (data['levelId'] as String?)?.trim() ?? '',
      levelName: (data['levelName'] as String?)?.trim() ?? '',
      name: (data['name'] as String?)?.trim() ?? '',
      description: (data['description'] as String?)?.trim() ?? '',
      active: data['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId.trim(),
      'levelName': levelName.trim(),
      'name': name.trim(),
      'description': description.trim(),
      'active': active,
    };
  }
}
