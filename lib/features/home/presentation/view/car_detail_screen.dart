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
  bool _isFavorite = false;
  DateTimeRange? _selectedDateRange;

  CarEntity get car => widget.car;

  @override
  void initState() {
    super.initState();
    // Khởi tạo mặc định ngày thuê 1 ngày (từ hôm nay đến ngày mai)
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
            expandedHeight: 310,
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
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          child: const Icon(Icons.directions_car_filled_outlined,
                              size: 80, color: AppColors.primary),
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

                  // 3. Thông số nổi bật (Horizontal Spec Highlights)
                  _SectionTitle(title: 'Thông số kỹ thuật'),
                  const SizedBox(height: 12),
                  _SpecGrid(specs: [
                    _SpecItem(icon: Icons.apartment_outlined, label: 'Hãng xe', value: car.brand),
                    _SpecItem(icon: Icons.directions_car_outlined, label: 'Loại xe', value: car.vehicleType),
                    _SpecItem(icon: Icons.people_alt_outlined, label: 'Số chỗ', value: '${car.seats} chỗ'),
                    _SpecItem(
                        icon: Icons.settings_suggest_outlined,
                        label: 'Hộp số',
                        value: car.transmission ?? 'Tự động'),
                    _SpecItem(
                        icon: Icons.local_gas_station_outlined,
                        label: 'Nhiên liệu',
                        value: car.fuelType ?? 'Xăng'),
                    if (car.year != null)
                      _SpecItem(icon: Icons.calendar_today_outlined, label: 'Năm sản xuất', value: '${car.year}'),
                    if (car.color != null)
                      _SpecItem(icon: Icons.palette_outlined, label: 'Màu xe', value: car.color!),
                    if (car.model != null)
                      _SpecItem(icon: Icons.time_to_leave_outlined, label: 'Model', value: car.model!),
                  ]),
                  const SizedBox(height: 24),

                  // 4. Tiện nghi xe (Features / Amenities)
                  _SectionTitle(title: 'Tiện nghi trên xe'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _FeatureChip(icon: Icons.bluetooth_rounded, label: 'Bluetooth'),
                      _FeatureChip(icon: Icons.map_outlined, label: 'Bản đồ GPS'),
                      _FeatureChip(icon: Icons.videocam_outlined, label: 'Camera lùi'),
                      _FeatureChip(icon: Icons.ac_unit_rounded, label: 'Điều hòa 2 vùng'),
                      _FeatureChip(icon: Icons.key_rounded, label: 'Smartkey'),
                      _FeatureChip(icon: Icons.speed_rounded, label: 'Cruise Control'),
                      _FeatureChip(icon: Icons.child_care_rounded, label: 'Ghế trẻ em'),
                      _FeatureChip(icon: Icons.usb_rounded, label: 'Cổng sạc USB'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 5. Mô tả xe
                  if (car.description?.isNotEmpty == true) ...[
                    _SectionTitle(title: 'Mô tả chi tiết'),
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

                  // 6. Thông tin chủ xe (Owner Info)
                  _SectionTitle(title: 'Thông tin chủ xe'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.person, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Chủ xe Uy tín',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(Icons.verified_rounded, size: 18, color: Colors.blue.shade600),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: const [
                                      Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                      SizedBox(width: 3),
                                      Text('4.9',
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary)),
                                      SizedBox(width: 8),
                                      Text('• Tỷ lệ phản hồi 100%',
                                          style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đang kết nối tin nhắn với chủ xe...')),
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                label: const Text('Nhắn tin'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đang gọi điện cho chủ xe...')),
                                  );
                                },
                                icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                                label: const Text('Gọi điện'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 7. Giấy tờ & Điều khoản thuê xe
                  _SectionTitle(title: 'Giấy tờ & Điều khoản thuê xe'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: const [
                        _TermRow(
                          icon: Icons.badge_outlined,
                          title: 'Giấy tờ bắt buộc',
                          desc: 'GPLX (hạng B2 trở lên) + CCCD gắn chip đối chiếu khi nhận xe.',
                        ),
                        Divider(height: 20, color: AppColors.border),
                        _TermRow(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Tài sản thế chấp',
                          desc: '15.000.000đ tiền mặt hoặc Xe máy chính chủ kèm cavet xe.',
                        ),
                        Divider(height: 20, color: AppColors.border),
                        _TermRow(
                          icon: Icons.local_gas_station_outlined,
                          title: 'Quy định nhiên liệu',
                          desc: 'Trả xe nguyên trạng mức nhiên liệu như khi bàn giao.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 8. Đánh giá từ người thuê
                  _SectionTitle(title: 'Đánh giá từ khách hàng (24)'),
                  const SizedBox(height: 12),
                  const _ReviewCard(
                    name: 'Nguyễn Văn Minh',
                    date: '02/08/2026',
                    rating: 5.0,
                    comment: 'Xe mới, sạch sẽ, máy êm. Chủ xe giao nhận đúng giờ và nhiệt tình!',
                  ),
                  const SizedBox(height: 10),
                  const _ReviewCard(
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
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
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
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Icon(Icons.edit_outlined, size: 16, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chi tiết bảng giá
                  const Text('Chi tiết thanh toán',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  _CostRow(label: 'Giá thuê ($_rentalDays ngày)', value: _formatPrice(_totalPrice)),
                  const SizedBox(height: 6),
                  _CostRow(label: 'Bảo hiểm chuyến đi', value: _formatPrice(50000 * _rentalDays)),
                  const SizedBox(height: 6),
                  _CostRow(label: 'Phí dịch vụ', value: _formatPrice(30000)),
                  const Divider(height: 20, color: AppColors.border),
                  _CostRow(
                    label: 'Tổng số tiền',
                    value: _formatPrice(_totalPrice + (50000 * _rentalDays) + 30000),
                    isBold: true,
                  ),
                  const SizedBox(height: 24),

                  // Nút bấm đặt
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                                SizedBox(width: 10),
                                Text('Đặt xe thành công!'),
                              ],
                            ),
                            content: Text(
                              'Đơn đặt xe ${car.name} của bạn đã được gửi cho chủ xe. Mã đơn: #CAR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                              style: const TextStyle(height: 1.5),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Đóng'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Xác nhận Đặt xe',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Custom Helper Widgets ───────────────────────────────────────────────────

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
                    Text(spec.label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
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

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TermRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _TermRow({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String date;
  final double rating;
  final String comment;

  const _ReviewCard({
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
              Text(date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                size: 14,
                color: Colors.amber,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(comment, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _CostRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: isBold ? 15 : 13.5,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            )),
        Text(value,
            style: TextStyle(
              fontSize: isBold ? 17 : 14,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              color: isBold ? AppColors.accent : AppColors.textPrimary,
            )),
      ],
    );
  }
}

