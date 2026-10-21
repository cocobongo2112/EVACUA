class MeetingPoint {
  const MeetingPoint({
    required this.id,
    required this.buildingId,
    required this.name,
    required this.location,
    required this.description,
    required this.active,
  });

  final String id;
  final String buildingId;
  final String name;
  final String location;
  final String description;
  final bool active;

  factory MeetingPoint.fromMap(
    String id,
    String buildingId,
    Map<String, dynamic> data,
  ) {
    return MeetingPoint(
      id: id,
      buildingId: buildingId,
      name: (data['name'] as String?)?.trim() ?? '',
      location: (data['location'] as String?)?.trim() ?? '',
      description: (data['description'] as String?)?.trim() ?? '',
      active: data['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'location': location.trim(),
      'description': description.trim(),
      'active': active,
    };
  }
}
