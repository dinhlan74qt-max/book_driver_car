import 'owner_booking_status.dart';

class OwnerBookingEntity {
  final String id;
  final String bookingCode;
  final String vehicleName;
  final String vehicleImage;
  final String licensePlate;
  final String renterName;
  final String renterPhone;
  final String? renterAvatar;
  final String? contractImage;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int pricePerDay;
  final int totalPrice;
  final BookingStatus status;
  final String? note;
  final DateTime createdAt;

  const OwnerBookingEntity({
    required this.id,
    required this.bookingCode,
    required this.vehicleName,
    required this.vehicleImage,
    required this.licensePlate,
    required this.renterName,
    required this.renterPhone,
    this.renterAvatar,
    this.contractImage,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.pricePerDay,
    required this.totalPrice,
    required this.status,
    this.note,
    required this.createdAt,
  });

  OwnerBookingEntity copyWith({
    String? id,
    String? bookingCode,
    String? vehicleName,
    String? vehicleImage,
    String? licensePlate,
    String? renterName,
    String? renterPhone,
    String? renterAvatar,
    String? contractImage,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    int? pricePerDay,
    int? totalPrice,
    BookingStatus? status,
    String? note,
    DateTime? createdAt,
  }) {
    return OwnerBookingEntity(
      id: id ?? this.id,
      bookingCode: bookingCode ?? this.bookingCode,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleImage: vehicleImage ?? this.vehicleImage,
      licensePlate: licensePlate ?? this.licensePlate,
      renterName: renterName ?? this.renterName,
      renterPhone: renterPhone ?? this.renterPhone,
      renterAvatar: renterAvatar ?? this.renterAvatar,
      contractImage: contractImage ?? this.contractImage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
