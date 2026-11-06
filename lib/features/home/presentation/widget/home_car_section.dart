import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail/car_detail_screen.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_card.dart';
import 'package:book_drive_car/features/home/presentation/widget/home_empty_state.dart';
import 'package:book_drive_car/shared/widget/staggered_fade_in.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:book_drive_car/core/utils/responsive_utils.dart';

class HomeCarSection extends StatelessWidget {
  final int index;
  final String title;
  final List<CarEntity> cars;
  final bool isHorizontal;
  final String emptyTitle;
  final String emptyDescription;
  final VoidCallback onReset;
  final VoidCallback onSeeAll;

  const HomeCarSection({
    super.key,
    required this.index,
    required this.title,
    required this.cars,
    required this.isHorizontal,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.onReset,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StaggeredFadeIn(
          index: index,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
              ),
              TapScale(
                onTap: cars.isEmpty ? null : onSeeAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.shadowSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Xem tất cả',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        StaggeredFadeIn(
          index: index + 1,
          child: cars.isEmpty
              ? HomeEmptyState(
                  title: emptyTitle,
                  description: emptyDescription,
                  onReset: onReset,
                )
              : isHorizontal
                  ? _HorizontalCars(cars: cars)
                  : _VerticalCars(cars: cars),
        ),
      ],
    );
  }
}

class _HorizontalCars extends StatelessWidget {
  final List<CarEntity> cars;
  const _HorizontalCars({required this.cars});

  @override
  Widget build(BuildContext context) {
    final cardWidth = context.isTablet
        ? 340.0
        : (context.screenWidth * 0.72).clamp(240.0, 320.0);
    final listHeight = context.isTablet ? 300.0 : 275.0;

    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: cars.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return CarCard(
            car: cars[index],
            width: cardWidth,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CarDetailScreen(car: cars[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VerticalCars extends StatelessWidget {
  final List<CarEntity> cars;
  const _VerticalCars({required this.cars});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < cars.length; i++) ...[
          CarCard(
            car: cars[i],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CarDetailScreen(car: cars[i]),
              ),
            ),
          ),
          if (i != cars.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}
