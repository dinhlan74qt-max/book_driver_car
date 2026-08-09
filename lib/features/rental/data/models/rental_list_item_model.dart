import '../../domain/entities/rental_list_item_entity.dart';
import 'rental_vehicle_model.dart';

class RentalListItemModel extends RentalListItemEntity {
  RentalListItemModel({
    required super.id,
    required super.bookingCode,
    super.createdAt,
    required super.startDate,
    required super.endDate,
    required super.status,
    required super.totalAmount,
    required super.totalDays,
    super.pricePerDay,
    required super.vehicle,
  });

  factory RentalListItemModel.fromJson(Map<String, dynamic> json) {
    final vehicleJson = json['vehicle'] is Map
        ? Map<String, dynamic>.from(json['vehicle'] as Map)
        : <String, dynamic>{};

    return RentalListItemModel(
      id: json['id'] as int? ?? 0,
      bookingCode: json['bookingCode'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
      totalDays: (json['totalDays'] as num?)?.toInt() ?? 0,
      pricePerDay: (json['pricePerDay'] as num?)?.toInt(),
      vehicle: RentalVehicleModel.fromJson(vehicleJson),
    );
  }
}
