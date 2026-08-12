import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LuxuryCarDetailBackground extends StatelessWidget {
  const LuxuryCarDetailBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1017), Color(0xFF151A24), Color(0xFFF7F8FA)],
          stops: [0.0, 0.42, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: LuxuryGlow(
              size: 240,
              colors: [
                AppColors.headlightAmber.withValues(alpha: 0.20),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            top: 160,
            left: -80,
            child: LuxuryGlow(
              size: 180,
              colors: [
                AppColors.pageAccents[2].withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LuxuryGlow extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const LuxuryGlow({super.key, required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.laneWhite,
      ),
    );
  }
}
