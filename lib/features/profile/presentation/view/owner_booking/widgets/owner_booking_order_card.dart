import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_entity.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_status.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OwnerBookingOrderCard extends StatelessWidget {
  final OwnerBookingEntity booking;
  final String Function(num) formatPrice;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  const OwnerBookingOrderCard({
    super.key,
    required this.booking,
    required this.formatPrice,
    required this.formatDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = booking.status;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final surfaceSecondary = isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: status == BookingStatus.pending
                ? (isDark ? AppColors.darkAccent : AppColors.accent)
                : borderColor,
            width: status == BookingStatus.pending ? 1.4 : 1.0,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Mã đơn + Badge trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_rounded, size: 16, color: textMuted),
                    const SizedBox(width: 6),
                    Text(
                      booking.bookingCode,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: status.color.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(status.icon, size: 13, color: status.color),
                      const SizedBox(width: 4),
                      Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: status.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: borderColor),
            const SizedBox(height: 12),

            // Body: Ảnh xe + Thông tin xe + Khách thuê
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: booking.vehicleImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: booking.vehicleImage,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: primaryColor.withValues(alpha: 0.08),
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: primaryColor.withValues(alpha: 0.1),
                              child: Icon(Icons.directions_car_filled_rounded, color: primaryColor),
                            ),
                          )
                        : Container(
                            color: primaryColor.withValues(alpha: 0.1),
                            child: Icon(Icons.directions_car_filled_rounded, color: primaryColor),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.vehicleName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          booking.licensePlate,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 14, color: textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${booking.renterName} • ${booking.renterPhone}',
                              style: TextStyle(fontSize: 12, color: textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lịch thuê xe
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${formatDate(booking.startDate)} - ${formatDate(booking.endDate)} (${booking.totalDays} ngày)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Footer: Tổng tiền + Nút xem chi tiết
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tổng tiền thu về', style: TextStyle(fontSize: 11, color: textMuted)),
                    Text(
                      '${formatPrice(booking.totalPrice)} đ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (status == BookingStatus.pending)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkAccent : AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Cần duyệt',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: primaryColor),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
