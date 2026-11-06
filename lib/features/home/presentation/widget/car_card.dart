import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CarCard extends StatelessWidget {
  final CarEntity car;
  final VoidCallback? onTap;
  final double? width;

  const CarCard({super.key, required this.car, this.onTap, this.width});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = width != null ? width! < 330 : screenWidth < 330;
    final content = isCompact ? _CompactCard(car: car) : _ExpandedCard(car: car);

    final card = _CardShell(
      onTap: onTap,
      child: content,
    );

    if (width == null) return card;
    return SizedBox(width: width, child: card);
  }

  static String _formatPrice(num price) {
    final s = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buffer.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()}đ';
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _CardShell({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TapScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.22)
                  : const Color(0xFF17251F).withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

class _ExpandedCard extends StatelessWidget {
  final CarEntity car;

  const _ExpandedCard({required this.car});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 124,
          height: 140,
          child: _CarImage(car: car),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  car.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        car.location.isNotEmpty ? car.location : car.province,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _SpecChip(
                      icon: Icons.directions_car_filled_outlined,
                      label: car.brand,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                    if (car.vehicleType.isNotEmpty)
                      _SpecChip(
                        icon: Icons.electric_car_outlined,
                        label: car.vehicleType,
                        color: isDark ? AppColors.darkSuccess : AppColors.success,
                      ),
                    _SpecChip(
                      icon: Icons.airline_seat_recline_normal_rounded,
                      label: '${car.seats} chỗ',
                      color: isDark ? AppColors.darkAccent : AppColors.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: CarCard._formatPrice(car.pricePerDay),
                              style: AppTypography.priceMedium.copyWith(
                                fontSize: 16,
                                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: ' /ngày',
                              style: AppTypography.caption.copyWith(
                                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactCard extends StatelessWidget {
  final CarEntity car;

  const _CompactCard({required this.car});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 130, child: _CarImage(car: car, height: 130)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                car.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      car.location.isNotEmpty ? car.location : car.province,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _SpecChip(
                    icon: Icons.directions_car_filled_outlined,
                    label: car.brand,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                  _SpecChip(
                    icon: Icons.airline_seat_recline_normal_rounded,
                    label: '${car.seats} chỗ',
                    color: isDark ? AppColors.darkAccent : AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: CarCard._formatPrice(car.pricePerDay),
                            style: AppTypography.priceMedium.copyWith(
                              fontSize: 15.5,
                              color: isDark ? AppColors.darkPrimary : AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' /ngày',
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CarImage extends StatefulWidget {
  final CarEntity car;
  final double? width;
  final double? height;

  const _CarImage({required this.car, this.width, this.height});

  @override
  State<_CarImage> createState() => _CarImageState();
}

class _CarImageState extends State<_CarImage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final images = widget.car.imageUrls.where((url) => url.isNotEmpty).toList();
    if (images.isEmpty && widget.car.imageIcon.isNotEmpty) {
      images.add(widget.car.imageIcon);
    }
    final hasNetworkImages = images.any((e) => e.startsWith('http'));

    final placeholderColor = isDark ? const Color(0xFF1B2C24) : const Color(0xFFEEF0E8);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: placeholderColor,
            ),
            child: hasNetworkImages
                ? (images.length > 1
                    ? PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: placeholderColor,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    isDark ? AppColors.darkPrimary : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, _, _) => Center(
                              child: _carIconFor(widget.car.imageIcon, isDark),
                            ),
                          );
                        },
                      )
                    : CachedNetworkImage(
                        imageUrl: images.first,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: placeholderColor,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                isDark ? AppColors.darkPrimary : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (_, _, _) =>
                            Center(child: _carIconFor(widget.car.imageIcon, isDark)),
                      ))
                : Center(child: _carIconFor(widget.car.imageIcon, isDark)),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.85)
                    : AppColors.textPrimary.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.car.brand.toUpperCase(),
                style: AppTypography.dataLabel.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          if (hasNetworkImages && images.length > 1)
            Positioned(
              bottom: 6,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _carIconFor(String key, bool isDark) {
    return Icon(
      Icons.directions_car_filled_rounded,
      color: isDark ? AppColors.darkPrimary : AppColors.primary,
      size: 40,
    );
  }
}

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _SpecChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = color ?? (isDark ? AppColors.darkPrimary : AppColors.primary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: chipColor.withValues(alpha: isDark ? 0.3 : 0.15),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
