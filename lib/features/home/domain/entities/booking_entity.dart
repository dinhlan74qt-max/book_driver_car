class BookingEntity {
  final int id;
  final int vehicleId;
  final DateTime startDate;
  final DateTime endDate;
  final String note;
  final String status; // ví dụ:  PENDING, APPROVED, REJECTED, RENTING, COMPLETED, CANCELLED

  BookingEntity({
    required this.id,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.note,
    required this.status,
  });
}