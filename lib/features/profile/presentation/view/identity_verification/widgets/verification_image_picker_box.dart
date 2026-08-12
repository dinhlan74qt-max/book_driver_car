import 'dart:io';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VerificationImagePickerBox extends StatelessWidget {
  final String label;
  final String? imagePath;
  final IconData documentIcon;
  final String? emptySubtitle;
  final VoidCallback onPick;

  const VerificationImagePickerBox({
    super.key,
    required this.label,
    required this.imagePath,
    this.documentIcon = Icons.badge_outlined,
    this.emptySubtitle,
    required this.onPick,
  });

  static Future<void> showImagePickerSheet({
    required BuildContext context,
    required Function(String path) onSelected,
  }) async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chọn nguồn hình ảnh', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Chụp từ Camera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Chọn từ Thư viện ảnh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_rounded, color: AppColors.headlightAmber),
              title: const Text('Dùng ảnh mẫu sẵn (Demo)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              onTap: () => Navigator.of(ctx).pop('DEMO'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    if (result == 'DEMO') {
      onSelected('https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600');
      return;
    }

    if (result is ImageSource) {
      try {
        final picker = ImagePicker();
        final XFile? file = await picker.pickImage(source: result, imageQuality: 80);
        if (file != null) {
          onSelected(file.path);
        }
      } catch (e) {
        debugPrint('Error picking image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    Widget displayWidget;
    if (!hasImage) {
      displayWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    documentIcon,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chụp / Tải ảnh lên',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    emptySubtitle ?? 'Chạm để chụp từ camera hoặc chọn từ thư viện',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.add_photo_alternate_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ],
        ),
      );
    } else {
      displayWidget = Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath!.startsWith('http'))
            Image.network(imagePath!, fit: BoxFit.cover)
          else
            Image.file(File(imagePath!), fit: BoxFit.cover),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.edit_rounded, color: AppColors.primary, size: 12),
                  SizedBox(width: 4),
                  Text('Đổi ảnh', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            if (hasImage)
              const Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'Đã tải ảnh',
                    style: TextStyle(color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        TapScale(
          onTap: onPick,
          child: Container(
            height: hasImage ? 140 : 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: hasImage ? Colors.white10 : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: hasImage
                  ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 1.5,
                    )
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: displayWidget,
            ),
          ),
        ),
      ],
    );
  }
}
