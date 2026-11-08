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
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            icon,
            key: ValueKey<IconData>(icon),
            color: iconColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.getPrimary(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);

    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
