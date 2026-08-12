import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';

class VerificationStepIndicator extends StatelessWidget {
  final int currentStep;
  final bool Function(int) isStepValid;
  final Function(int) onStepTapped;

  const VerificationStepIndicator({
    super.key,
    required this.currentStep,
    required this.isStepValid,
    required this.onStepTapped,
  });

  static const List<String> stepTitles = [
    'Cá nhân',
    'Ảnh CCCD',
    'GPLX',
    'Selfie',
    'Khẩn cấp',
    'Cam kết',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(stepTitles.length, (index) {
            final isActive = index == currentStep;
            final isDone = index < currentStep;

            return Row(
              children: [
                TapScale(
                  onTap: () {
                    if (index <= currentStep || isStepValid(currentStep)) {
                      onStepTapped(index);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : (isDone ? AppColors.primary.withValues(alpha: 0.2) : Colors.white10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? AppColors.primary : Colors.white24,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (isDone)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(Icons.check_rounded, color: AppColors.primary, size: 14),
                          ),
                        Text(
                          'B${index + 1}: ${stepTitles[index]}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                            color: isActive ? Colors.white : (isDone ? AppColors.primary : Colors.white60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < stepTitles.length - 1)
                  Container(
                    width: 16,
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: Colors.white24,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
