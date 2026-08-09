import 'rental_vehicle_entity.dart';

class RentalListItemEntity {
  final int id;
  final String bookingCode;
  final DateTime? createdAt;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final int totalAmount;
  final int totalDays;
  final int? pricePerDay;
  final RentalVehicleEntity vehicle;

  RentalListItemEntity({
    required this.id,
    required this.bookingCode,
    this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalAmount,
    required this.totalDays,
    this.pricePerDay,
    required this.vehicle,
  });
}
