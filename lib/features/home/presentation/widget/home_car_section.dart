import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail_screen.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_card.dart';
import 'package:book_drive_car/features/home/presentation/widget/home_empty_state.dart';
import 'package:book_drive_car/shared/widget/staggered_fade_in.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeCarSection extends StatefulWidget {
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
  State<HomeCarSection> createState() => _HomeCarSectionState();
}

class _HomeCarSectionState extends State<HomeCarSection> {
  final GlobalKey _headerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    double dy = 999;
    final box = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.attached) {
      dy = box.localToGlobal(Offset.zero).dy;
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final darkBoundary = screenHeight * 0.45;

    final bool isDarkBackground = dy <= darkBoundary;
    final titleColor = isDarkBackground ? AppColors.laneWhite : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StaggeredFadeIn(
          index: widget.index,
          child: Row(
            key: _headerKey,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                  child: Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              TapScale(
                onTap: widget.cars.isEmpty ? null : widget.onSeeAll,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkBackground ? AppColors.surfaceNavy : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkBackground ? AppColors.hairline : AppColors.border,
                    ),
                    boxShadow: isDarkBackground
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: isDarkBackground ? AppColors.headlightAmber : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        StaggeredFadeIn(
          index: widget.index + 1,
          child: widget.cars.isEmpty
              ? HomeEmptyState(
                  title: widget.emptyTitle,
                  description: widget.emptyDescription,
                  onReset: widget.onReset,
                )
              : widget.isHorizontal
                  ? _HorizontalCars(cars: widget.cars)
                  : _VerticalCars(cars: widget.cars),
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
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cars.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return CarCard(
            car: cars[index],
            width: 260,
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
          if (i != cars.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
