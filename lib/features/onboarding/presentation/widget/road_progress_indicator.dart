import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RoadProgressIndicator extends StatelessWidget {
  final double page;
  final int pageCount;
  final List<Color> accentColors;
  final Color trackColor;

  const RoadProgressIndicator({
    super.key,
    required this.page,
    required this.pageCount,
    required this.accentColors,
    this.trackColor = AppColors.border,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = _lerpAccent(page);
    return SizedBox(
      height: 28,
      width: double.infinity,
      child: CustomPaint(
        painter: _RoadPainter(
          page: page,
          pageCount: pageCount,
          activeColor: activeColor,
          trackColor: trackColor,
        ),
      ),
    );
  }

  Color _lerpAccent(double page) {
    final clamped = page.clamp(0, pageCount - 1).toDouble();
    final index = clamped.floor();
    final t = clamped - index;
    final nextIndex = (index + 1).clamp(0, pageCount - 1);
    return Color.lerp(accentColors[index], accentColors[nextIndex], t) ??
        accentColors[index];
  }
}

class _RoadPainter extends CustomPainter {
  final double page;
  final int pageCount;
  final Color activeColor;
  final Color trackColor;

  _RoadPainter({
    required this.page,
    required this.pageCount,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackY = size.height / 2;
    final dashPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const dashWidth = 10.0;
    const dashGap = 8.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, trackY),
        Offset(x + dashWidth, trackY),
        dashPaint,
      );
      x += dashWidth + dashGap;
    }

    final progress = pageCount <= 1
        ? 1.0
        : (page / (pageCount - 1)).clamp(0.0, 1.0);
    final markerX = 14 + progress * (size.width - 28);

    final glowPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(markerX, trackY), 11, glowPaint);

    final markerPaint = Paint()..color = activeColor;
    canvas.drawCircle(Offset(markerX, trackY), 5, markerPaint);
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) {
    return oldDelegate.page != page ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
