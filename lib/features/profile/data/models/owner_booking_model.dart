import 'package:book_drive_car/features/profile/domain/entities/owner_booking_entity.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_status.dart';

class OwnerBookingModel extends OwnerBookingEntity {
  const OwnerBookingModel({
    required super.id,
    required super.bookingCode,
    required super.vehicleName,
    required super.vehicleImage,
    required super.licensePlate,
    required super.renterName,
    required super.renterPhone,
    super.renterAvatar,
    required super.startDate,
    required super.endDate,
    required super.totalDays,
    required super.pricePerDay,
    required super.totalPrice,
    required super.status,
    super.note,
    required super.createdAt,
  });

  factory OwnerBookingModel.fromJson(Map<String, dynamic> json) {
    DateTime start = DateTime.now();
    DateTime end = DateTime.now().add(const Duration(days: 1));
    DateTime created = DateTime.now();

    if (json['startDate'] != null) {
      start = DateTime.tryParse(json['startDate'].toString()) ?? start;
    } else if (json['start_date'] != null) {
      start = DateTime.tryParse(json['start_date'].toString()) ?? start;
    }

    if (json['endDate'] != null) {
      end = DateTime.tryParse(json['endDate'].toString()) ?? end;
    } else if (json['end_date'] != null) {
      end = DateTime.tryParse(json['end_date'].toString()) ?? end;
    }

    if (json['createdAt'] != null) {
      created = DateTime.tryParse(json['createdAt'].toString()) ?? created;
    } else if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'].toString()) ?? created;
    }

    final vehicle = json['vehicle'] is Map ? json['vehicle'] as Map<String, dynamic> : null;
    final user = json['user'] is Map ? json['user'] as Map<String, dynamic> : null;

    final vehicleName = vehicle?['vehicleName']?.toString() ??
        json['vehicleName']?.toString() ??
        json['vehicle_name']?.toString() ??
        'Xe tự lái';

    final vehicleImage = vehicle?['imageUrls'] is List && (vehicle!['imageUrls'] as List).isNotEmpty
        ? (vehicle['imageUrls'] as List).first.toString()
        : json['vehicleImage']?.toString() ?? json['image']?.toString() ?? '';

    final licensePlate = vehicle?['licensePlate']?.toString() ??
        json['licensePlate']?.toString() ??
        json['license_plate']?.toString() ??
        '43A-999.99';

    final renterName = user?['fullname']?.toString() ??
        json['renterName']?.toString() ??
        json['renter_name']?.toString() ??
        json['customerName']?.toString() ??
        'Khách thuê';

    final renterPhone = user?['phone']?.toString() ??
        json['renterPhone']?.toString() ??
        json['renter_phone']?.toString() ??
        json['phone']?.toString() ??
        '0905 123 456';

    final totalDays = (json['totalDays'] as num?)?.toInt() ??
        (json['days'] as num?)?.toInt() ??
        (end.difference(start).inDays < 1 ? 1 : end.difference(start).inDays);

    final pricePerDay = (json['pricePerDay'] as num?)?.toInt() ??
        (vehicle?['pricePerDay'] as num?)?.toInt() ??
        800000;

    final totalPrice = (json['totalPrice'] as num?)?.toInt() ??
        (json['amount'] as num?)?.toInt() ??
        (pricePerDay * totalDays);

    return OwnerBookingModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      bookingCode: json['bookingCode']?.toString() ??
          json['code']?.toString() ??
          'BK-${(json['id'] ?? '8888').toString().padLeft(4, '0')}',
      vehicleName: vehicleName,
      vehicleImage: vehicleImage,
      licensePlate: licensePlate,
      renterName: renterName,
      renterPhone: renterPhone,
      renterAvatar: user?['avatar']?.toString() ?? json['renterAvatar']?.toString(),
      startDate: start,
      endDate: end,
      totalDays: totalDays,
      pricePerDay: pricePerDay,
      totalPrice: totalPrice,
      status: BookingStatus.fromString(json['status']?.toString()),
      note: json['note']?.toString() ?? json['description']?.toString(),
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingCode': bookingCode,
      'vehicleName': vehicleName,
      'vehicleImage': vehicleImage,
      'licensePlate': licensePlate,
      'renterName': renterName,
      'renterPhone': renterPhone,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'pricePerDay': pricePerDay,
      'totalPrice': totalPrice,
      'status': status.code,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
