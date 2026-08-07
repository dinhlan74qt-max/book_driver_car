class BookingRequestEntity {
  final int vehicleId;
  final DateTime startDate;
  final DateTime endDate;
  final String note;

  BookingRequestEntity({
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.note,
  });
}