import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_status.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/owner_booking_cubit.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/owner_booking_state.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/owner_booking_detail_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/widgets/owner_booking_empty_state.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/widgets/owner_booking_filter_chip.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/widgets/owner_booking_kpi_banner.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/widgets/owner_booking_order_card.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/widgets/owner_booking_shimmer_loading.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class OwnerBookingListScreen extends StatelessWidget {
  final String? initialVehicleName;

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
        : 'Quản lý đơn khách đặt';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTypography.titleLarge.copyWith(color: textPrimary),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<OwnerBookingCubit, OwnerBookingState>(
        builder: (context, state) {
          if (state is OwnerBookingLoading || state is OwnerBookingInitial) {
            return const OwnerBookingShimmerLoading();
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
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      text: 'Thử lại',
                      onPressed: () => context.read<OwnerBookingCubit>().fetchBookings(),
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
              list = list
                  .where((e) => e.vehicleName.toLowerCase().contains(widget.vehicleFilter!.toLowerCase()))
                  .toList();
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
                .where((e) =>
                    e.status == BookingStatus.completed ||
                    e.status == BookingStatus.renting ||
                    e.status == BookingStatus.approved)
                .fold(0, (sum, item) => sum + item.totalPrice);

            return Column(
              children: [
                // ── KPI Summary Banner ──────────────────────────────────────────
                OwnerBookingKpiBanner(
                  totalBookings: state.allBookings.length,
                  pendingCount: pendingCount,
                  totalRevenue: totalRevenue,
                  formatPrice: _formatPrice,
                ),

                // ── Thanh tìm kiếm nhanh ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: isDark ? null : AppColors.shadowSm,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.bodyLarge.copyWith(color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo mã đơn, người thuê, tên xe...',
                        hintStyle: AppTypography.body.copyWith(color: textMuted),
                        prefixIcon: Icon(Icons.search_rounded, color: primaryColor, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, size: 18, color: textMuted),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                // ── Thanh lọc trạng thái (Filter Tabs) ──────────────────────────
                Container(
                  color: bgColor,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        OwnerBookingFilterChip(
                          label: 'Tất cả (${state.allBookings.length})',
                          isSelected: state.filterStatus == null,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(null),
                        ),
                        const SizedBox(width: 8),
                        OwnerBookingFilterChip(
                          label: 'Chờ duyệt ($pendingCount)',
                          isSelected: state.filterStatus == BookingStatus.pending,
                          badgeColor: pendingCount > 0 ? AppColors.accentWarm : null,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(BookingStatus.pending),
                        ),
                        const SizedBox(width: 8),
                        OwnerBookingFilterChip(
                          label: 'Đã duyệt',
                          isSelected: state.filterStatus == BookingStatus.approved,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(BookingStatus.approved),
                        ),
                        const SizedBox(width: 8),
                        OwnerBookingFilterChip(
                          label: 'Đang thuê',
                          isSelected: state.filterStatus == BookingStatus.renting,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(BookingStatus.renting),
                        ),
                        const SizedBox(width: 8),
                        OwnerBookingFilterChip(
                          label: 'Hoàn thành',
                          isSelected: state.filterStatus == BookingStatus.completed,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(BookingStatus.completed),
                        ),
                        const SizedBox(width: 8),
                        OwnerBookingFilterChip(
                          label: 'Từ chối ($rejectedCount)',
                          isSelected: state.filterStatus == BookingStatus.rejected,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(BookingStatus.rejected),
                        ),
                        const SizedBox(width: 8),
                        OwnerBookingFilterChip(
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
                        ? OwnerBookingEmptyState(
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
                              return OwnerBookingOrderCard(
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
}
