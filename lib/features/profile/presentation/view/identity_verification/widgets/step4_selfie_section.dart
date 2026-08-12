import 'dart:io';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';

class Step4SelfieSection extends StatelessWidget {
  final String? selfieImage;
  final VoidCallback onPickSelfie;

  const Step4SelfieSection({
    super.key,
    required this.selfieImage,
    required this.onPickSelfie,
  });

  @override
  Widget build(BuildContext context) {
    Widget selfieDisplay;
    final hasSelfie = selfieImage != null && selfieImage!.isNotEmpty;

    if (!hasSelfie) {
      selfieDisplay = Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 80,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
          Positioned(
            right: 28,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else if (selfieImage!.startsWith('http')) {
      selfieDisplay = Image.network(selfieImage!, fit: BoxFit.cover);
    } else {
      selfieDisplay = Image.file(File(selfieImage!), fit: BoxFit.cover);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bước 4: Ảnh chân dung chính diện',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Chụp ảnh khuôn mặt để đối chiếu xác minh với CCCD.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.lightBlueAccent, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Yêu cầu chụp khuôn mặt:\n'
                  '• Nhìn thẳng vào ống kính camera.\n'
                  '• Không đeo kính râm, khẩu trang hoặc mũ che mặt.\n'
                  '• Đảm bảo đủ ánh sáng rõ nét.',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              TapScale(
                onTap: onPickSelfie,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: hasSelfie ? 0.08 : 0.04),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasSelfie ? AppColors.primary : Colors.white24,
                      width: hasSelfie ? 2 : 1.2,
                    ),
                  ),
                  child: ClipOval(
                    child: selfieDisplay,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onPickSelfie,
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(hasSelfie ? 'Chụp lại ảnh chân dung' : 'Chụp / Chọn ảnh chân dung'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
