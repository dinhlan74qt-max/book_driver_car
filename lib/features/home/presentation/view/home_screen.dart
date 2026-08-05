import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_cubit.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_state.dart';
import 'package:book_drive_car/features/home/presentation/view/all_cars_screen.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail_screen.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_card.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_search_sheet.dart';
import 'package:book_drive_car/shared/widget/staggered_fade_in.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  final bool nearbyIsHorizontal;
  final bool suggestedIsHorizontal;

  const HomeScreen({
    super.key,
    this.nearbyIsHorizontal = true,
    this.suggestedIsHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..fetchCars(),
      child: _HomeScreenContent(
        nearbyIsHorizontal: nearbyIsHorizontal,
        suggestedIsHorizontal: suggestedIsHorizontal,
      ),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  final bool nearbyIsHorizontal;
  final bool suggestedIsHorizontal;

  const _HomeScreenContent({
    required this.nearbyIsHorizontal,
    required this.suggestedIsHorizontal,
  });

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  static const _defaultProvince = 'Đà Nẵng';

  String _userName = '';

  CarSearchFilter _filter = const CarSearchFilter(
    locationMode: LocationSearchMode.province,
    locationLabel: _defaultProvince,
  );

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = await sl<UserLocalStorage>().getUser();
    if (mounted && user != null) {
      setState(() => _userName = user.fullname ?? '');
    }
  }

  Future<void> _openSearch() async {
    final result = await CarSearchSheet.show(context, initialFilter: _filter);
    if (result != null) {
      setState(() => _filter = result);
      if (!mounted) return;
      context.read<HomeCubit>().searchCars(
            locationMode: _filter.locationMode.toString(),
            locationLabel: _filter.locationLabel,
            latitude: _filter.latitude,
            longitude: _filter.longitude,
            vehicleType: _filter.vehicleType,
            brand: _filter.brand,
          );
    }
  }

  void _openAllCars(List<CarEntity> cars, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AllCarsScreen(cars: cars, title: title),
      ),
    );
  }

  void _resetFilter() {
    setState(() {
      _filter = const CarSearchFilter(
        locationMode: LocationSearchMode.province,
        locationLabel: _defaultProvince,
      );
    });
    context.read<HomeCubit>().fetchCars();
  }

  String get _locationLabel => _filter.locationLabel ?? _defaultProvince;

  String get _heroSubtitle {
    switch (_filter.locationMode) {
      case LocationSearchMode.currentLocation:
        return 'Đang xem xe gần vị trí hiện tại của bạn';
      case LocationSearchMode.address:
        return 'Đang xem xe gần "$_locationLabel"';
      case LocationSearchMode.province:
      case LocationSearchMode.none:
        return 'Đang xem xe tại $_locationLabel';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<HomeCubit>().fetchCars(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is HomeLoaded) {
          final nearbyCars = state.nearbyCars.take(5).toList();
          final suggestedCars = state.suggestedCars.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async => context.read<HomeCubit>().fetchCars(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                StaggeredFadeIn(
                  index: 0,
                  child: _HeroCard(
                    userName: _userName,
                    subtitle: _heroSubtitle,
                    searchPlaceholder: _filter.locationMode == LocationSearchMode.none
                        ? 'Nhập tên tỉnh hoặc địa chỉ cụ thể'
                        : _locationLabel,
                    onSearchTap: _openSearch,
                  ),
                ),
                const SizedBox(height: 16),
                StaggeredFadeIn(
                  index: 1,
                  child: Row(
                    children: [
                      _InfoPill(label: '${state.cars.length}', caption: 'xe phù hợp'),
                      const SizedBox(width: 10),
                      const _InfoPill(label: '4.8+', caption: 'đánh giá'),
                      const SizedBox(width: 10),
                      const _InfoPill(label: '24h', caption: 'hỗ trợ'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _CarSection(
                  index: 2,
                  title: 'Xe gần đây',
                  cars: nearbyCars,
                  isHorizontal: widget.nearbyIsHorizontal,
                  emptyTitle: 'Chưa có xe phù hợp',
                  emptyDescription: 'Bạn hãy đổi vị trí hoặc xoá bộ lọc để xem thêm xe.',
                  onReset: _resetFilter,
                  onSeeAll: () => _openAllCars(state.nearbyCars, 'Xe gần đây'),
                ),
                const SizedBox(height: 20),
                _CarSection(
                  index: 3,
                  title: 'Gợi ý cho bạn',
                  cars: suggestedCars,
                  isHorizontal: widget.suggestedIsHorizontal,
                  emptyTitle: 'Chưa có gợi ý phù hợp',
                  emptyDescription: 'Bạn hãy đổi vị trí hoặc xoá bộ lọc để xem gợi ý khác.',
                  onReset: _resetFilter,
                  onSeeAll: () => _openAllCars(state.suggestedCars, 'Gợi ý cho bạn'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ── Section tiêu đề + danh sách ──────────────────────────────────────────────

class _CarSection extends StatelessWidget {
  final int index;
  final String title;
  final List<CarEntity> cars;
  final bool isHorizontal;
  final String emptyTitle;
  final String emptyDescription;
  final VoidCallback onReset;
  final VoidCallback onSeeAll;

  const _CarSection({
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
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TapScale(
                onTap: cars.isEmpty ? null : onSeeAll,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        StaggeredFadeIn(
          index: index + 1,
          child: cars.isEmpty
              ? _EmptyState(
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
    return SizedBox(
      height: 250,
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

// ── Hero card (search bar + greeting) ────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final String userName;
  final String subtitle;
  final String searchPlaceholder;
  final VoidCallback onSearchTap;

  const _HeroCard({
    required this.userName,
    required this.subtitle,
    required this.searchPlaceholder,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final greeting = userName.isNotEmpty ? 'Xin chào, $userName' : 'Xin chào!';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85, red: 30),
            AppColors.accent.withValues(alpha: 0.94),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.78), height: 1.5),
          ),
          const SizedBox(height: 16),
          TapScale(
            onTap: onSearchTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      searchPlaceholder,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info pills (4 xe / 4.8+ / 24h) ──────────────────────────────────────────

class _InfoPill extends StatelessWidget {
  final String label;
  final String caption;

  const _InfoPill({required this.label, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onReset;

  const _EmptyState({
    required this.title,
    required this.description,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 30),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onReset, child: const Text('Xoá bộ lọc')),
        ],
      ),
    );
  }
}
