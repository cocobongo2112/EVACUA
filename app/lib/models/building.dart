class Building {
  const Building({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.active,
  });

  final String id;
  final String name;
  final String address;
  final String description;
  final bool active;

  factory Building.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return Building(
      id: id,
      name: (data['name'] as String?)?.trim() ?? '',
      address: (data['address'] as String?)?.trim() ?? '',
      description: (data['description'] as String?)?.trim() ?? '',
      active: data['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'address': address.trim(),
      'description': description.trim(),
      'active': active,
    };
  }
}
