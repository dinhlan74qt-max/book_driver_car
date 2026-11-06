import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_cubit.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_state.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail/car_detail_screen.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_card.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_empty_state.dart';
import 'package:book_drive_car/shared/widget/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CityCarsResultScreen extends StatelessWidget {
  final String cityName;

  const CityCarsResultScreen({super.key, required this.cityName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..searchCarsByCity(cityName),
      child: _CityCarsResultContent(cityName: cityName),
    );
  }
}

class _CityCarsResultContent extends StatefulWidget {
  final String cityName;

  const _CityCarsResultContent({required this.cityName});

  @override
  State<_CityCarsResultContent> createState() => _CityCarsResultContentState();
}

class _CityCarsResultContentState extends State<_CityCarsResultContent> {
  String _selectedFilter = 'Tất cả';

  List<CarEntity> _filterCars(List<CarEntity> cars) {
    if (_selectedFilter == 'Tự động') {
      return cars.where((c) => (c.transmission ?? '').toLowerCase().contains('tự động') || (c.transmission ?? '').toLowerCase().contains('auto')).toList();
    }
    if (_selectedFilter == '7 chỗ') {
      return cars.where((c) => c.seats >= 7).toList();
    }
    if (_selectedFilter == '4-5 chỗ') {
      return cars.where((c) => c.seats <= 5).toList();
    }
    return cars;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          children: [
            Text(
              'Xe tại ${widget.cityName}',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Địa điểm nhận xe',
              style: AppTypography.caption.copyWith(color: textSecondary),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: primaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, __) => const AppShimmer(
                  width: double.infinity,
                  height: 140,
                  borderRadius: 20,
                ),
              );
            }

            if (state is HomeError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AppEmptyState(
                    title: 'Không tải được danh sách xe',
                    subtitle: state.message,
                    icon: Icons.error_outline_rounded,
                    buttonText: 'Thử lại',
                    onButtonPressed: () => context.read<HomeCubit>().searchCarsByCity(widget.cityName),
                  ),
                ),
              );
            }

            if (state is HomeLoaded) {
              final allCars = state.cars;
              final filteredCars = _filterCars(allCars);

              if (allCars.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AppEmptyState(
                      title: 'Chưa có xe tại ${widget.cityName}',
                      subtitle: 'Hiện chưa có chủ xe nào cho thuê xe tại khu vực này. Bạn hãy thử tìm kiếm các thành phố lân cận nhé.',
                      icon: Icons.directions_car_outlined,
                      buttonText: 'Tìm thành phố khác',
                      onButtonPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<HomeCubit>().searchCarsByCity(widget.cityName),
                child: Column(
                  children: [
                    // Filter bar
                    Container(
                      color: surfaceColor,
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['Tất cả', 'Tự động', '4-5 chỗ', '7 chỗ'].map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  filter,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 12.5,
                                    color: isSelected
                                        ? (isDark ? AppColors.darkBackground : Colors.white)
                                        : textSecondary,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: primaryColor,
                                backgroundColor: bgColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  side: BorderSide(
                                    color: isSelected ? primaryColor : borderColor,
                                  ),
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedFilter = filter);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Results Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            'Tìm thấy ${filteredCars.length} xe',
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.sort_rounded, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Giá tốt nhất',
                            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    // Cars List
                    Expanded(
                      child: filteredCars.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Không có xe nào khớp bộ lọc "$_selectedFilter"',
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                              itemCount: filteredCars.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final car = filteredCars[index];
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
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
