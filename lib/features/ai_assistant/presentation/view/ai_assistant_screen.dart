import 'dart:async';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/domain/repositories/home_repository.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail/car_detail_screen.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

enum AiMessageType { text, carRecommendation }

class AiChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;
  final AiMessageType type;
  final List<CarEntity> recommendedCars;

  AiChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    DateTime? timestamp,
    this.type = AiMessageType.text,
    this.recommendedCars = const [],
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AiChatMessage> _messages = [];
  bool _isThinking = false;
  bool _hasText = false;
  List<CarEntity> _allCars = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _quickChips = const [
    '🚗 Xe 7 chỗ',
    '⚡ Xe điện VinFast',
    '💰 Dưới 900k/ngày',
    '🏙️ Xe 4-5 chỗ đi phố',
    '📋 Thủ tục thuê xe',
    '🛡️ Chính sách hủy & cọc',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText && mounted) {
        setState(() => _hasText = hasText);
      }
    });

    _loadAvailableCars();
    _initWelcomeMessage();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initWelcomeMessage() {
    _messages.add(
      AiChatMessage(
        id: 'welcome_msg',
        isUser: false,
        text:
            'Xin chào! Tôi là Trợ lý AI của CarNow 🚗✨\n\nTôi sẵn sàng hỗ trợ bạn tìm kiếm chiếc xe ưng ý nhất theo số chỗ, tầm giá hoặc giải đáp các thắc mắc về hợp đồng thuê xe.',
        type: AiMessageType.text,
      ),
    );
  }

  Future<void> _loadAvailableCars() async {
    try {
      if (sl.isRegistered<HomeRepository>()) {
        final cars = await sl<HomeRepository>().getCars();
        if (mounted && cars.isNotEmpty) {
          setState(() {
            _allCars = cars;
          });
          return;
        }
      }
    } catch (_) {}

    if (_allCars.isEmpty && mounted) {
      setState(() {
        _allCars = _buildFallbackCars();
      });
    }
  }

  List<CarEntity> _buildFallbackCars() {
    return const [
      CarEntity(
        id: '1',
        name: 'Toyota Fortuner Legender',
        brand: 'Toyota',
        vehicleType: 'SUV',
        province: 'TP. Hồ Chí Minh',
        imageIcon:
            'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=800&q=80',
        imageUrls: [
          'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=800&q=80',
        ],
        pricePerDay: 1300000,
        distanceKm: 2.5,
        seats: 7,
        rating: 4.9,
        location: 'Quận 1, TP. Hồ Chí Minh',
        transmission: 'Số tự động',
        fuelType: 'Dầu Diesel',
        year: 2023,
      ),
      CarEntity(
        id: '2',
        name: 'VinFast VF8 Plus',
        brand: 'VinFast',
        vehicleType: 'SUV Điện',
        province: 'TP. Hồ Chí Minh',
        imageIcon:
            'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=800&q=80',
        imageUrls: [
          'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=800&q=80',
        ],
        pricePerDay: 1100000,
        distanceKm: 3.8,
        seats: 5,
        rating: 4.95,
        location: 'Quận 7, TP. Hồ Chí Minh',
        transmission: 'Số tự động',
        fuelType: 'Điện (EV)',
        year: 2023,
      ),
      CarEntity(
        id: '3',
        name: 'Mazda CX-5 Premium',
        brand: 'Mazda',
        vehicleType: 'Crossover',
        province: 'Hà Nội',
        imageIcon:
            'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=800&q=80',
        imageUrls: [
          'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=800&q=80',
        ],
        pricePerDay: 850000,
        distanceKm: 1.2,
        seats: 5,
        rating: 4.85,
        location: 'Cầu Giấy, Hà Nội',
        transmission: 'Số tự động',
        fuelType: 'Xăng',
        year: 2022,
      ),
      CarEntity(
        id: '4',
        name: 'Mitsubishi Xpander Cross',
        brand: 'Mitsubishi',
        vehicleType: 'MPV',
        province: 'TP. Hồ Chí Minh',
        imageIcon:
            'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=800&q=80',
        imageUrls: [
          'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=800&q=80',
        ],
        pricePerDay: 800000,
        distanceKm: 4.0,
        seats: 7,
        rating: 4.8,
        location: 'Bình Thạnh, TP. Hồ Chí Minh',
        transmission: 'Số tự động',
        fuelType: 'Xăng',
        year: 2023,
      ),
      CarEntity(
        id: '5',
        name: 'Kia Morning GT-Line',
        brand: 'Kia',
        vehicleType: 'Hatchback',
        province: 'Đà Nẵng',
        imageIcon:
            'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?auto=format&fit=crop&w=800&q=80',
        imageUrls: [
          'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?auto=format&fit=crop&w=800&q=80',
        ],
        pricePerDay: 550000,
        distanceKm: 0.8,
        seats: 4,
        rating: 4.75,
        location: 'Hải Châu, Đà Nẵng',
        transmission: 'Số tự động',
        fuelType: 'Xăng',
        year: 2022,
      ),
    ];
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 160,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _sendMessage([String? textToSend]) {
    final query = (textToSend ?? _textController.text).trim();
    if (query.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(
        AiChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          isUser: true,
          text: query,
        ),
      );
      _isThinking = true;
      _hasText = false;
    });
    _textController.clear();
    _scrollToBottom();

    Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _processAiResponse(query);
    });
  }

  void _processAiResponse(String query) {
    final q = query.toLowerCase();

    // 1. CAR RECOMMENDATION INTENTS (Gợi ý xe -> Trả về ô thông tin xe!)
    final bool wants7Seats =
        q.contains('7 chỗ') ||
        q.contains('bảy chỗ') ||
        q.contains('gia đình') ||
        q.contains('đông người');
    final bool wantsElectric =
        q.contains('vinfast') ||
        q.contains('xe điện') ||
        q.contains('vf8') ||
        q.contains('vf9') ||
        q.contains('vf5') ||
        q.contains('ev');
    final bool wantsBudget =
        q.contains('giá rẻ') ||
        q.contains('dưới 800') ||
        q.contains('dưới 900') ||
        q.contains('dưới 1 triệu') ||
        q.contains('tiết kiệm') ||
        q.contains('rẻ');
    final bool wantsSmallCity =
        q.contains('nhỏ gọn') ||
        q.contains('đi phố') ||
        q.contains('4 chỗ') ||
        q.contains('5 chỗ') ||
        q.contains('hatchback') ||
        q.contains('sedan');
    final bool wantsGeneralRecommend =
        q.contains('gợi ý xe') ||
        q.contains('tìm xe') ||
        q.contains('thuê xe') ||
        q.contains('tư vấn xe') ||
        q.contains('mẫu xe nào') ||
        q.contains('xe tự lái');

    if (wants7Seats ||
        wantsElectric ||
        wantsBudget ||
        wantsSmallCity ||
        wantsGeneralRecommend) {
      List<CarEntity> matched = [];

      if (wants7Seats) {
        matched = _allCars.where((c) => c.seats >= 7).toList();
      } else if (wantsElectric) {
        matched = _allCars
            .where(
              (c) =>
                  c.brand.toLowerCase().contains('vinfast') ||
                  (c.fuelType?.toLowerCase().contains('điện') ?? false) ||
                  c.name.toLowerCase().contains('vf'),
            )
            .toList();
      } else if (wantsBudget) {
        matched = _allCars.where((c) => c.pricePerDay <= 950000).toList()
          ..sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
      } else if (wantsSmallCity) {
        matched = _allCars.where((c) => c.seats <= 5).toList();
      } else {
        matched = List<CarEntity>.from(_allCars)
          ..sort((a, b) => b.rating.compareTo(a.rating));
      }

      if (matched.isEmpty) {
        matched = _allCars.take(3).toList();
      }

      String intro;
      if (wants7Seats) {
        intro =
            'Dưới đây là các mẫu xe 7 chỗ rộng rãi, phù hợp nhất cho chuyến đi gia đình hoặc nhóm bạn. Bạn có thể nhấn trực tiếp vào ô xe để xem chi tiết và giữ chỗ nhé:';
      } else if (wantsElectric) {
        intro =
            'Đây là những mẫu xe điện cao cấp, êm ái và bảo vệ môi trường dành cho bạn:';
      } else if (wantsBudget) {
        intro =
            'CarNow AI đã chọn lọc các mẫu xe có biểu phí tiết kiệm nhất cho bạn:';
      } else if (wantsSmallCity) {
        intro =
            'Gợi ý các dòng xe 4-5 chỗ nhỏ gọn, dễ luồn lách và tiết kiệm xăng:';
      } else {
        intro =
            'Dưới đây là những mẫu xe được đánh giá cao và được nhiều khách hàng yêu thích nhất:';
      }

      setState(() {
        _isThinking = false;
        _messages.add(
          AiChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            isUser: false,
            text: intro,
            type: AiMessageType.carRecommendation,
            recommendedCars: matched,
          ),
        );
      });
      _scrollToBottom();
      return;
    }

    // 2. TEXT-ONLY KNOWLEDGE Q&A (Chỉ hiện ô tin nhắn chữ thông thường)
    String replyText;
    if (q.contains('giấy tờ') ||
        q.contains('thủ tục') ||
        q.contains('điều kiện')) {
      replyText =
          '📋 QUY TRÌNH & THỦ TỤC THUÊ XE TỰ LÁI:\n\n'
          '1. Căn cước công dân (CCCD) gắn chip còn hiệu lực.\n'
          '2. Giấy phép lái xe (GPLX) hạng B1/B2 trở lên.\n'
          '3. Tài sản thế chấp: Xe máy kèm cà vẹt chính chủ (trị giá >15 triệu) HOẶC đặt cọc tiền mặt theo thỏa thuận.\n\n'
          'Mọi thủ tục đều được số hóa và ký kết hợp đồng điện tử an toàn ngay trên app CarNow.';
    } else if (q.contains('hủy') ||
        q.contains('tiền cọc') ||
        q.contains('đặt cọc') ||
        q.contains('hoàn tiền')) {
      replyText =
          '🛡️ QUY ĐỊNH HỦY CHUYẾN & HOÀN CỌC MINH BẠCH:\n\n'
          '• Hủy trước 24 giờ nhận xe: Hoàn lại 100% tiền đặt cọc vào Ví CarNow.\n'
          '• Hủy trước 12 - 24 giờ: Phí hủy là 30% tiền cọc (hoàn 70%).\n'
          '• Hủy sát giờ (< 12 giờ): Không hoàn cọc để bảo vệ quyền lợi chuẩn bị xe của chủ xe.\n\n'
          'Tiền hoàn sẽ được chuyển về Ví CarNow của bạn ngay lập tức.';
    } else if (q.contains('bảo hiểm') ||
        q.contains('sự cố') ||
        q.contains('tai nạn')) {
      replyText =
          '🛡️ CHÍNH SÁCH BẢO HIỂM XE:\n\n'
          'Tất cả phương tiện trên CarNow đều sở hữu Bảo hiểm TNDS bắt buộc và gói Bảo hiểm Thân vỏ 2 chiều.\n\n'
          'Nếu phát sinh va quẹt ngoài ý muốn, bạn vui lòng giữ nguyên hiện trường và liên hệ Tổng đài khẩn cấp 1900 6868 để kỹ thuật viên hỗ trợ.';
    } else if (q.contains('xin chào') ||
        q.contains('hello') ||
        q.contains('hi')) {
      replyText =
          'Chào bạn! Rất vui được hỗ trợ bạn hôm nay. Bạn đang lên kế hoạch cho chuyến đi du lịch gia đình, công tác hay cần tìm xe trong phân khúc nào?';
    } else {
      replyText =
          'Cảm ơn câu hỏi của bạn. Tôi là AI chuyên biệt về xe tự lái tại Việt Nam. Bạn có thể thử các mẫu câu như:\n\n'
          '• "Tìm xe 7 chỗ gia đình"\n'
          '• "Gợi ý xe dưới 800k"\n'
          '• "Thuê xe điện VinFast"\n\nTôi sẽ lọc và gửi ngay ô thông tin chi tiết từng xe cho bạn!';
    }

    setState(() {
      _isThinking = false;
      _messages.add(
        AiChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          isUser: false,
          text: replyText,
          type: AiMessageType.text,
        ),
      );
    });
    _scrollToBottom();
  }

  void _openCarDetail(CarEntity car) {
    HapticFeedback.mediumImpact();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CarDetailScreen(car: car)));
  }

  void _clearChat() {
    HapticFeedback.selectionClick();
    setState(() {
      _messages.clear();
      _initWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF0E3A5D))
                    .withValues(alpha: isDark ? 0.35 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Animated Pulsing Glowing Avatar
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0E3A5D), AppColors.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.38),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'CarNow AI Assistant',
                                style: AppTypography.titleMedium.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Trực tuyến • Tư vấn & gợi ý xe tức thì',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 11.5,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── 1. Message Stream OR Interactive Command Center ─────────────
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              children: [
                // Render chat messages
                ..._messages.map((message) {
                  return _ChatBubbleItem(
                    message: message,
                    onCarTap: _openCarDetail,
                  );
                }),

                if (_isThinking) const _AiThinkingBubble(),
              ],
            ),
          ),

          // ── 2. Quick Prompt Chips Bar ───────────────────────────────────
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final prompt = _quickChips[i];
                return TapScale(
                  onTap: () => _sendMessage(prompt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: borderColor, width: 1),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(
                                  0xFF0E3A5D,
                                ).withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      prompt,
                      style: AppTypography.caption.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── 3. High-End All-In-One Floating Input Dock ────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(top: BorderSide(color: borderColor, width: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : const Color(0xFF0E3A5D))
                      .withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceSecondary
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _hasText ? AppColors.accent : borderColor,
                    width: _hasText ? 1.5 : 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _hasText
                          ? AppColors.accent.withValues(alpha: 0.18)
                          : (isDark ? Colors.black : const Color(0xFF0E3A5D))
                                .withValues(alpha: 0.04),
                      blurRadius: _hasText ? 14 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left Sparkle Icon Badge
                    Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(bottom: 2, left: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary),
                            AppColors.accent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Expanding Dynamic TextField
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: TextField(
                          controller: _textController,
                          maxLines: 4,
                          minLines: 1,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Nhập câu hỏi hoặc yêu cầu xe...',
                            hintStyle: TextStyle(
                              color: textSecondary.withValues(alpha: 0.75),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Clear button when user typed text
                    if (_hasText)
                      TapScale(
                        onTap: () {
                          _textController.clear();
                          setState(() => _hasText = false);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8, right: 6),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: textSecondary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: textSecondary,
                          ),
                        ),
                      ),

                    // Embedded Animated Send Button
                    TapScale(
                      onTap: _hasText ? _sendMessage : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.only(bottom: 2, right: 2),
                        decoration: BoxDecoration(
                          gradient: _hasText
                              ? const LinearGradient(
                                  colors: [Color(0xFF0E3A5D), AppColors.accent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: _hasText
                              ? null
                              : (isDark ? AppColors.darkSurface : Colors.white),
                          shape: BoxShape.circle,
                          border: _hasText
                              ? null
                              : Border.all(color: borderColor, width: 1),
                          boxShadow: _hasText
                              ? [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.45,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          size: 20,
                          color: _hasText
                              ? Colors.white
                              : textSecondary.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiHeroBanner extends StatelessWidget {
  final bool isDark;
  final Color primaryColor;

  const _AiHeroBanner({required this.isDark, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF0B1926), Color(0xFF132A3E), Color(0xFF1B3D5A)]
              : const [Color(0xFF09253A), Color(0xFF0E3A5D), Color(0xFF1B4F72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0E3A5D)).withValues(
              alpha: 0.30,
            ),
            blurRadius: 22,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 14, color: AppColors.accent),
                    SizedBox(width: 4),
                    Text(
                      'AI CAR MATCHER 2.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.directions_car_filled_rounded,
                color: Colors.white60,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Tìm chiếc xe hoàn hảo cho bạn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mô tả hành trình của bạn hoặc ngân sách mong muốn, CarNow AI sẽ tự động sàng lọc đội xe tốt nhất.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? null : AppColors.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: textPrimary,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: AppTypography.caption.copyWith(
                color: textSecondary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubbleItem extends StatelessWidget {
  final AiChatMessage message;
  final ValueChanged<CarEntity> onCarTap;

  const _ChatBubbleItem({required this.message, required this.onCarTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;
    final timeStr = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 10, top: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E3A5D), AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
          ],
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Text Bubble with refined borders & shadows (snug fit)
                Container(
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width *
                        (isUser ? 0.78 : 0.85),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [Color(0xFF0E3A5D), Color(0xFF1B4F72)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isUser
                        ? null
                        : (isDark ? AppColors.darkSurface : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                            width: 1,
                          ),
                    boxShadow: isDark ? null : AppColors.shadowSm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.42,
                          color: isUser
                              ? Colors.white
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isUser
                              ? Colors.white70
                              : (isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Ô THÔNG TIN TỪNG XE MỘT (Luxury Showcase Cards) ────────
                if (message.type == AiMessageType.carRecommendation &&
                    message.recommendedCars.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ...message.recommendedCars.map((car) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _AiCarCardItem(
                        car: car,
                        onTap: () => onCarTap(car),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiCarCardItem extends StatelessWidget {
  final CarEntity car;
  final VoidCallback onTap;

  const _AiCarCardItem({required this.car, required this.onTap});

  String _formatPrice(num price) {
    return NumberFormat.decimalPattern('vi_VN').format(price);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return TapScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF0E3A5D).withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Banner with Glass Badges
            Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: car.imageIcon,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: isDark
                          ? AppColors.darkSurfaceSecondary
                          : AppColors.background,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: isDark
                          ? AppColors.darkSurfaceSecondary
                          : AppColors.background,
                      child: Icon(
                        Icons.directions_car_filled_rounded,
                        size: 48,
                        color: textSecondary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),

                // Dark subtle gradient scrim at bottom of image
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Rating Glass Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.60),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB300),
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          car.rating > 0
                              ? car.rating.toStringAsFixed(1)
                              : '5.0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // AI Match Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE86000), Color(0xFFFF8533)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE86000).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'GỢI Ý TỐI ƯU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Price Tag over photo
                Positioned(
                  bottom: 10,
                  left: 14,
                  child: Row(
                    children: [
                      Text(
                        '${_formatPrice(car.pricePerDay)}đ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ngày',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Card Body Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      fontSize: 16.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          car.location.isNotEmpty ? car.location : car.province,
                          style: AppTypography.caption.copyWith(
                            color: textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Spec Pills
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _CarSpecPill(
                        icon: Icons.airline_seat_recline_normal_rounded,
                        label: '${car.seats} chỗ',
                      ),
                      _CarSpecPill(
                        icon: Icons.tune_rounded,
                        label: car.transmission ?? 'Tự động',
                      ),
                      _CarSpecPill(
                        icon: Icons.local_gas_station_rounded,
                        label: car.fuelType ?? 'Xăng',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Full-width CTA button to view car details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          Color.lerp(
                            primaryColor,
                            const Color(0xFF1B4F72),
                            0.5,
                          )!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Xem chi tiết xe & Đặt giữ chỗ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarSpecPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CarSpecPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark
        ? AppColors.darkSurfaceSecondary
        : AppColors.background;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiThinkingBubble extends StatefulWidget {
  const _AiThinkingBubble({super.key});

  @override
  State<_AiThinkingBubble> createState() => _AiThinkingBubbleState();
}

class _AiThinkingBubbleState extends State<_AiThinkingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0E3A5D), AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
              boxShadow: isDark ? null : AppColors.shadowSm,
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final progress = (_controller.value - delay) % 1.0;
                    final bounce = (progress < 0.5)
                        ? (1.0 - (progress * 2 - 0.5).abs() * 2)
                        : 0.0;
                    final double translation = -3.5 * bounce;
                    final double opacity = 0.35 + 0.65 * bounce;

                    return Transform.translate(
                      offset: Offset(0, translation),
                      child: Container(
                        margin: EdgeInsets.only(left: index == 0 ? 0 : 5),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: opacity),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
