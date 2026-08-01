class CarModel {
  final String id;
  final String name;
  final String makeId;
  final String makeName;

  const CarModel({
    required this.id,
    required this.name,
    required this.makeId,
    required this.makeName,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id']?.toString() ?? json['make_model_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['model']?.toString() ?? '',
      makeId: json['make_id']?.toString() ??
          json['model_make_id']?.toString() ??
          '',
      makeName: json['make']?.toString() ??
          json['make_name']?.toString() ??
          '',
    );
  }
}
