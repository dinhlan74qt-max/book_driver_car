class CarMake {
  final String id;
  final String name;

  const CarMake({
    required this.id,
    required this.name,
  });

  factory CarMake.fromJson(Map<String, dynamic> json) {
    return CarMake(
      id: json['id']?.toString() ?? json['make_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['make_display']?.toString() ?? '',
    );
  }
}
