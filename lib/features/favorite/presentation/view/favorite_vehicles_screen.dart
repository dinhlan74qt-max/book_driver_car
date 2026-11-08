import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/favorite/presentation/manager/favorite_manager.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail/car_detail_screen.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/staggered_fade_in.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FavoriteVehiclesScreen extends StatefulWidget {
  const FavoriteVehiclesScreen({super.key});

  @override
  State<FavoriteVehiclesScreen> createState() => _FavoriteVehiclesScreenState();
}

class _FavoriteVehiclesScreenState extends State<FavoriteVehiclesScreen> {
  final _favoriteManager = FavoriteManager.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _favoriteManager.loadFavorites(forceRefresh: true);
      }
    });
  }

  Future<void> _handleRefresh() async {
    await _favoriteManager.loadFavorites(forceRefresh: true);
  }

  Future<void> _handleRemoveFavorite(CarEntity car) async {
    final vehicleId = int.tryParse(car.id);
    if (vehicleId == null) return;

    try {
      await _favoriteManager.removeFavorite(vehicleId);
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: AppToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return AnimatedBuilder(
      animation: _favoriteManager,
      builder: (context, _) {
        final favorites = _favoriteManager.favorites;
        final isLoading = _favoriteManager.isLoading;
        final error = _favoriteManager.errorMessage;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: surfaceColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              children: [
                Text(
                  'Xe yêu thích',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                if (!isLoading && favorites.isNotEmpty)
                  Text(
                    '${favorites.length} xe đã lưu',
                    style: AppTypography.caption.copyWith(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.primary,
            child: _buildBody(
              isLoading: isLoading,
              error: error,
              favorites: favorites,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required String? error,
    required List<CarEntity> favorites,
    required bool isDark,
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    if (isLoading && favorites.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: AppColors.danger,
              ),
              const SizedBox(height: 16),
              Text(
                'Không thể tải danh sách',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: textSecondary),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Thử lại',
                icon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: () =>
                    _favoriteManager.loadFavorites(forceRefresh: true),
              ),
            ],
          ),
        ),
      );
    }

    if (favorites.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 44,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Chưa có xe yêu thích',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy chạm vào biểu tượng trái tim khi xem xe để lưu lại các dòng xe bạn yêu thích nhất.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Khám phá xe ngay',
                      icon: const Icon(Icons.explore_rounded, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final car = favorites[index];
        return StaggeredFadeIn(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _FavoriteCarCard(
              car: car,
              isDark: isDark,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CarDetailScreen(car: car)),
                );
              },
              onRemove: () => _handleRemoveFavorite(car),
            ),
          ),
        );
      },
    );
  }
}

class _FavoriteCarCard extends StatelessWidget {
  final CarEntity car;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCarCard({
    required this.car,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final priceFormat = NumberFormat.decimalPattern('vi_VN');

    final displayImage = car.imageUrls.isNotEmpty
        ? car.imageUrls.first
        : (car.imageIcon.isNotEmpty ? car.imageIcon : '');

    return TapScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : const Color(0xFF17251F).withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack with Favorite Button
            Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: displayImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: displayImage,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: isDark
                                ? AppColors.darkSurfaceSecondary
                                : AppColors.surfaceSecondary,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) =>
                              _buildImagePlaceholder(isDark),
                        )
                      : _buildImagePlaceholder(isDark),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Top-Left Brand / Type Chip
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      car.brand.isNotEmpty ? car.brand : 'Xe tự lái',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ),
                // Top-Right Heart Button (Remove from favorites)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom-Left Price tag on image
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Row(
                    children: [
                      Text(
                        '${priceFormat.format(car.pricePerDay)} đ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4),
                          ],
                        ),
                      ),
                      const Text(
                        ' / ngày',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom-Right Rating Chip
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: Color(0xFFFFB800),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          car.rating > 0
                              ? car.rating.toStringAsFixed(1)
                              : '4.8',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Car Details Section
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          car.location.isNotEmpty ? car.location : car.province,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Feature pills (Seats, Transmission, Fuel)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildFeatureChip(
                        icon: Icons.airline_seat_recline_normal_rounded,
                        label: '${car.seats} chỗ',
                        isDark: isDark,
                      ),
                      if (car.transmission != null &&
                          car.transmission!.isNotEmpty)
                        _buildFeatureChip(
                          icon: Icons.settings_suggest_rounded,
                          label: car.transmission!,
                          isDark: isDark,
                        ),
                      if (car.fuelType != null && car.fuelType!.isNotEmpty)
                        _buildFeatureChip(
                          icon: Icons.local_gas_station_rounded,
                          label: car.fuelType!,
                          isDark: isDark,
                        ),
                      if (car.year != null && car.year! > 0)
                        _buildFeatureChip(
                          icon: Icons.calendar_today_rounded,
                          label: 'Đời ${car.year}',
                          isDark: isDark,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceSecondary
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      color: isDark
          ? AppColors.darkSurfaceSecondary
          : AppColors.surfaceSecondary,
      child: Center(
        child: Icon(
          Icons.directions_car_rounded,
          size: 48,
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
        ),
      ),
    );
  }
}
