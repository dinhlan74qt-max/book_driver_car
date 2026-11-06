import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail/car_detail_screen.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_card.dart';
import 'package:book_drive_car/shared/widget/app_empty_state.dart';
import 'package:flutter/material.dart';

class AllCarsScreen extends StatelessWidget {
  final List<CarEntity> cars;
  final String title;

  const AllCarsScreen({
    super.key,
    required this.cars,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTypography.titleLarge.copyWith(color: textPrimary),
        ),
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: cars.isEmpty
          ? const AppEmptyState(
              icon: Icons.directions_car_filled_rounded,
              title: 'Không có xe nào phù hợp',
              subtitle: 'Danh mục này hiện chưa có xe khả dụng.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cars.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final car = cars[index];
                return CarCard(
                  car: car,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CarDetailScreen(car: car),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
