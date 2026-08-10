import 'dart:async';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_cubit.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_state.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail_screen.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_card.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_search_sheet.dart';
import 'package:book_drive_car/features/home/presentation/widget/city_search_suggestions.dart';
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
      if (modelText.isEmpty || !modelText.contains(_normalize(model)))
        return false;
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

    return true;
  }

  List<CarEntity> _applyLocalFilters(List<CarEntity> cars) {
    return cars.where(_matchesFilter).toList();
  }

  String get _title {
    final parts = <String>[
      if (filter.locationLabel?.isNotEmpty == true) filter.locationLabel!,
      if (filter.brand?.isNotEmpty == true) filter.brand!,
      if (filter.model?.isNotEmpty == true) filter.model!,
    ];
    return parts.isEmpty ? 'Kết quả tìm kiếm' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.headlightAmber),
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
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _runSearchForFilter(
                        context.read<HomeCubit>(),
                        filter,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.headlightAmber,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is HomeLoaded) {
            final cars = _applyLocalFilters(state.cars);
            if (cars.isEmpty) {
              return _EmptySearchState(filter: filter);
            }

            return RefreshIndicator(
              color: AppColors.headlightAmber,
              onRefresh: () =>
                  _runSearchForFilter(context.read<HomeCubit>(), filter),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: cars.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
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

class _EmptySearchState extends StatelessWidget {
  final CarSearchFilter filter;

  const _EmptySearchState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final label = filter.locationLabel ?? 'khu vực đã chọn';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: AppColors.primary,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Không có xe phù hợp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hiện chưa có xe nào khớp với bộ lọc tại $label. Bạn hãy thử đổi thành phố, hãng hoặc dòng xe khác.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
