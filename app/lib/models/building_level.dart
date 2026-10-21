class BuildingLevel {
  const BuildingLevel({
    required this.id,
    required this.buildingId,
    required this.name,
    required this.number,
    required this.description,
    required this.planUrl,
    required this.active,
  });

  final String id;
  final String buildingId;
  final String name;
  final int number;
  final String description;
  final String planUrl;
  final bool active;

  factory BuildingLevel.fromMap(
    String id,
    String buildingId,
    Map<String, dynamic> data,
  ) {
    return BuildingLevel(
      id: id,
      buildingId: buildingId,
      name: (data['name'] as String?)?.trim() ?? '',
      number: (data['number'] as num?)?.toInt() ?? 0,
      description: (data['description'] as String?)?.trim() ?? '',
      planUrl: (data['planUrl'] as String?)?.trim() ?? '',
      active: data['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'number': number,
      'description': description.trim(),
      'planUrl': planUrl.trim(),
      'active': active,
    };
  }
}
