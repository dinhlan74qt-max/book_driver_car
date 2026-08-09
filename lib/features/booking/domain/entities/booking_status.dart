import 'package:flutter/material.dart';

enum BookingStatus {
  pending('PENDING', 'Chờ duyệt', Color(0xFFFFA000), Icons.hourglass_top_rounded),
  approved('APPROVED', 'Đã duyệt', Color(0xFF1976D2), Icons.check_circle_outline_rounded),
  rejected('REJECTED', 'Đã từ chối', Color(0xFFD32F2F), Icons.cancel_outlined),
  renting('RENTING', 'Đang thuê', Color(0xFF7B1FA2), Icons.directions_car_rounded),
  completed('COMPLETED', 'Hoàn thành', Color(0xFF388E3C), Icons.verified_rounded),
  cancelled('CANCELLED', 'Đã huỷ', Color(0xFF757575), Icons.block_rounded);

  final String code;
  final String label;
  final Color color;
  final IconData icon;

  const BookingStatus(this.code, this.label, this.color, this.icon);

  static BookingStatus fromString(String? code) {
    return BookingStatus.values.firstWhere(
      (e) => e.code == code?.toUpperCase(),
      orElse: () => BookingStatus.pending,
    );
  }
}