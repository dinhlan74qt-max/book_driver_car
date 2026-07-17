import 'package:book_drive_car/core/shared/widget/tap_scale.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RentalManagementScreen extends StatelessWidget {
  const RentalManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cars = const [
      _RentalCar(
        name: 'VinFast Lux A2.0',
        plate: '43A-123.45',
        status: 'Đang cho thuê',
        statusColor: AppColors.success,
        summary: 'Lịch thuê kín 3 ngày tới, đang có 2 yêu cầu chờ duyệt.',
      ),
      _RentalCar(
        name: 'Toyota Vios',
        plate: '43C-678.90',
        status: 'Đã xác minh',
        statusColor: AppColors.primary,
        summary: 'Hồ sơ đầy đủ, sẵn sàng nhận khách ngay.',
      ),
      _RentalCar(
        name: 'Mitsubishi Xpander',
        plate: '43D-456.78',
        status: 'Tạm dừng',
        statusColor: AppColors.accent,
        summary: 'Đang bảo trì định kỳ, có thể bật lại sau khi hoàn tất.',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            Row(
              children: [
                TapScale(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Đăng ký cho thuê xe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withBlue(100),
                    AppColors.accent.withOpacity(0.92),
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản lý xe cho thuê',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Theo dõi trạng thái đăng xe, bật tắt hiển thị, và quản lý hồ sơ cho từng xe của bạn.',
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...cars.map(
              (car) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border.withOpacity(0.8)),
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
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.directions_car_rounded, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(car.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(car.plate, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: car.statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              car.status,
                              style: TextStyle(
                                color: car.statusColor,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(car.summary, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('Sửa thông tin'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              child: const Text('Quản lý trạng thái'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RentalCar {
  final String name;
  final String plate;
  final String status;
  final Color statusColor;
  final String summary;

  const _RentalCar({
    required this.name,
    required this.plate,
    required this.status,
    required this.statusColor,
    required this.summary,
  });
}
