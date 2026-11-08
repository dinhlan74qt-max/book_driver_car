import 'dart:async';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_cubit.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_state.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail/car_detail_screen.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_card.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_search_sheet.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_empty_state.dart';
import 'package:book_drive_car/shared/widget/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

bool _isCityFilter(CarSearchFilter filter) {
  return filter.locationLabel != null &&
      filter.locationLabel!.trim().isNotEmpty &&
      filter.locationMode != LocationSearchMode.currentLocation;
}

Future<void> _runSearchForFilter(
  HomeCubit cubit,
  CarSearchFilter filter,
) async {
  if (_isCityFilter(filter)) {
    await cubit.searchCarsByCity(filter.locationLabel!.trim());
    return;
  }

  await cubit.searchCars(
    locationMode: filter.locationMode.toString(),
    locationLabel: filter.locationLabel,
    latitude: filter.latitude,
    longitude: filter.longitude,
    vehicleType: filter.vehicleType,
    brand: filter.brand,
    model: filter.model,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
  );
}

class SearchResultsScreen extends StatelessWidget {
  final CarSearchFilter filter;

  const SearchResultsScreen({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<HomeCubit>();
        unawaited(_runSearchForFilter(cubit, filter));
        return cubit;
      },
      child: _SearchResultsContent(filter: filter),
    );
  }
}

class _SearchResultsContent extends StatelessWidget {
  final CarSearchFilter filter;

  const _SearchResultsContent({required this.filter});

  String _normalize(String value) => value.trim().toLowerCase();

  bool _matchesFilter(CarEntity car) {
    final brand = filter.brand?.trim();
    final model = filter.model?.trim();
    final vehicleType = filter.vehicleType?.trim();
    final city = filter.locationLabel?.trim();

    if (brand != null &&
        brand.isNotEmpty &&
        _normalize(brand) != _normalize(kAllOption)) {
      if (_normalize(car.brand) != _normalize(brand)) return false;
    }

    if (model != null &&
        model.isNotEmpty &&
        _normalize(model) != _normalize(kAllOption)) {
      final modelText = _normalize(car.model ?? '');
      if (modelText.isEmpty || !modelText.contains(_normalize(model))) {
        return false;
      }
    }

    if (vehicleType != null &&
        vehicleType.isNotEmpty &&
        _normalize(vehicleType) != _normalize(kAllOption)) {
      if (_normalize(car.vehicleType) != _normalize(vehicleType)) return false;
    }

    if (city != null && city.isNotEmpty && _isCityFilter(filter)) {
      final carCity = _normalize(
        car.province.isNotEmpty ? car.province : car.location,
      );
      final targetCity = _normalize(city);
      if (carCity.isEmpty || !carCity.contains(targetCity)) return false;
    }

    if (filter.minPrice != null && car.pricePerDay < filter.minPrice!) {
      return false;
    }

    if (filter.maxPrice != null && car.pricePerDay > filter.maxPrice!) {
      return false;
    }

    return true;
  }

  List<CarEntity> _applyLocalFilters(List<CarEntity> cars) {
    return cars.where(_matchesFilter).toList();
  }

  String _formatPriceFilter(int? min, int? max) {
    if (min != null && max != null) {
      return '${(min / 1000).toStringAsFixed(0)}k-${(max / 1000).toStringAsFixed(0)}k';
    } else if (min != null) {
      return '≥${(min / 1000).toStringAsFixed(0)}k';
    } else if (max != null) {
      return '≤${(max / 1000).toStringAsFixed(0)}k';
    }
    return '';
  }

  String get _title {
    final parts = <String>[
      if (filter.locationLabel?.isNotEmpty == true) filter.locationLabel!,
      if (filter.brand?.isNotEmpty == true) filter.brand!,
      if (filter.model?.isNotEmpty == true) filter.model!,
      if (filter.minPrice != null || filter.maxPrice != null)
        _formatPriceFilter(filter.minPrice, filter.maxPrice),
    ];
    return parts.isEmpty ? 'Kết quả tìm kiếm' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          _title,
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
      body: BlocBuilder<HomeCubit, HomeState>(
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.danger,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(color: textPrimary),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: 'Thử lại',
                      onPressed: () => _runSearchForFilter(
                        context.read<HomeCubit>(),
                        filter,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is HomeLoaded) {
            final cars = _applyLocalFilters(state.cars);
            if (cars.isEmpty) {
              final label = filter.locationLabel ?? 'khu vực đã chọn';
              return AppEmptyState(
                icon: Icons.directions_car_filled_rounded,
                title: 'Không tìm thấy xe phù hợp',
                subtitle: 'Hiện chưa có xe nào khớp với bộ lọc tại $label. Bạn hãy thử đổi tiêu chí tìm kiếm khác.',
                buttonText: 'Quay lại',
                onButtonPressed: () => Navigator.of(context).pop(),
              );
            }

            return RefreshIndicator(
              color: primaryColor,
              onRefresh: () =>
                  _runSearchForFilter(context.read<HomeCubit>(), filter),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: cars.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
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

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
