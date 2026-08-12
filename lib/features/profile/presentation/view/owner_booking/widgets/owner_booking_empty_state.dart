import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_status.dart';
import 'package:flutter/material.dart';

class OwnerBookingEmptyState extends StatelessWidget {
  final BookingStatus? filter;
  final bool isSearching;
  final VoidCallback onReset;

  const OwnerBookingEmptyState({
    super.key,
    this.filter,
    this.isSearching = false,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.receipt_long_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'Không tìm thấy đơn hàng phù hợp'
                  : (filter != null ? 'Chưa có đơn ở trạng thái "${filter!.label}"' : 'Chưa có đơn đặt thuê nào'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? 'Vui lòng thử tìm với từ khóa hoặc tên khách hàng khác.'
                  : 'Khi khách hàng đặt thuê xe của bạn, các đơn hàng sẽ xuất hiện tại đây.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),
            if (filter != null || isSearching) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onReset,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isSearching ? 'Xóa tìm kiếm' : 'Xem tất cả đơn'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
