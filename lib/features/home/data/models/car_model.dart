import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';

class CarModel extends CarEntity {
  const CarModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.vehicleType,
    required super.province,
    required super.imageIcon,
    super.imageUrls = const [],
    required super.pricePerDay,
    required super.distanceKm,
    required super.seats,
    required super.rating,
    required super.location,
    super.model,
    super.year,
    super.color,
    super.fuelType,
    super.transmission,
    super.description,
    super.licensePlate,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    // Lấy tất cả imageUrls
    final List<String> imageUrls = [];
    final rawImages = json['imageUrls'];
    if (rawImages is List) {
      for (final img in rawImages) {
        if (img is String && img.isNotEmpty) imageUrls.add(img);
      }
    }
    final imageIcon = imageUrls.isNotEmpty ? imageUrls[0] : '';

    // Xử lý address
    String province = '';
    String fullLocation = '';
    final address = json['address'];
    if (address is Map<String, dynamic>) {
      province = address['city']?.toString() ?? '';
      final detail = address['addressDetail']?.toString() ?? '';
      final ward = address['ward']?.toString() ?? '';
      final city = address['city']?.toString() ?? '';
      fullLocation = [detail, ward, city].where((e) => e.isNotEmpty).join(', ');
    }

    return CarModel(
      id: json['id']?.toString() ?? '',
      name: json['vehicleName']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      vehicleType: json['vehicleType']?.toString() ?? '',
      province: province,
      imageIcon: imageIcon,
      imageUrls: imageUrls,
      pricePerDay: (json['pricePerDay'] as num?)?.toInt() ?? 0,
      distanceKm: (json['Distance'] as num?)?.toDouble() ?? 0.0,
      seats: json['seatCount'] as int? ?? 4,
      rating: 4.8,
      location: fullLocation,
      model: json['model']?.toString(),
      year: (json['year'] as num?)?.toInt(),
      color: json['color']?.toString(),
      fuelType: json['fuelType']?.toString(),
      transmission: json['transmission']?.toString(),
      description: json['description']?.toString(),
      licensePlate: json['licensePlate']?.toString(),
    );
  }
}
