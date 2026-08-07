import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  BookingModel({
    required super.id,
    required super.vehicleId,
    required super.startDate,
    required super.endDate,
    required super.note,
    required super.status,
  });

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse('$value') ?? fallback;
  }

  static DateTime _parseDate(dynamic value, {DateTime? fallback}) {
    final parsed = value == null ? null : DateTime.tryParse('$value');
    return parsed ?? fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory BookingModel.fromJson(
    Map<String, dynamic> json, {
    int fallbackVehicleId = 0,
    DateTime? fallbackStartDate,
    DateTime? fallbackEndDate,
    String fallbackNote = '',
    String fallbackStatus = '',
  }) {
    return BookingModel(
      id: _parseInt(json['id']),
      vehicleId: _parseInt(json['vehicleId'], fallback: fallbackVehicleId),
      startDate: _parseDate(json['startDate'], fallback: fallbackStartDate),
      endDate: _parseDate(json['endDate'], fallback: fallbackEndDate),
      note: json['note']?.toString() ?? fallbackNote,
      status: json['status']?.toString() ?? fallbackStatus,
    );
  }
}
