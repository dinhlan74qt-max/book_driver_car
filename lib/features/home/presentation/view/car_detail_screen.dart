import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';

import 'package:book_drive_car/features/home/presentation/widget/car_detail_review_card.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_detail_spec_grid.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_detail_terms_card.dart';
import 'package:flutter/material.dart';
import 'package:book_drive_car/core/utils/responsive_utils.dart';


class CarDetailScreen extends StatefulWidget {
  final CarEntity car;

  const CarDetailScreen({super.key, required this.car});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  int _currentImage = 0;
  bool _isFavorite = false;
  DateTimeRange? _selectedDateRange;

  CarEntity get car => widget.car;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: now,
      end: now.add(const Duration(days: 1)),
    );
  }

  String _formatPrice(num price) {
    final s = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buffer.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
    }
    return '${buffer.toString()}đ';
  }

  int get _rentalDays {
    if (_selectedDateRange == null) return 1;
    final days = _selectedDateRange!.duration.inDays;
    return days < 1 ? 1 : days;
  }

  int get _totalPrice {
    return car.pricePerDay * _rentalDays;
  }

  @override
  Widget build(BuildContext context) {
    final images = car.imageUrls.isNotEmpty ? car.imageUrls : [car.imageIcon];
    final hasImages = images.any((e) => e.startsWith('http'));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar + Gallery Carousel ──────────────────────────────
          SliverAppBar(
            expandedHeight: context.isTablet ? 420 : 310,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? Colors.redAccent : Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isFavorite ? 'Đã thêm vào yêu thích' : 'Đã xóa khỏi yêu thích'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Chia sẻ thông tin xe ${car.name}'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Carousel Ảnh
                  if (hasImages)
                    PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _currentImage = i),
                      itemBuilder: (_, i) => Image.network(
                        images[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, _) => Container(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          child: const Icon(
                            Icons.directions_car_filled_outlined,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            Color(0xFF2C3E50),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.directions_car_filled_rounded,
                            size: 96, color: Colors.white),
                      ),
                    ),

                  // Badge thương hiệu góc trên
                  Positioned(
                    top: 90,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        car.brand.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Gradient đen mờ ở viền dưới
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 90,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Dots chỉ số trang ảnh
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
                            width: _currentImage == i ? 22 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _currentImage == i
                                  ? AppColors.accent
                                  : Colors.white.withValues(alpha: 0.6),
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
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tên xe + Đánh giá + Biển số
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.name,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    car.vehicleType,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                if (car.licensePlate != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.amber.shade400, width: 0.8),
                                    ),
                                    child: Text(
                                      car.licensePlate!,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF7D5A00),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade300, width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              car.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2. Vị trí + Khoảng cách
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on, size: 18, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car.location.isNotEmpty ? car.location : car.province,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Cách bạn khoảng ${car.distanceKm.toStringAsFixed(1)} km',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Thông số kỹ thuật
                  const _SectionTitle(title: 'Thông số kỹ thuật'),
                  const SizedBox(height: 12),
                  CarDetailSpecGrid(specs: [
                    SpecItem(icon: Icons.apartment_outlined, label: 'Hãng xe', value: car.brand),
                    SpecItem(icon: Icons.directions_car_outlined, label: 'Loại xe', value: car.vehicleType),
                    SpecItem(icon: Icons.people_alt_outlined, label: 'Số chỗ', value: '${car.seats} chỗ'),
                    SpecItem(
                        icon: Icons.settings_suggest_outlined,
                        label: 'Hộp số',
                        value: car.transmission ?? 'Tự động'),
                    SpecItem(
                        icon: Icons.local_gas_station_outlined,
                        label: 'Nhiên liệu',
                        value: car.fuelType ?? 'Xăng'),
                    if (car.year != null)
                      SpecItem(icon: Icons.calendar_today_outlined, label: 'Năm sản xuất', value: '${car.year}'),
                    if (car.color != null)
                      SpecItem(icon: Icons.palette_outlined, label: 'Màu xe', value: car.color!),
                    if (car.model != null)
                      SpecItem(icon: Icons.time_to_leave_outlined, label: 'Model', value: car.model!),
                  ]),
                  const SizedBox(height: 24),

                  // 4. Tiện nghi xe
                  const _SectionTitle(title: 'Tiện nghi trên xe'),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FeatureChip(icon: Icons.bluetooth_rounded, label: 'Bluetooth'),
                      FeatureChip(icon: Icons.map_outlined, label: 'Bản đồ GPS'),
                      FeatureChip(icon: Icons.videocam_outlined, label: 'Camera lùi'),
                      FeatureChip(icon: Icons.ac_unit_rounded, label: 'Điều hòa 2 vùng'),
                      FeatureChip(icon: Icons.key_rounded, label: 'Smartkey'),
                      FeatureChip(icon: Icons.speed_rounded, label: 'Cruise Control'),
                      FeatureChip(icon: Icons.child_care_rounded, label: 'Ghế trẻ em'),
                      FeatureChip(icon: Icons.usb_rounded, label: 'Cổng sạc USB'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 5. Mô tả xe
                  if (car.description?.isNotEmpty == true) ...[
                    const _SectionTitle(title: 'Mô tả chi tiết'),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                    const SizedBox(height: 24),
                  ],



                  // 7. Giấy tờ & Điều khoản thuê xe
                  const _SectionTitle(title: 'Giấy tờ & Điều khoản thuê xe'),
                  const SizedBox(height: 12),
                  const CarDetailTermsCard(),
                  const SizedBox(height: 24),

                  // 8. Đánh giá từ người thuê
                  const _SectionTitle(title: 'Đánh giá từ khách hàng (24)'),
                  const SizedBox(height: 12),
                  const CarDetailReviewCard(
                    name: 'Nguyễn Văn Minh',
                    date: '02/08/2026',
                    rating: 5.0,
                    comment: 'Xe mới, sạch sẽ, máy êm. Chủ xe giao nhận đúng giờ và nhiệt tình!',
                  ),
                  const SizedBox(height: 10),
                  const CarDetailReviewCard(
                    name: 'Trần Thị Thu',
                    date: '28/07/2026',
                    rating: 4.8,
                    comment: 'Chuyến đi tuyệt vời, xe tiết kiệm nhiên liệu. Sẽ quay lại thuê tiếp.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Thanh Đặt xe dưới cùng (Bottom Action Bar) ──────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Giá thuê 1 ngày',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                const SizedBox(height: 2),
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
            const SizedBox(width: 20),
            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF2C3E50)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _showBookingBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đặt xe ngay',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Modal Bottom Sheet Đặt Xe Chi Tiết ─────────────────────────────────────
  void _showBookingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Xác nhận đặt xe ${car.name}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),

                  // Chọn số ngày thuê
                  const Text('Thời gian thuê xe',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                        initialDateRange: _selectedDateRange,
                      );
                      if (picked != null) {
                        setState(() => _selectedDateRange = picked);
                        setModalState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${_selectedDateRange?.start.day}/${_selectedDateRange?.start.month} - ${_selectedDateRange?.end.day}/${_selectedDateRange?.end.month}/${_selectedDateRange?.end.year} ($_rentalDays ngày)',
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Icon(Icons.edit_calendar_rounded, color: AppColors.textMuted, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bảng tính tổng phí
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Đơn giá thuê (1 ngày)', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                            Text(_formatPrice(car.pricePerDay),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Số ngày thuê', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                            Text('$_rentalDays ngày',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                        const Divider(height: 20, color: AppColors.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng tiền tạm tính',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            Text(
                              _formatPrice(_totalPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nút xác nhận
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Đặt xe thành công! Tổng tiền ${_formatPrice(_totalPrice)} cho $_rentalDays ngày.'),
                            backgroundColor: Colors.green.shade700,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Xác nhận đặt xe',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}
