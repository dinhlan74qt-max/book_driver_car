import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_cubit.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_state.dart';
import 'package:book_drive_car/features/home/presentation/view/search/all_cars_screen.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_search_sheet.dart';
import 'package:book_drive_car/features/home/presentation/widget/home_car_section.dart';
import 'package:book_drive_car/features/home/presentation/widget/home_hero_card.dart';
import 'package:book_drive_car/features/home/presentation/widget/home_info_pill.dart';
import 'package:book_drive_car/features/home/presentation/view/search/search_results_screen.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_shimmer.dart';
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
  String _userName = '';
  final ScrollController _scrollController = ScrollController();
  CarSearchFilter _filter = const CarSearchFilter();

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final user = await sl<UserLocalStorage>().getUser();
    if (mounted && user != null) {
      setState(() => _userName = user.fullname);
    }
  }

  Future<void> _openSearch() async {
    final result = await CarSearchSheet.show(
      context,
      initialFilter: _filter,
    );
    if (result == null) return;

    setState(() => _filter = result);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(filter: result),
      ),
    );
  }

  void _openAllCars(List<CarEntity> cars, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AllCarsScreen(cars: cars, title: title),
      ),
    );
  }

  void _resetFilter() {
    setState(() => _filter = const CarSearchFilter());
    context.read<HomeCubit>().fetchCars();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer(
                      width: double.infinity,
                      height: 220,
                      borderRadius: 28,
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Expanded(child: AppShimmer(width: double.infinity, height: 60, borderRadius: 16)),
                        SizedBox(width: 10),
                        Expanded(child: AppShimmer(width: double.infinity, height: 60, borderRadius: 16)),
                        SizedBox(width: 10),
                        Expanded(child: AppShimmer(width: double.infinity, height: 60, borderRadius: 16)),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const AppShimmer(width: 160, height: 24, borderRadius: 8),
                    const SizedBox(height: 14),
                    const AppShimmer(width: double.infinity, height: 160, borderRadius: 20),
                  ],
                ),
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
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.dangerLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (isDark ? AppColors.darkDanger : AppColors.danger).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 36,
                        color: isDark ? AppColors.darkDanger : AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Không thể tải dữ liệu',
                      style: AppTypography.titleLarge.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Thử lại ngay',
                      onPressed: () => context.read<HomeCubit>().fetchCars(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
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
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                children: [
                  RepaintBoundary(
                    child: StaggeredFadeIn(
                      index: 0,
                      child: HomeHeroCard(
                        userName: _userName,
                        subtitle: 'Tìm kiếm xe cao cấp theo thành phố, hãng và dòng xe.',
                        searchPlaceholder: 'Tìm theo điểm đến, hãng xe...',
                        onSearchTap: _openSearch,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RepaintBoundary(
                    child: StaggeredFadeIn(
                      index: 1,
                      child: Row(
                        children: [
                          HomeInfoPill(label: '$totalCars', caption: 'Xe sẵn sàng'),
                          const SizedBox(width: 10),
                          HomeInfoPill(label: '${avgRating.toStringAsFixed(1)}+', caption: 'Sao đánh giá'),
                          const SizedBox(width: 10),
                          HomeInfoPill(
                            label: brandCount > 0 ? '$brandCount+' : '24/7',
                            caption: brandCount > 0 ? 'Hãng xe' : 'Hỗ trợ',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  RepaintBoundary(
                    child: HomeCarSection(
                      index: 2,
                      title: 'Xe nổi bật gần bạn',
                      cars: nearbyCars,
                      isHorizontal: widget.nearbyIsHorizontal,
                      emptyTitle: 'Chưa tìm thấy xe gần bạn',
                      emptyDescription: 'Hãy mở rộng bán kính tìm kiếm hoặc thay đổi vị trí hiện tại.',
                      onReset: _resetFilter,
                      onSeeAll: () => _openAllCars(state.nearbyCars, 'Xe nổi bật gần bạn'),
                    ),
                  ),
                  const SizedBox(height: 28),
                  RepaintBoundary(
                    child: HomeCarSection(
                      index: 3,
                      title: 'Gợi ý lý tưởng cho bạn',
                      cars: suggestedCars,
                      isHorizontal: widget.suggestedIsHorizontal,
                      emptyTitle: 'Chưa có gợi ý phù hợp',
                      emptyDescription: 'Bạn hãy đổi bộ lọc để khám phá thêm nhiều mẫu xe khác.',
                      onReset: _resetFilter,
                      onSeeAll: () => _openAllCars(state.suggestedCars, 'Gợi ý lý tưởng cho bạn'),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
