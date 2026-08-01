class CarTrim {
  final String id;
  final String name;
  final int? year;
  final int? seats;
  final String fuel;
  final String transmission;

  const CarTrim({
    required this.id,
    required this.name,
    required this.year,
    required this.seats,
    required this.fuel,
    required this.transmission,
  });

  factory CarTrim.fromJson(Map<String, dynamic> json) {
    final body = json['make_model_trim_body'];
    final engine = json['make_model_trim_engine'];
    final trim = json['make_model_trim'];

    int? parseInt(dynamic value) => int.tryParse(value?.toString() ?? '');

    return CarTrim(
      id: json['id']?.toString() ??
          json['make_model_trim_id']?.toString() ??
          '',
      name: json['name']?.toString() ??
          json['trim']?.toString() ??
          json['model_trim']?.toString() ??
          json['description']?.toString() ??
          '',
      year: parseInt(json['year'] ?? json['model_year'] ?? trim?['year']),
      seats: parseInt(
        body is Map ? body['seats'] : json['seats'] ?? json['model_seats'],
      ),
      fuel: (engine is Map
              ? engine['fuel_type']
              : json['fuel_type'] ?? json['model_engine_fuel'])
          ?.toString() ??
          '',
      transmission: (engine is Map
              ? engine['transmission']
              : json['transmission'] ?? json['model_transmission_type'])
          ?.toString() ??
          '',
    );
  }
}
