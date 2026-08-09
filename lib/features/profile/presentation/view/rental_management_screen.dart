import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/profile/domain/entities/vehicle_entity.dart';
import 'package:book_drive_car/features/profile/presentation/view/owner_booking_list_screen.dart';
import 'package:book_drive_car/features/profile/presentation/view/vehicle_registration_screen.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RentalManagementScreen extends StatefulWidget {
  const RentalManagementScreen({super.key});

  @override
  State<RentalManagementScreen> createState() => _RentalManagementScreenState();
}

class _RentalManagementScreenState extends State<RentalManagementScreen> {
  final List<VehicleEntity> _vehicles = [];

  Future<void> _openRegistration() async {
    final vehicle = await Navigator.of(context).push<VehicleEntity>(
      MaterialPageRoute(builder: (_) => const VehicleRegistrationScreen()),
    );

    if (!mounted || vehicle == null) return;

    setState(() {
      _vehicles.insert(0, vehicle);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Đăng ký cho thuê xe',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          // Nút Quản lý đơn trên AppBar
          TextButton.icon(
            onPressed: () => _openBookingHistory(),
            icon: const Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.primary),
            label: const Text(
              'Quản lý đơn',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
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
                child: const Icon(Icons.add_rounded, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
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
                    color: const Color(0xFF0F172A).withValues(alpha: 0.18),
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
                    'Theo dõi xe bạn đã đăng ký và thêm xe mới để bắt đầu cho thuê.',
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (_vehicles.isEmpty)
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
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.no_crash_outlined,
                        size: 34,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Bạn chưa có xe nào',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hãy đăng ký xe đầu tiên để bắt đầu kiếm thêm thu nhập từ xe nhàn rỗi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openRegistration,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Đăng ký xe ngay'),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  for (final vehicle in _vehicles)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
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
                                      AppColors.primary.withValues(alpha: 0.12),
                                      AppColors.accent.withValues(alpha: 0.12),
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
                                      '${vehicle.brand} • ${vehicle.model} • ${vehicle.year}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      vehicle.licensePlate,
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
                                  color: AppColors.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  vehicle.status,
                                  style: const TextStyle(
                                    color: AppColors.success,
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
                                label: '${_formatPrice(vehicle.pricePerDay)}đ/ngày',
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
                                  '${vehicle.address.addressDetail}, ${vehicle.address.ward}, ${vehicle.address.district}, ${vehicle.address.city}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 10),

                          // Nút xem lịch sử thuê của chiếc xe này
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _openBookingHistory(vehicleName: vehicle.vehicleName),
                              icon: const Icon(Icons.history_rounded, size: 16),
                              label: const Text('Xem lịch sử thuê của xe này'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
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
