import 'dart:typed_data';

class BookingRequestEntity {
  final int vehicleId;
  final DateTime startDate;
  final DateTime endDate;
  final String note;
  final Uint8List? contractPdfBytes;
  final String? contractPdfFileName;

  BookingRequestEntity({
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.note,
    this.contractPdfBytes,
    this.contractPdfFileName,
  });
}
