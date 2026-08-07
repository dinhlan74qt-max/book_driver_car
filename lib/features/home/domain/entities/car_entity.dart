import 'package:equatable/equatable.dart';

class CarEntity extends Equatable {
  final String id;
  final String name;
  final String brand;
  final String vehicleType;
  final String province;
  final String imageIcon;
  final List<String> imageUrls;
  final int pricePerDay;
  final double distanceKm;
  final int seats;
  final double rating;
  final String location;
  // Thông tin thêm cho trang chi tiết
  final String? model;
  final int? year;
  final String? color;
  final String? fuelType;
  final String? transmission;
  final String? description;
  final String? licensePlate;

  const CarEntity({
    required this.id,
    required this.name,
    required this.brand,
    required this.vehicleType,
    required this.province,
    required this.imageIcon,
    this.imageUrls = const [],
    required this.pricePerDay,
    required this.distanceKm,
    required this.seats,
    required this.rating,
    required this.location,
    this.model,
    this.year,
    this.color,
    this.fuelType,
    this.transmission,
    this.description,
    this.licensePlate,
  });

  @override
  List<Object?> get props => [
        id, name, brand, vehicleType, province, imageIcon,
        imageUrls, pricePerDay, distanceKm, seats, rating, location,
        model, year, color, fuelType, transmission, description, licensePlate,
      ];
}
