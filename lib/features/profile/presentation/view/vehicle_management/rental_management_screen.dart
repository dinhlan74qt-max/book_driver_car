import 'dart:async';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/profile/domain/entities/vehicle_entity.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/my_vehicles_bloc.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/my_vehicles_event.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/my_vehicles_state.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking/owner_booking_list_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/vehicle_management/vehicle_detail_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/vehicle_management/vehicle_registration_screen.dart';
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
    final vehicle = await Navigator.of(context).push<VehicleEntity>(
      MaterialPageRoute(builder: (_) => const VehicleRegistrationScreen()),
    );

    if (!mounted) return;

    if (vehicle != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xe đã được tạo, đang cập nhật danh sách...'),
        ),
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
    final parts = <String>[
      vehicle.address.addressDetail,
      vehicle.address.ward,
      vehicle.address.district,
      vehicle.address.city,
    ].where((part) => part.trim().isNotEmpty).toList();

    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return AppColors.success;
      case 'PENDING':
        return AppColors.accent;
      case 'REJECTED':
      case 'UNAVAILABLE':
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return 'Sẵn sàng';
      case 'PENDING':
        return 'Chờ duyệt';
      case 'REJECTED':
        return 'Từ chối';
      case 'UNAVAILABLE':
        return 'Không khả dụng';
      default:
        return status;
    }
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Đăng ký cho thuê xe',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => _openBookingHistory(),
                icon: const Icon(
                  Icons.receipt_long_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Quản lý đơn',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 4),
                child: TapScale(
                  onTap: _openRegistration,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.primary,
                    ),
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
                  final availableCount = vehicles
                      .where(
                        (vehicle) =>
                            vehicle.status.toUpperCase() == 'AVAILABLE',
                      )
                      .length;
                  final pendingCount = vehicles
                      .where(
                        (vehicle) => vehicle.status.toUpperCase() == 'PENDING',
                      )
                      .length;
                  final blockedCount = vehicles.where((vehicle) {
                    final status = vehicle.status.toUpperCase();
                    return status == 'REJECTED' || status == 'UNAVAILABLE';
                  }).length;

                  return Stack(
                    children: [
                      const Positioned.fill(child: _LuxuryBackground()),
                      ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        children: [
                          if (refreshing) ...[
                            const SizedBox(height: 4),
                            const ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(999),
                              ),
                              child: LinearProgressIndicator(minHeight: 2.5),
                            ),
                            const SizedBox(height: 12),
                          ],
                          _HeroPanel(
                            totalCount: totalCount,
                            availableCount: availableCount,
                            pendingCount: pendingCount,
                            blockedCount: blockedCount,
                            onAddVehicle: _openRegistration,
                          ),
                          const SizedBox(height: 18),
                          if (initialLoading)
                            const _LoadingCard(
                              label: 'Đang tải danh sách xe của bạn...',
                            )
                          else if (_errorMessage != null && vehicles.isEmpty)
                            _EmptyStateCard(
                              icon: Icons.error_outline_rounded,
                              title: 'Không tải được danh sách xe',
                              description: _errorMessage!,
                              buttonLabel: 'Thử lại',
                              onPressed: _refreshVehicles,
                              accent: AppColors.danger,
                            )
                          else if (vehicles.isEmpty)
                            _EmptyStateCard(
                              icon: Icons.directions_car_filled_rounded,
                              title: 'Chưa có xe nào được đăng ký',
                              description:
                                  'Hãy tạo chiếc xe đầu tiên để bắt đầu quản lý lịch thuê, trạng thái và hồ sơ xe của bạn.',
                              buttonLabel: 'Đăng ký xe mới',
                              onPressed: _openRegistration,
                              accent: AppColors.primary,
                            )
                          else ...[
                            _SectionHeader(
                              title: 'Danh sách xe của bạn',
                              trailing: '$totalCount xe',
                            ),
                            const SizedBox(height: 12),
                            ...vehicles.map(
                              (vehicle) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TapScale(
                                  onTap: () => _openVehicleDetail(vehicle),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(26),
                                      border: Border.all(
                                        color: AppColors.border.withValues(
                                          alpha: 0.78,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF0F172A,
                                          ).withValues(alpha: 0.05),
                                          blurRadius: 18,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    AppColors.primary
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                                    AppColors.accent.withValues(
                                                      alpha: 0.12,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.directions_car_rounded,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    vehicle.vehicleName,
                                                    style: const TextStyle(
                                                      fontSize: 16.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _vehicleSubtitle(vehicle),
                                                    style: const TextStyle(
                                                      color: AppColors
                                                          .textSecondary,
                                                      fontSize: 12.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    vehicle
                                                            .licensePlate
                                                            .isNotEmpty
                                                        ? vehicle.licensePlate
                                                        : 'Chưa có biển số',
                                                    style: const TextStyle(
                                                      color: AppColors
                                                          .textSecondary,
                                                      fontSize: 12.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _statusColor(
                                                  vehicle.status,
                                                ).withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                _statusLabel(vehicle.status),
                                                style: TextStyle(
                                                  color: _statusColor(
                                                    vehicle.status,
                                                  ),
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _InfoChip(
                                              label: '${vehicle.seatCount} chỗ',
                                            ),
                                            _InfoChip(
                                              label: vehicle.transmission,
                                            ),
                                            _InfoChip(label: vehicle.fuelType),
                                            _InfoChip(
                                              label:
                                                  '${_formatPrice(vehicle.pricePerDay)} đ/ngày',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          vehicle.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            height: 1.45,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        if (_vehicleLocation(vehicle) != null)
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.place_outlined,
                                                size: 16,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  _vehicleLocation(vehicle)!,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 12.5,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.chevron_right_rounded,
                                                color: AppColors.textMuted,
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 6),
                                        const Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            'Chạm để xem chi tiết',
                                            style: TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LuxuryBackground extends StatelessWidget {
  const _LuxuryBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F8FA), Color(0xFFF3F4F7), Color(0xFFF7F8FA)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -70,
            child: _GlowOrb(
              size: 240,
              colors: [
                AppColors.primary.withValues(alpha: 0.10),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            top: 180,
            left: -90,
            child: _GlowOrb(
              size: 190,
              colors: [
                AppColors.accent.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GlowOrb({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final int totalCount;
  final int availableCount;
  final int pendingCount;
  final int blockedCount;
  final VoidCallback onAddVehicle;

  const _HeroPanel({
    required this.totalCount,
    required this.availableCount,
    required this.pendingCount,
    required this.blockedCount,
    required this.onAddVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F141B),
            const Color(0xFF16202B),
            AppColors.primary.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.20),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quản lý xe cho thuê',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Theo dõi hồ sơ xe, trạng thái đăng ký và mở rộng đội xe của bạn trong một giao diện sang hơn.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.74),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStatChip(label: '$totalCount', caption: 'Xe của bạn'),
              _HeroStatChip(label: '$availableCount', caption: 'Đang mở'),
              _HeroStatChip(label: '$pendingCount', caption: 'Chờ duyệt'),
              _HeroStatChip(label: '$blockedCount', caption: 'Tạm ẩn'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TapScale(
              onTap: onAddVehicle,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Đăng ký xe mới',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Danh sách xe được lấy trực tiếp từ server. Kéo xuống để làm mới hoặc mở từng thẻ để xem chi tiết.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  final String label;
  final String caption;

  const _HeroStatChip({required this.label, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionHeader({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;
  final Color accent;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final String label;

  const _LoadingCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
