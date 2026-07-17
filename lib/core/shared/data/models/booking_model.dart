enum BookingStatus { ongoing, completed, cancelled, pending }

class Booking {
  final String id;
  final String carName;
  final DateTime startDate;
  final DateTime endDate;
  final int totalPrice;
  final BookingStatus status;

  const Booking({
    required this.id,
    required this.carName,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case BookingStatus.ongoing:
        return 'Đang thuê';
      case BookingStatus.completed:
        return 'Hoàn thành';
      case BookingStatus.cancelled:
        return 'Đã hủy';
      case BookingStatus.pending:
        return 'Chờ xác nhận';
    }
  }
}