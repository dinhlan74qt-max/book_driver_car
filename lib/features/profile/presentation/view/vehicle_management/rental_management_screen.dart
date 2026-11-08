import 'dart:async';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/profile/domain/entities/verification_entity.dart';
import 'package:book_drive_car/features/profile/domain/repositories/verification_repository.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/identity_verification_screen.dart';
import 'package:book_drive_car/features/profile/domain/entities/vehicle_entity.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/my_vehicles_bloc.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/my_vehicles_event.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/my_vehicles_state.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/owner_booking_list_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/vehicle_management/vehicle_detail_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/vehicle_management/vehicle_registration_screen.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_empty_state.dart';
import 'package:book_drive_car/shared/widget/app_shimmer.dart';
import 'package:book_drive_car/shared/widget/app_status_badge.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/staggered_fade_in.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RentalManagementScreen extends StatefulWidget {
  const RentalManagementScreen({super.key});

  @override
  State<RentalManagementScreen> createState() => _RentalManagementScreenState();
}

class _RentalManagementScreenState extends State<RentalManagementScreen> {
  late final MyVehiclesBloc _myVehiclesBloc;
  List<VehicleEntity> _vehiclesCache = [];
  String? _errorMessage;
  Completer<void>? _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _myVehiclesBloc = sl<MyVehiclesBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _myVehiclesBloc.add(const MyVehiclesRequested());
      }
    });
  }

  @override
  void dispose() {
    _myVehiclesBloc.close();
    super.dispose();
  }

  Future<void> _openRegistration() async {
    // Kiểm tra trạng thái KYC trước khi cho phép vào màn hình đăng ký xe
    try {
      final vRepo = sl<VerificationRepository>();
      final vData = await vRepo.syncVerification();
      if (vData.status != VerificationStatus.verified) {
        if (!mounted) return;
        if (vData.status == VerificationStatus.pending) {
          AppToast.show(
            context,
            message:
                'Hồ sơ KYC đang chờ kiểm duyệt. Vui lòng chờ phê duyệt trước khi tạo xe.',
            type: AppToastType.info,
            duration: const Duration(seconds: 4),
          );
        } else {
          AppToast.show(
            context,
            message:
                'Vui lòng hoàn tất xác thực danh tính (KYC) trước khi tạo xe.',
            type: AppToastType.warning,
            duration: const Duration(seconds: 4),
          );
        }
        return;
      }
    } catch (e) {
      debugPrint('[RentalManagement] KYC check failed: $e');
    }

    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(builder: (_) => const VehicleRegistrationScreen()),
    );

    if (!mounted) return;

    if (result == 'timeout') {
      AppToast.show(
        context,
        message:
            'Dữ liệu đã được gửi đi, nếu chưa hiển thị vui lòng kéo để tải lại.',
        type: AppToastType.info,
      );
      _myVehiclesBloc.add(const MyVehiclesRequested());
      return;
    }

    if (result is VehicleEntity) {
      AppToast.show(
        context,
        message: 'Tạo xe thành công! Xe đã được thêm vào danh sách quản lý.',
        type: AppToastType.success,
        duration: const Duration(seconds: 4),
      );
    }
    _myVehiclesBloc.add(const MyVehiclesRequested());
  }

  Future<void> _openVehicleDetail(VehicleEntity vehicle) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicle: vehicle)),
    );
  }

  Future<void> _refreshVehicles() {
    final completer = Completer<void>();
    _refreshCompleter = completer;
    _myVehiclesBloc.add(const MyVehiclesRequested());
    return completer.future;
  }

  void _openBookingHistory({String? vehicleName}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OwnerBookingListScreen(initialVehicleName: vehicleName),
      ),
    );
  }

  String _formatPrice(num price) {
    return NumberFormat.decimalPattern('vi_VN').format(price);
  }

  String _vehicleSubtitle(VehicleEntity vehicle) {
    final parts = <String>[
      if (vehicle.brand.isNotEmpty) vehicle.brand,
      if (vehicle.model.isNotEmpty) vehicle.model,
      if (vehicle.year > 0) vehicle.year.toString(),
    ];
    return parts.join(' • ');
  }

  String? _vehicleLocation(VehicleEntity vehicle) {
    final parts = [
      vehicle.address.addressDetail,
      vehicle.address.ward,
      vehicle.address.district,
      vehicle.address.city,
    ].where((part) => part.trim().isNotEmpty).toList();

    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _myVehiclesBloc,
      child: BlocListener<MyVehiclesBloc, MyVehiclesState>(
        listener: (context, state) {
          if (state is MyVehiclesLoaded) {
            _vehiclesCache = state.vehicles;
            _errorMessage = null;
            if (_refreshCompleter != null &&
                !(_refreshCompleter?.isCompleted ?? true)) {
              _refreshCompleter?.complete();
            }
          }

          if (state is MyVehiclesFailure) {
            _errorMessage = state.error;
            if (_refreshCompleter != null &&
                !(_refreshCompleter?.isCompleted ?? true)) {
              _refreshCompleter?.complete();
            }
            AppToast.show(
              context,
              message: state.error,
              type: AppToastType.error,
            );
          }
        },
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final bgColor = isDark
                ? AppColors.darkBackground
                : AppColors.background;
            final surfaceColor = isDark
                ? AppColors.darkSurface
                : AppColors.surface;
            final borderColor = isDark
                ? AppColors.darkBorder
                : AppColors.border;
            final primaryColor = isDark
                ? AppColors.darkPrimary
                : AppColors.primary;
            final textPrimary = isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary;

            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: surfaceColor,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  'Quản lý xe cho thuê',
                  style: AppTypography.titleLarge.copyWith(color: textPrimary),
                ),
                actions: [
                  TapScale(
                    onTap: () => _openBookingHistory(),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkPrimaryContainer
                            : AppColors.primaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 16,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Đơn thuê',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refreshVehicles,
                  child: BlocBuilder<MyVehiclesBloc, MyVehiclesState>(
                    builder: (context, state) {
                      final vehicles = state is MyVehiclesLoaded
                          ? state.vehicles
                          : _vehiclesCache;
                      final bool initialLoading =
                          state is MyVehiclesLoading && vehicles.isEmpty;
                      final bool refreshing =
                          state is MyVehiclesLoading && vehicles.isNotEmpty;

                      final totalCount = vehicles.length;
                      final availableCount = vehicles.where((v) {
                        final s = v.status.toUpperCase().trim();
                        return s == 'AVAILABLE' ||
                            s == 'APPROVED' ||
                            s == 'ACTIVE' ||
                            s == 'ĐÃ DUYỆT';
                      }).length;
                      final pendingCount = vehicles.where((v) {
                        final s = v.status.toUpperCase().trim();
                        return s == 'PENDING' ||
                            s == 'WAITING' ||
                            s == 'CHỜ DUYỆT' ||
                            s == 'ĐANG CHỜ DUYỆT' ||
                            s.isEmpty ||
                            s == 'NULL';
                      }).length;
                      final blockedCount = vehicles.where((v) {
                        final s = v.status.toUpperCase().trim();
                        return s == 'REJECTED' ||
                            s == 'UNAVAILABLE' ||
                            s == 'BLOCKED' ||
                            s == 'DENIED' ||
                            s == 'TỪ CHỐI' ||
                            s == 'TẠM ẨN';
                      }).length;

                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                        children: [
                          if (refreshing) ...[
                            const ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(999),
                              ),
                              child: LinearProgressIndicator(
                                minHeight: 2.5,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Hero KPI Card
                          StaggeredFadeIn(
                            index: 0,
                            child: _RentalFleetHero(
                              totalCount: totalCount,
                              availableCount: availableCount,
                              pendingCount: pendingCount,
                              blockedCount: blockedCount,
                              onAddVehicle: _openRegistration,
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (initialLoading)
                            Column(
                              children: List.generate(
                                3,
                                (_) => const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: AppShimmer(
                                    width: double.infinity,
                                    height: 160,
                                    borderRadius: 20,
                                  ),
                                ),
                              ),
                            )
                          else if (_errorMessage != null && vehicles.isEmpty)
                            AppEmptyState(
                              icon: Icons.error_outline_rounded,
                              title: 'Không tải được danh sách xe',
                              subtitle: _errorMessage!,
                              buttonText: 'Thử lại',
                              onButtonPressed: _refreshVehicles,
                            )
                          else if (vehicles.isEmpty)
                            AppEmptyState(
                              icon: Icons.directions_car_filled_rounded,
                              title: 'Chưa có xe nào được đăng ký',
                              subtitle:
                                  'Hãy tạo hồ sơ chiếc xe đầu tiên để bắt đầu nhận đơn và quản lý doanh thu cho thuê.',
                              buttonText: 'Đăng ký xe ngay',
                              onButtonPressed: _openRegistration,
                            )
                          else ...[
                            StaggeredFadeIn(
                              index: 1,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Danh sách xe sở hữu',
                                    style: AppTypography.titleLarge,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      '$totalCount xe',
                                      style: AppTypography.caption.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...vehicles.asMap().entries.map((entry) {
                              final index = entry.key;
                              final vehicle = entry.value;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: StaggeredFadeIn(
                                  index: 2 + index,
                                  child: _VehicleFleetCard(
                                    vehicle: vehicle,
                                    subtitle: _vehicleSubtitle(vehicle),
                                    location: _vehicleLocation(vehicle),
                                    priceFormatted: _formatPrice(
                                      vehicle.pricePerDay,
                                    ),
                                    onTap: () => _openVehicleDetail(vehicle),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RentalFleetHero extends StatelessWidget {
  final int totalCount;
  final int availableCount;
  final int pendingCount;
  final int blockedCount;
  final VoidCallback onAddVehicle;

  const _RentalFleetHero({
    required this.totalCount,
    required this.availableCount,
    required this.pendingCount,
    required this.blockedCount,
    required this.onAddVehicle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF06111C), Color(0xFF0B1F33), Color(0xFF13324F)]
              : const [Color(0xFF082236), AppColors.primary, Color(0xFF1B4F72)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withValues(
              alpha: 0.28,
            ),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: AppColors.accentWarm,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Trung tâm đối tác CarNow',
                      style: AppTypography.dataLabel.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.directions_car_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Quản lý xe & Lợi nhuận',
            style: AppTypography.display.copyWith(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Theo dõi trạng thái duyệt xe, biểu phí theo ngày và cập nhật thông tin phương tiện.',
            style: AppTypography.body.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _HeroMetricTile(label: '$totalCount', caption: 'Tổng xe'),
              const SizedBox(width: 8),
              _HeroMetricTile(label: '$availableCount', caption: 'Đã duyệt'),
              const SizedBox(width: 8),
              _HeroMetricTile(label: '$pendingCount', caption: 'Chờ duyệt'),
              const SizedBox(width: 8),
              _HeroMetricTile(label: '$blockedCount', caption: 'Tạm ẩn'),
            ],
          ),
          const SizedBox(height: 18),
          AppButton(
            text: 'Đăng ký thêm xe mới',
            height: 48,
            width: double.infinity,
            variant: AppButtonVariant.secondary,
            onPressed: onAddVehicle,
          ),
        ],
      ),
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  final String label;
  final String caption;

  const _HeroMetricTile({required this.label, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.priceLarge.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleFleetCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final String subtitle;
  final String? location;
  final String priceFormatted;
  final VoidCallback onTap;

  const _VehicleFleetCard({
    required this.vehicle,
    required this.subtitle,
    required this.location,
    required this.priceFormatted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final iconBg = isDark
        ? AppColors.darkPrimaryContainer
        : AppColors.primaryContainer.withValues(alpha: 0.6);

    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? null : AppColors.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Icon(
                    Icons.directions_car_filled_rounded,
                    color: primaryColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.vehicleName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.caption.copyWith(
                          color: textSecondary,
                        ),
                      ),
                      if (vehicle.licensePlate.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Biển số: ${vehicle.licensePlate}',
                          style: AppTypography.dataLabel.copyWith(
                            color: textPrimary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AppStatusBadge.fromVehicleStatus(vehicle.status),
              ],
            ),
            Divider(height: 20, color: borderColor),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _FleetChip(label: '${vehicle.seatCount} chỗ'),
                      _FleetChip(
                        label:
                            vehicle.transmission.toLowerCase().contains(
                              'tự động',
                            )
                            ? 'Tự động'
                            : (vehicle.transmission.toLowerCase().contains(
                                    'sàn',
                                  )
                                  ? 'Số sàn'
                                  : vehicle.transmission),
                      ),
                      _FleetChip(label: vehicle.fuelType),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                    text: priceFormatted,
                    style: AppTypography.priceMedium.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: ' đ/ngày',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (location != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 16, color: textMuted),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FleetChip extends StatelessWidget {
  final String label;

  const _FleetChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark
        ? AppColors.darkSurfaceSecondary
        : AppColors.surfaceSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
      ),
    );
  }
}
