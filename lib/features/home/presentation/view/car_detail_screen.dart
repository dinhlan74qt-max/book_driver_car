import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CarDetailScreen extends StatefulWidget {
  final CarEntity car;

  const CarDetailScreen({super.key, required this.car});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  int _currentImage = 0;

  CarEntity get car => widget.car;

  String _formatPrice(num price) {
    final s = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buffer.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
    }
    return '${buffer.toString()} VND';
  }

  @override
  Widget build(BuildContext context) {
    final images = car.imageUrls.isNotEmpty ? car.imageUrls : [car.imageIcon];
    final hasImages = images.any((e) => e.startsWith('http'));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar + Gallery ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Ảnh carousel
                  if (hasImages)
                    PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _currentImage = i),
                      itemBuilder: (_, i) => Image.network(
                        images[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          child: const Icon(Icons.directions_car_filled_outlined,
                              size: 80, color: AppColors.primary),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.accent.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.directions_car_filled_rounded,
                            size: 96, color: Colors.white),
                      ),
                    ),
                  // Gradient overlay phía dưới
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Dots indicator
                  if (images.length > 1)
                    Positioned(
                      bottom: 14,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImage == i ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentImage == i
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Nội dung chi tiết ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên xe + đánh giá
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          car.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              car.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Địa chỉ
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          car.location.isNotEmpty ? car.location : car.province,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Thông số kỹ thuật
                  _SectionTitle(title: 'Thông số xe'),
                  const SizedBox(height: 12),
                  _SpecGrid(specs: [
                    _SpecItem(icon: Icons.apartment_outlined, label: 'Hãng xe', value: car.brand),
                    _SpecItem(icon: Icons.directions_car_outlined, label: 'Loại xe', value: car.vehicleType),
                    _SpecItem(icon: Icons.people_alt_outlined, label: 'Số chỗ', value: '${car.seats} chỗ'),
                    if (car.model != null)
                      _SpecItem(icon: Icons.time_to_leave_outlined, label: 'Model', value: car.model!),
                    if (car.year != null)
                      _SpecItem(icon: Icons.calendar_today_outlined, label: 'Năm SX', value: '${car.year}'),
                    if (car.color != null)
                      _SpecItem(icon: Icons.palette_outlined, label: 'Màu sắc', value: car.color!),
                    if (car.fuelType != null)
                      _SpecItem(icon: Icons.local_gas_station_outlined, label: 'Nhiên liệu', value: car.fuelType!),
                    if (car.transmission != null)
                      _SpecItem(icon: Icons.settings_outlined, label: 'Hộp số', value: car.transmission!),
                  ]),
                  const SizedBox(height: 20),

                  // Mô tả
                  if (car.description?.isNotEmpty == true) ...[
                    _SectionTitle(title: 'Mô tả'),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        car.description!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.6,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Giá
                  _SectionTitle(title: 'Giá thuê'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Giá/ngày', style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          _formatPrice(car.pricePerDay),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Nút Đặt xe ──────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Giá/ngày', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                Text(
                  _formatPrice(car.pricePerDay),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đặt xe ${car.name} — tính năng sắp có!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Đặt xe ngay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets phụ ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
    );
  }
}

class _SpecItem {
  final IconData icon;
  final String label;
  final String value;
  const _SpecItem({required this.icon, required this.label, required this.value});
}

class _SpecGrid extends StatelessWidget {
  final List<_SpecItem> specs;
  const _SpecGrid({required this.specs});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: specs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        final spec = specs[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(spec.icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(spec.label,
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    Text(spec.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
