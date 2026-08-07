import 'dart:async';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/profile/domain/entities/vehicle_entity.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/my_vehicles_bloc.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/my_vehicles_event.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/my_vehicles_state.dart';
import 'package:book_drive_car/features/profile/presentation/view/vehicle_detail_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/vehicle_registration_screen.dart';
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
        const SnackBar(content: Text('Xe đã được tạo, đang cập nhật danh sách...')),
      );
      _myVehiclesBloc.add(const MyVehiclesRequested());
    }
  }

  Future<void> _openVehicleDetail(VehicleEntity vehicle) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VehicleDetailScreen(vehicle: vehicle),
      ),
    );
  }

  Future<void> _refreshVehicles() {
    final completer = Completer<void>();
    _refreshCompleter = completer;
    _myVehiclesBloc.add(const MyVehiclesRequested());
    return completer.future;
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _myVehiclesBloc,
      child: BlocListener<MyVehiclesBloc, MyVehiclesState>(
        listener: (context, state) {
          if (state is MyVehiclesLoaded) {
            _vehiclesCache = state.vehicles;
            _errorMessage = null;
            if (_refreshCompleter != null && !(_refreshCompleter?.isCompleted ?? true)) {
              _refreshCompleter?.complete();
            }
          }

          if (state is MyVehiclesFailure) {
            _errorMessage = state.error;
            if (_refreshCompleter != null && !(_refreshCompleter?.isCompleted ?? true)) {
              _refreshCompleter?.complete();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Đăng ký cho thuê xe',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TapScale(
                  onTap: _openRegistration,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add_rounded, color: AppColors.primary),
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
                  final vehicles = state is MyVehiclesLoaded ? state.vehicles : _vehiclesCache;
                  final bool initialLoading = state is MyVehiclesLoading && vehicles.isEmpty;
                  final bool refreshing = state is MyVehiclesLoading && vehicles.isNotEmpty;

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (refreshing) ...[
                        const SizedBox(height: 4),
                        const ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                          child: LinearProgressIndicator(minHeight: 2.5),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF11161F),
                              const Color(0xFF1A2230),
                              AppColors.primary.withBlue(110),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.directions_car_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'Quản lý xe cho thuê',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Danh sách xe được lấy trực tiếp từ server. Kéo xuống để tải lại hoặc bấm dấu cộng để đăng ký xe mới.',
                              style: TextStyle(color: Colors.white70, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (initialLoading)
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Column(
                            children: [
                              SizedBox(
                                width: 44,
                                height: 44,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Đang tải danh sách xe của bạn...',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        )
                      else if (_errorMessage != null && vehicles.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.danger,
                                size: 36,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _refreshVehicles,
                                  child: const Text('Thử lại'),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (vehicles.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.directions_car_filled_rounded,
                                  size: 36,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Chưa có xe nào được đăng ký',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Hãy bấm nút dấu cộng để thêm xe đầu tiên của bạn. Khi server trả về dữ liệu, xe sẽ xuất hiện ở đây.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _openRegistration,
                                  child: const Text('Đăng ký cho thuê xe'),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        Row(
                          children: [
                            Text(
                              'Danh sách xe của bạn',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              '${vehicles.length} xe',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
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
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppColors.border.withOpacity(0.8)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0F172A).withOpacity(0.04),
                                      blurRadius: 16,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 58,
                                          height: 58,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(18),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.primary.withOpacity(0.12),
                                                AppColors.accent.withOpacity(0.12),
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                vehicle.vehicleName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _vehicleSubtitle(vehicle),
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12.5,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                vehicle.licensePlate.isNotEmpty
                                                    ? vehicle.licensePlate
                                                    : 'Chưa có biển số',
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _statusColor(vehicle.status).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            vehicle.status,
                                            style: TextStyle(
                                              color: _statusColor(vehicle.status),
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
                                        _InfoChip(label: '${vehicle.seatCount} chỗ'),
                                        _InfoChip(label: vehicle.transmission),
                                        _InfoChip(label: vehicle.fuelType),
                                        _InfoChip(
                                          label: '${_formatPrice(vehicle.pricePerDay)} đ/ngày',
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
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
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

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
