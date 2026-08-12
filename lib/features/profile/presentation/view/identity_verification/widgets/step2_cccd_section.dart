import 'package:book_drive_car/features/profile/presentation/view/identity_verification/widgets/verification_image_picker_box.dart';
import 'package:flutter/material.dart';

class Step2CccdSection extends StatelessWidget {
  final String? cccdFrontImage;
  final String? cccdBackImage;
  final VoidCallback onPickFront;
  final VoidCallback onPickBack;

  const Step2CccdSection({
    super.key,
    required this.cccdFrontImage,
    required this.cccdBackImage,
    required this.onPickFront,
    required this.onPickBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bước 2: Tải ảnh CCCD / CMND',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Chụp rõ nét 2 mặt giấy tờ căn cước công dân của bạn.',
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
                  'Yêu cầu chụp ảnh:\n'
                  '• Đặt giấy tờ trên mặt phẳng, đủ ánh sáng.\n'
                  '• Chụp thẳng góc, không bị lóa sáng hay mất góc.\n'
                  '• Chữ và số trên thẻ phải rõ ràng, đọc được.',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        VerificationImagePickerBox(
          label: 'Ảnh mặt trước CCCD *',
          imagePath: cccdFrontImage,
          documentIcon: Icons.badge_outlined,
          emptySubtitle: 'Chụp rõ mặt trước thẻ CCCD gắn chip',
          onPick: onPickFront,
        ),
        const SizedBox(height: 16),
        VerificationImagePickerBox(
          label: 'Ảnh mặt sau CCCD *',
          imagePath: cccdBackImage,
          documentIcon: Icons.fingerprint_rounded,
          emptySubtitle: 'Chụp rõ mặt sau, mã QR và dải chip',
          onPick: onPickBack,
        ),
      ],
    );
  }
}
