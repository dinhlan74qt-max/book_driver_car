import 'dart:math' as math;
import 'package:book_drive_car/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';

/// Hiệu ứng chuyển cảnh (Theme Transition Ripple) mượt mà 60/120fps chuẩn flagship
/// Khi đổi giao diện Sáng / Tối, một làn sóng radial ripple thanh lịch sẽ lan tỏa
/// từ vị trí chạm ra toàn bộ màn hình và tan biến tự nhiên, kết hợp cùng AnimatedTheme.
class ThemeTransitionWrapper extends StatefulWidget {
  final Widget child;

  const ThemeTransitionWrapper({super.key, required this.child});

  @override
  State<ThemeTransitionWrapper> createState() => _ThemeTransitionWrapperState();
}

class _ThemeTransitionWrapperState extends State<ThemeTransitionWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _toDark = false;
  Offset? _origin;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    themeController.transitionTrigger.addListener(_onThemeTransitionTriggered);
  }

  void _onThemeTransitionTriggered() {
    if (!mounted) return;
    setState(() {
      _toDark = themeController.isDarkMode;
      _origin = themeController.lastTransitionOrigin;
    });
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    themeController.transitionTrigger.removeListener(_onThemeTransitionTriggered);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            if (_controller.value <= 0.0 || _controller.value >= 1.0) {
              return const SizedBox.shrink();
            }
            final size = MediaQuery.of(context).size;
            final origin = _origin ?? Offset(size.width / 2, size.height / 2);

            return IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  size: size,
                  painter: _ThemeRipplePainter(
                    progress: _animation.value,
                    toDark: _toDark,
                    origin: origin,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ThemeRipplePainter extends CustomPainter {
  final double progress; // 0.0 -> 1.0
  final bool toDark;
  final Offset origin;

  _ThemeRipplePainter({
    required this.progress,
    required this.toDark,
    required this.origin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    // Khoảng cách xa nhất từ điểm chạm tới 4 góc màn hình
    final dx = math.max(origin.dx, size.width - origin.dx);
    final dy = math.max(origin.dy, size.height - origin.dy);
    final maxRadius = math.sqrt(dx * dx + dy * dy);

    final currentRadius = maxRadius * progress;

    // Fade out êm ái ở 35% chặng cuối
    final opacity = progress < 0.65
        ? 0.70
        : (0.70 * (1.0 - (progress - 0.65) / 0.35));

    final baseColor = toDark
        ? const Color(0xFF0B0E14)
        : const Color(0xFFF1F5F9);

    final glowColor = toDark
        ? const Color(0xFF38BDF8)
        : const Color(0xFF0E3A5D);

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final normX = ((origin.dx / size.width) * 2 - 1).clamp(-1.0, 1.0);
    final normY = ((origin.dy / size.height) * 2 - 1).clamp(-1.0, 1.0);

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(normX, normY),
        radius: (currentRadius / size.width).clamp(0.001, 10.0),
        colors: [
          baseColor.withValues(alpha: opacity),
          baseColor.withValues(alpha: opacity * 0.85),
          glowColor.withValues(alpha: opacity * 0.30),
          Colors.transparent,
        ],
        stops: const [0.0, 0.70, 0.92, 1.0],
      ).createShader(rect);

    canvas.drawCircle(origin, currentRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _ThemeRipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
