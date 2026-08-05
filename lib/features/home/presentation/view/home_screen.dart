import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_cubit.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_state.dart';
import 'package:book_drive_car/features/home/presentation/view/all_cars_screen.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_search_sheet.dart';
import 'package:book_drive_car/features/home/presentation/widget/home_car_section.dart';
import 'package:book_drive_car/features/home/presentation/widget/home_hero_card.dart';
import 'package:book_drive_car/features/home/presentation/widget/home_info_pill.dart';
import 'package:book_drive_car/shared/widget/staggered_fade_in.dart';
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
  final ScrollController _scrollController = ScrollController();

  CarSearchFilter _filter = const CarSearchFilter(
    locationMode: LocationSearchMode.province,
    locationLabel: _defaultProvince,
  );

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (mounted) setState(() {});
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0E1118),
            Color(0xFF151A24),
            Color(0xFFF5F6F8),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(
              top: -80,
              right: -55,
              child: _LuxuryGlow(
                size: 220,
                colors: [
                  AppColors.headlightAmber.withValues(alpha: 0.22),
                  AppColors.accent.withValues(alpha: 0.0),
                ],
              ),
            ),
            Positioned(
              top: 150,
              left: -70,
              child: _LuxuryGlow(
                size: 180,
                colors: [
                  AppColors.pageAccents[2].withValues(alpha: 0.15),
                  AppColors.pageAccents[2].withValues(alpha: 0.0),
                ],
              ),
            ),
            BlocBuilder<HomeCubit, HomeState>(
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
                  final nearbyCars = state.nearbyCars.take(5).toList();
                  final suggestedCars = state.suggestedCars.take(5).toList();

                  final totalCars = state.cars.length;
                  final avgRating = state.cars.isNotEmpty
                      ? (state.cars.map((e) => e.rating).reduce((a, b) => a + b) / state.cars.length)
                      : 4.8;
                  final brandCount = state.cars.map((e) => e.brand).where((b) => b.isNotEmpty).toSet().length;

                  return RefreshIndicator(
                    onRefresh: () async => context.read<HomeCubit>().fetchCars(),
                    color: AppColors.headlightAmber,
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 44, 16, 24),
                      children: [
                        StaggeredFadeIn(
                          index: 0,
                          child: HomeHeroCard(
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
                              HomeInfoPill(label: '$totalCars', caption: 'xe phù hợp'),
                              const SizedBox(width: 10),
                              HomeInfoPill(label: '${avgRating.toStringAsFixed(1)}+', caption: 'đánh giá'),
                              const SizedBox(width: 10),
                              HomeInfoPill(
                                label: brandCount > 0 ? '$brandCount+' : '24h',
                                caption: brandCount > 0 ? 'hãng xe' : 'hỗ trợ',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        HomeCarSection(
                          index: 2,
                          title: 'Xe gần đây',
                          cars: nearbyCars,
                          isHorizontal: widget.nearbyIsHorizontal,
                          emptyTitle: 'Chưa có xe phù hợp',
                          emptyDescription: 'Bạn hãy đổi vị trí hoặc xoá bộ lọc để xem thêm xe.',
                          onReset: _resetFilter,
                          onSeeAll: () => _openAllCars(state.nearbyCars, 'Xe gần đây'),
                        ),
                        const SizedBox(height: 24),
                        HomeCarSection(
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
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxuryGlow extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _LuxuryGlow({
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
