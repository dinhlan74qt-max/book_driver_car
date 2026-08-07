import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/profile/domain/entities/vehicle_entity.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VehicleDetailScreen extends StatefulWidget {
  final VehicleEntity vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late final PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _imageUrls =>
      widget.vehicle.imageUrls.where((url) => url.trim().isNotEmpty).toList();

  String _formatPrice(num price) {
    return NumberFormat.decimalPattern('vi_VN').format(price);
  }

  String _joinNonEmpty(Iterable<String> values) {
    return values.where((value) => value.trim().isNotEmpty).join(' • ');
  }

  String _locationText() {
    final parts = [
      widget.vehicle.address.addressDetail,
      widget.vehicle.address.ward,
      widget.vehicle.address.district,
      widget.vehicle.address.city,
    ];
    return _joinNonEmpty(parts);
  }

  Future<void> _changeImage(int delta) async {
    if (!_pageController.hasClients || _imageUrls.length <= 1) return;

    final int nextIndex =
        (_currentImageIndex + delta).clamp(0, _imageUrls.length - 1) as int;
    if (nextIndex == _currentImageIndex) return;

    await _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return AppColors.success;
      case 'PENDING':
        return AppColors.accent;
      case 'REJECTED':
      case 'UNAVAILABLE':
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final status = vehicle.status.trim().isEmpty ? 'UNKNOWN' : vehicle.status;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.asphalt,
                      AppColors.asphalt.withBlue(40),
                      AppColors.primary.withOpacity(0.92),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TapScale(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      vehicle.vehicleName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _joinNonEmpty([
                        if (vehicle.brand.isNotEmpty) vehicle.brand,
                        if (vehicle.model.isNotEmpty) vehicle.model,
                        if (vehicle.year > 0) vehicle.year.toString(),
                      ]),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TopChip(
                          icon: Icons.payments_rounded,
                          label: '${_formatPrice(vehicle.pricePerDay)} đ/ngày',
                        ),
                        _TopChip(
                          icon: Icons.directions_car_filled_rounded,
                          label: vehicle.vehicleType.isNotEmpty
                              ? vehicle.vehicleType
                              : '${vehicle.seatCount} chỗ',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GalleryCard(
                      images: _imageUrls,
                      currentIndex: _currentImageIndex,
                      onIndexChanged: (index) {
                        if (!mounted) return;
                        setState(() => _currentImageIndex = index);
                      },
                      onPrevious: () => _changeImage(-1),
                      onNext: () => _changeImage(1),
                      pageController: _pageController,
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: 'Tổng quan xe',
                      icon: Icons.dashboard_customize_rounded,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _InfoChip(label: '${vehicle.seatCount} chỗ'),
                          if (vehicle.fuelType.isNotEmpty)
                            _InfoChip(label: vehicle.fuelType),
                          if (vehicle.transmission.isNotEmpty)
                            _InfoChip(label: vehicle.transmission),
                          if (vehicle.color.isNotEmpty)
                            _InfoChip(label: vehicle.color),
                          if (vehicle.licensePlate.isNotEmpty)
                            _InfoChip(label: vehicle.licensePlate),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Thông tin chi tiết',
                      icon: Icons.info_outline_rounded,
                      child: Column(
                        children: [
                          _DetailRow(
                            label: 'Hãng xe',
                            value: vehicle.brand.isNotEmpty
                                ? vehicle.brand
                                : 'Chưa cập nhật',
                          ),
                          _DetailRow(
                            label: 'Dòng xe',
                            value: vehicle.model.isNotEmpty
                                ? vehicle.model
                                : 'Chưa cập nhật',
                          ),
                          _DetailRow(
                            label: 'Năm sản xuất',
                            value: vehicle.year > 0
                                ? vehicle.year.toString()
                                : 'Chưa cập nhật',
                          ),
                          _DetailRow(
                            label: 'Trạng thái',
                            value: status,
                            valueColor: _statusColor(status),
                          ),
                          _DetailRow(
                            label: 'Giá thuê',
                            value:
                                '${_formatPrice(vehicle.pricePerDay)} đ/ngày',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Địa chỉ xe',
                      icon: Icons.place_outlined,
                      child: Text(
                        _locationText().isNotEmpty
                            ? _locationText()
                            : 'Chưa có thông tin địa chỉ.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Mô tả',
                      icon: Icons.subject_rounded,
                      child: Text(
                        vehicle.description.isNotEmpty
                            ? vehicle.description
                            : 'Chưa có mô tả cho xe này.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Ảnh giấy tờ',
                      icon: Icons.description_rounded,
                      child: Text(
                        vehicle.vehicleRegistration.isNotEmpty
                            ? vehicle.vehicleRegistration
                            : 'Chưa tải ảnh giấy tờ xe.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Quay lại danh sách'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final List<String> images;
  final int currentIndex;
  final PageController pageController;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _GalleryCard({
    required this.images,
    required this.currentIndex,
    required this.pageController,
    required this.onIndexChanged,
    required this.onPrevious,
    required this.onNext,
  });

  bool get _hasMultipleImages => images.length > 1;

  String _imageLabel(int index) {
    const labels = ['Mặt trước', 'Mặt sau', 'Bên trái', 'Bên phải'];
    if (index < labels.length) return labels[index];
    return 'Ảnh ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Ảnh 4 mặt',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${images.isEmpty ? 0 : currentIndex + 1}/${images.isEmpty ? 0 : images.length}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: images.isNotEmpty
                        ? PageView.builder(
                            controller: pageController,
                            onPageChanged: onIndexChanged,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return _GalleryImage(imageUrl: images[index]);
                            },
                          )
                        : const _GalleryEmptyState(),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.22),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: _ImageLabel(
                      text: images.isEmpty
                          ? 'Chưa có ảnh'
                          : _imageLabel(currentIndex),
                    ),
                  ),
                  if (_hasMultipleImages)
                    Positioned(
                      left: 10,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _ArrowButton(
                          icon: Icons.chevron_left_rounded,
                          onTap: onPrevious,
                        ),
                      ),
                    ),
                  if (_hasMultipleImages)
                    Positioned(
                      right: 10,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _ArrowButton(
                          icon: Icons.chevron_right_rounded,
                          onTap: onNext,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (images.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final active = index == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

class _GalleryImage extends StatelessWidget {
  final String imageUrl;

  const _GalleryImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.background,
            alignment: Alignment.center,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.directions_car_filled_rounded,
                  size: 44,
                  color: AppColors.textMuted,
                ),
                SizedBox(height: 8),
                Text(
                  'Không tải được ảnh',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppColors.background,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          },
        ),
      ],
    );
  }
}

class _ImageLabel extends StatelessWidget {
  final String text;

  const _ImageLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.52),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GalleryEmptyState extends StatelessWidget {
  const _GalleryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_library_outlined,
            size: 44,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 10),
          const Text(
            'Chưa có ảnh xe',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.38),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TopChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color _color() {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return AppColors.success;
      case 'PENDING':
        return AppColors.accent;
      case 'REJECTED':
      case 'UNAVAILABLE':
        return AppColors.danger;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
