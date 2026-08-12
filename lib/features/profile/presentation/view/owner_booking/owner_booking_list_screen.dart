import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_status.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_entity.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/owner_booking_cubit.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/owner_booking_state.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/owner_booking_detail_screen.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class OwnerBookingListScreen extends StatelessWidget {
  final String? initialVehicleName; // Nếu mở từ 1 xe cụ thể

  const OwnerBookingListScreen({super.key, this.initialVehicleName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OwnerBookingCubit>()..fetchBookings(),
      child: _OwnerBookingListContent(vehicleFilter: initialVehicleName),
    );
  }
}

class _OwnerBookingListContent extends StatefulWidget {
  final String? vehicleFilter;

  const _OwnerBookingListContent({this.vehicleFilter});

  @override
  State<_OwnerBookingListContent> createState() => _OwnerBookingListContentState();
}

class _OwnerBookingListContentState extends State<_OwnerBookingListContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatPrice(num price) {
    return NumberFormat.decimalPattern('vi_VN').format(price);
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.vehicleFilter != null
        ? 'Lịch sử thuê: ${widget.vehicleFilter}'
        : 'Quản lý đơn đặt xe';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: BlocBuilder<OwnerBookingCubit, OwnerBookingState>(
        builder: (context, state) {
          if (state is OwnerBookingLoading || state is OwnerBookingInitial) {
            return _buildShimmerLoading();
          }

          if (state is OwnerBookingError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<OwnerBookingCubit>().fetchBookings(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is OwnerBookingLoaded) {
            var list = state.filteredBookings;

            // Lọc theo xe nếu có
            if (widget.vehicleFilter != null) {
              list = list.where((e) => e.vehicleName.toLowerCase().contains(widget.vehicleFilter!.toLowerCase())).toList();
            }

            // Lọc theo ô tìm kiếm
            if (_searchQuery.isNotEmpty) {
              list = list.where((e) {
                return e.bookingCode.toLowerCase().contains(_searchQuery) ||
                    e.renterName.toLowerCase().contains(_searchQuery) ||
                    e.renterPhone.toLowerCase().contains(_searchQuery) ||
                    e.vehicleName.toLowerCase().contains(_searchQuery);
              }).toList();
            }

            final pendingCount = state.countByStatus(BookingStatus.pending);
            final rejectedCount = state.countByStatus(BookingStatus.rejected);
            final cancelledCount = state.countByStatus(BookingStatus.cancelled);
            final num totalRevenue = state.allBookings
                .where((e) => e.status == BookingStatus.completed || e.status == BookingStatus.renting || e.status == BookingStatus.approved)
                .fold(0, (sum, item) => sum + item.totalPrice);

            return Column(
              children: [
                // ── KPI Summary Banner ──────────────────────────────────────────
                _buildKpiBanner(
                  totalBookings: state.allBookings.length,
                  pendingCount: pendingCount,
                  totalRevenue: totalRevenue,
                ),

                // ── Thanh tìm kiếm nhanh ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo mã đơn, khách hàng, tên xe...',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                // ── Thanh lọc trạng thái (Filter Tabs) ──────────────────────────
                Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Tất cả (${state.allBookings.length})',
                          isSelected: state.filterStatus == null,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(null),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Chờ duyệt ($pendingCount)',
                          isSelected: state.filterStatus == BookingStatus.pending,
                          badgeColor: pendingCount > 0 ? const Color(0xFFFFA000) : null,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(BookingStatus.pending),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Đã duyệt',
                          isSelected: state.filterStatus == BookingStatus.approved,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(BookingStatus.approved),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Đang thuê',
                          isSelected: state.filterStatus == BookingStatus.renting,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(BookingStatus.renting),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Hoàn thành',
                          isSelected: state.filterStatus == BookingStatus.completed,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(BookingStatus.completed),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Từ chối ($rejectedCount)',
                          isSelected: state.filterStatus == BookingStatus.rejected,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(BookingStatus.rejected),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Đã huỷ ($cancelledCount)',
                          isSelected: state.filterStatus == BookingStatus.cancelled,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(BookingStatus.cancelled),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),

                // ── Danh sách đơn hàng ──────────────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => context.read<OwnerBookingCubit>().fetchBookings(),
                    color: AppColors.primary,
                    child: list.isEmpty
                        ? _EmptyBookingState(
                            filter: state.filterStatus,
                            isSearching: _searchQuery.isNotEmpty,
                            onReset: () {
                              _searchController.clear();
                              context.read<OwnerBookingCubit>().filterByStatus(null);
                            },
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: list.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final booking = list[index];
                              return _BookingOrderCard(
                                booking: booking,
                                formatPrice: _formatPrice,
                                formatDate: _formatDate,
                                onTap: () async {
                                  final cubit = context.read<OwnerBookingCubit>();
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: cubit,
                                        child: OwnerBookingDetailScreen(booking: booking),
                                      ),
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  await context.read<OwnerBookingCubit>().fetchBookings();
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildKpiBanner({
    required int totalBookings,
    required int pendingCount,
    required num totalRevenue,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildKpiItem(
              label: 'Tổng đơn',
              value: '$totalBookings',
              icon: Icons.receipt_long_rounded,
              iconColor: AppColors.primary,
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.border),
          Expanded(
            child: _buildKpiItem(
              label: 'Chờ duyệt',
              value: '$pendingCount',
              icon: Icons.pending_actions_rounded,
              iconColor: const Color(0xFFFFA000),
              isAlert: pendingCount > 0,
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.border),
          Expanded(
            child: _buildKpiItem(
              label: 'Ước tính thu',
              value: '${_formatPrice(totalRevenue)} đ',
              icon: Icons.account_balance_wallet_rounded,
              iconColor: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    bool isAlert = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isAlert ? const Color(0xFFD32F2F) : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, _) => Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 100, height: 16, color: Colors.black12),
                Container(width: 70, height: 16, color: Colors.black12),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(width: 60, height: 60, color: Colors.black12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: double.infinity, height: 14, color: Colors.black12),
                      const SizedBox(height: 8),
                      Container(width: 120, height: 12, color: Colors.black12),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget Filter Chip ────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (badgeColor != null ? badgeColor!.withValues(alpha: 0.12) : AppColors.background),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (badgeColor ?? AppColors.border),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (badgeColor ?? AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

// ── Widget Thẻ đơn hàng (Order Card) ──────────────────────────────────────────

class _BookingOrderCard extends StatelessWidget {
  final OwnerBookingEntity booking;
  final String Function(num) formatPrice;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  const _BookingOrderCard({
    required this.booking,
    required this.formatPrice,
    required this.formatDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = booking.status;

    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: status == BookingStatus.pending
                ? const Color(0xFFFFA000).withValues(alpha: 0.5)
                : AppColors.border,
            width: status == BookingStatus.pending ? 1.4 : 1.0,
          ),
          boxShadow: [
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
                    const Icon(Icons.receipt_rounded, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      booking.bookingCode,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: status.color.withValues(alpha: 0.3)),
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
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),

            // Body: Ảnh xe + Thông tin xe + Khách thuê
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: booking.vehicleImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: booking.vehicleImage,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary),
                            ),
                          )
                        : Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary),
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          booking.licensePlate,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7D5A00),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${booking.renterName} • ${booking.renterPhone}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${formatDate(booking.startDate)} - ${formatDate(booking.endDate)} (${booking.totalDays} ngày)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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
                    const Text('Tổng tiền thu về', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text(
                      '${formatPrice(booking.totalPrice)} đ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
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
                          color: const Color(0xFFFFA000),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Cần duyệt',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    const Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
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

// ── Widget Empty State ────────────────────────────────────────────────────────

class _EmptyBookingState extends StatelessWidget {
  final BookingStatus? filter;
  final bool isSearching;
  final VoidCallback onReset;

  const _EmptyBookingState({
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
