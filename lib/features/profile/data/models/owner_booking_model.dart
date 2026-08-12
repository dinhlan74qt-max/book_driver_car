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
    super.contractImage,
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
    // 1. Parse Dates
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

    // 2. Parse User & Vehicle object from API response
    final user = json['user'] is Map ? json['user'] as Map<String, dynamic> : null;
    final vehicle = json['vehicle'] is Map ? json['vehicle'] as Map<String, dynamic> : null;

    final vehicleName = vehicle?['vehicleName']?.toString() ??
        json['vehicleName']?.toString() ??
        json['vehicle_name']?.toString() ??
        'Xe tự lái';

    String vehicleImage = '';
    if (vehicle?['imageUrls'] is List && (vehicle!['imageUrls'] as List).isNotEmpty) {
      vehicleImage = (vehicle['imageUrls'] as List).first.toString();
    } else {
      vehicleImage = json['vehicleImage']?.toString() ?? json['image']?.toString() ?? '';
    }

    final licensePlate = vehicle?['licensePlate']?.toString() ??
        json['licensePlate']?.toString() ??
        json['license_plate']?.toString() ??
        'Chưa có biển số';

    final renterName = user?['fullname']?.toString() ??
        json['renterName']?.toString() ??
        json['customerName']?.toString() ??
        'Khách thuê';

    final renterPhone = user?['phone']?.toString() ??
        json['renterPhone']?.toString() ??
        json['phone']?.toString() ??
        '0905 123 456';

    final contractImage = json['contractImage']?.toString() ??
        json['contractUrl']?.toString() ??
        json['contractPdfUrl']?.toString();

    int safeInt(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? fallback;
    }

    final int diffDays = end.difference(start).inDays < 1 ? 1 : end.difference(start).inDays;
    final int totalDays = (() {
      final d = safeInt(json['totalDays']);
      if (d > 0) return d;
      final d2 = safeInt(json['days']);
      return d2 > 0 ? d2 : diffDays;
    })();

    final int pricePerDay = (() {
      final p = safeInt(vehicle?['pricePerDay']);
      if (p > 0) return p;
      final p2 = safeInt(json['pricePerDay']);
      return p2 > 0 ? p2 : 1200000;
    })();

    final int totalPrice = (() {
      final t = safeInt(json['totalAmount']);
      if (t > 0) return t;
      final t2 = safeInt(json['totalPrice']);
      if (t2 > 0) return t2;
      final t3 = safeInt(json['amount']);
      return t3 > 0 ? t3 : pricePerDay * totalDays;
    })();


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
      contractImage: contractImage?.trim().isNotEmpty == true ? contractImage : null,
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
      'contractImage': contractImage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'pricePerDay': pricePerDay,
      'totalAmount': totalPrice,
      'status': status.code,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
