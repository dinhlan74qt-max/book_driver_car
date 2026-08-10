import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_cubit.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_state.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail_screen.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_card.dart';
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

class _CityCarsResultContent extends StatelessWidget {
  final String cityName;

  const _CityCarsResultContent({required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          const Positioned.fill(child: _LuxuryResultBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _HeaderIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kết quả tìm kiếm',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cityName,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _HeaderIconButton(
                        icon: Icons.search_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading || state is HomeInitial) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.headlightAmber,
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
                                const SizedBox(height: 12),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context
                                      .read<HomeCubit>()
                                      .searchCarsByCity(cityName),
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
                        final cars = state.cars;
                        if (cars.isEmpty) {
                          return _EmptyCityState(
                            cityName: cityName,
                            onSearchAgain: () {
                              Navigator.of(context).pop();
                            },
                          );
                        }

                        return RefreshIndicator(
                          color: AppColors.headlightAmber,
                          onRefresh: () =>
                              context.read<HomeCubit>().searchCarsByCity(cityName),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCityState extends StatelessWidget {
  final String cityName;
  final VoidCallback onSearchAgain;

  const _EmptyCityState({
    required this.cityName,
    required this.onSearchAgain,
  });

  @override
  Widget build(BuildContext context) {
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
                'Không có xe ở thành phố này',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hiện tại chưa có xe nào được đăng ở $cityName. Bạn có thể thử một thành phố khác.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSearchAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.headlightAmber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Tìm thành phố khác',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LuxuryResultBackground extends StatelessWidget {
  const _LuxuryResultBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1017), Color(0xFF151A24), Color(0xFFF7F8FA)],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _GlowOrb(
              size: 220,
              colors: [
                AppColors.headlightAmber.withValues(alpha: 0.20),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            top: 160,
            left: -70,
            child: _GlowOrb(
              size: 180,
              colors: [
                AppColors.pageAccents[2].withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GlowOrb({required this.size, required this.colors});

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

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
