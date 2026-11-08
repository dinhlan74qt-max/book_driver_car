import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';
import 'package:book_drive_car/features/ai_assistant/presentation/bloc/ai_assistant_event.dart';
import 'package:book_drive_car/features/ai_assistant/presentation/bloc/ai_assistant_state.dart';
import 'package:book_drive_car/features/ai_assistant/presentation/bloc/ai_chat_message.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail/car_detail_screen.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AiAssistantBloc>(
      create: (_) => sl<AiAssistantBloc>(),
      child: const _AiAssistantView(),
    );
  }
}

class _AiAssistantView extends StatefulWidget {
  const _AiAssistantView();

  @override
  State<_AiAssistantView> createState() => _AiAssistantViewState();
}

class _AiAssistantViewState extends State<_AiAssistantView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _quickChips = const [
    '🏖️ Tìm ô tô 4 chỗ ở Đà Nẵng, giá dưới 1 triệu/ngày',
    '🚗 Xe 7 chỗ đi gia đình',
    '⚡ Xe điện VinFast',
    '💰 Dưới 800k/ngày',
    '📋 Thủ tục thuê xe tự lái',
    '🛡️ Chính sách cọc xe',
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
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
    context.read<AiAssistantBloc>().add(AiSendMessageEvent(query));
    _textController.clear();
    setState(() => _hasText = false);
    _scrollToBottom();
  }

  void _openCarDetail(CarEntity car) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CarDetailScreen(car: car)));
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Làm mới đoạn chat?',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Lịch sử trò chuyện hiện tại với AI sẽ được xóa để bắt đầu phiên tư vấn mới.',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<AiAssistantBloc>().add(const AiResetChatEvent());
              },
              child: const Text('Bắt đầu lại'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return BlocConsumer<AiAssistantBloc, AiAssistantState>(
      listener: (context, state) {
        _scrollToBottom();
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: bgColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 0.8),
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Animated Pulsing Avatar
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
                                    color: AppColors.accent.withValues(
                                      alpha: 0.38,
                                    ),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.14,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'CarNow AI',
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
                                    state.isThinking
                                        ? 'Đang phân tích & tìm xe tốt nhất...'
                                        : 'Trực tuyến',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 11.5,
                                      color: state.isThinking
                                          ? AppColors.accent
                                          : AppColors.success,
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
                      // Nút làm mới đoạn chat
                      IconButton(
                        tooltip: 'Làm mới cuộc trò chuyện',
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: textSecondary,
                          size: 22,
                        ),
                        onPressed: _showResetConfirmDialog,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              // ── 1. Message Stream ─────────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  children: [
                    ...state.messages.map((message) {
                      return _ChatBubbleItem(
                        message: message,
                        onCarTap: _openCarDetail,
                      );
                    }),
                    if (state.isThinking) const _AiThinkingBubble(),
                  ],
                ),
              ),

              // ── 2. Quick Prompt Chips Bar ─────────────────────────────────
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

              // ── 3. High-End All-In-One Floating Input Dock ────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(
                    top: BorderSide(color: borderColor, width: 0.8),
                  ),
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
                              : (isDark
                                        ? Colors.black
                                        : const Color(0xFF0E3A5D))
                                    .withValues(alpha: 0.04),
                          blurRadius: _hasText ? 14 : 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
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
                                isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.primary,
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
                                hintText: 'Tìm ô tô 4 chỗ ở Đà Nẵng...',
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
                                      colors: [
                                        Color(0xFF0E3A5D),
                                        AppColors.accent,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: _hasText
                                  ? null
                                  : (isDark
                                        ? AppColors.darkSurface
                                        : Colors.white),
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
      },
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
    final isError = message.isError;
    final timeStr = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
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
                    gradient: LinearGradient(
                      colors: isError
                          ? const [Color(0xFFB71C1C), Color(0xFFE53935)]
                          : const [Color(0xFF0E3A5D), AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isError ? Colors.red : AppColors.accent)
                            .withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isError
                        ? Icons.error_outline_rounded
                        : Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ],
              Flexible(
                child: Container(
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
                        : isError
                        ? (isDark
                              ? const Color(0xFF3B1818)
                              : const Color(0xFFFFEBEE))
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
                            color: isError
                                ? (isDark
                                      ? Colors.red.withValues(alpha: 0.5)
                                      : Colors.red.withValues(alpha: 0.3))
                                : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.border),
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
                      SelectableText(
                        message.text,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: isUser
                              ? Colors.white
                              : isError
                              ? (isDark
                                    ? const Color(0xFFFF8A80)
                                    : const Color(0xFFC62828))
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 4),
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
              ),
            ],
          ),

          // ── Danh sách xe AI gợi ý (Hiển thị ngay bên dưới để người dùng xem và nhấn vào) ───
          if (!isUser && message.recommendedCars.isNotEmpty) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.directions_car_filled_rounded,
                          size: 15,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Xe đề xuất cho bạn (${message.recommendedCars.length} xe)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
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
              ),
            ),
          ],
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
    final displayImage = car.imageIcon.isNotEmpty
        ? car.imageIcon
        : (car.imageUrls.isNotEmpty ? car.imageUrls.first : '');

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
            // Top Image Banner
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
                        )
                      : Container(
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

                // Dark subtle gradient scrim at bottom of image
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.70),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // AI Match Badge
                Positioned(
                  top: 12,
                  left: 12,
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

                // Floating Price Tag
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
                      const Icon(
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
                        label: car.transmission?.isNotEmpty == true
                            ? car.transmission!
                            : 'Số tự động',
                      ),
                      _CarSpecPill(
                        icon: Icons.local_gas_station_rounded,
                        label: car.fuelType?.isNotEmpty == true
                            ? car.fuelType!
                            : 'Xăng',
                      ),
                      if (car.color?.isNotEmpty == true)
                        _CarSpecPill(
                          icon: Icons.palette_outlined,
                          label: car.color!,
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
  const _AiThinkingBubble();

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
