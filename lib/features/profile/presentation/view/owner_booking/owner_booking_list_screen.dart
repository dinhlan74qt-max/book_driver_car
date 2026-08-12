import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_status.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/owner_booking_cubit.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/owner_booking_state.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/owner_booking_detail_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/widgets/owner_booking_empty_state.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/widgets/owner_booking_filter_chip.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/widgets/owner_booking_kpi_banner.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/widgets/owner_booking_order_card.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/widgets/owner_booking_shimmer_loading.dart';
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
                        OwnerBookingFilterChip(
                          label: 'Tất cả (${state.allBookings.length})',
                          isSelected: state.filterStatus == null,
                          onTap: () => context.read<OwnerBookingCubit>().filterByStatus(null),
                        ),
                        const SizedBox(width: 8),
                        OwnerBookingFilterChip(
                          label: 'Chờ duyệt ($pendingCount)',
                          isSelected: state.filterStatus == BookingStatus.pending,
                          badgeColor: pendingCount > 0 ? const Color(0xFFFFA000) : null,
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
