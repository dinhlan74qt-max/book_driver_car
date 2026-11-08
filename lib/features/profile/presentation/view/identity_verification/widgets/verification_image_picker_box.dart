import 'dart:io';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VerificationImagePickerBox extends StatelessWidget {
  final String label;
  final String? imagePath;
  final IconData documentIcon;
  final String? emptySubtitle;
  final VoidCallback onPick;
  final bool isReadOnly;

  const VerificationImagePickerBox({
    super.key,
    required this.label,
    required this.imagePath,
    this.documentIcon = Icons.badge_outlined,
    this.emptySubtitle,
    required this.onPick,
    this.isReadOnly = false,
  });

  static Future<void> showImagePickerSheet({
    required BuildContext context,
    required Function(String path) onSelected,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final tileHover = isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary;

    final result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white30 : Colors.black12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Chọn nguồn hình ảnh',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Vui lòng chọn ảnh chụp rõ nét, đủ 4 góc giấy tờ',
                style: AppTypography.caption.copyWith(color: textSecondary),
              ),
              const SizedBox(height: 16),
              _buildPickerTile(
                icon: Icons.camera_alt_rounded,
                title: 'Chụp từ Camera',
                subtitle: 'Mở máy ảnh chụp trực tiếp',
                color: AppColors.primary,
                bgColor: tileHover,
                textColor: textPrimary,
                subColor: textSecondary,
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              const SizedBox(height: 8),
              _buildPickerTile(
                icon: Icons.photo_library_rounded,
                title: 'Chọn từ Thư viện ảnh',
                subtitle: 'Chọn ảnh có sẵn trên thiết bị',
                color: AppColors.accent,
                bgColor: tileHover,
                textColor: textPrimary,
                subColor: textSecondary,
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
              const SizedBox(height: 8),
              _buildPickerTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Dùng ảnh mẫu sẵn (Demo)',
                subtitle: 'Tải nhanh ảnh mẫu để thử nghiệm',
                color: const Color(0xFF10B981),
                bgColor: tileHover,
                textColor: textPrimary,
                subColor: textSecondary,
                onTap: () => Navigator.of(ctx).pop('DEMO'),
              ),
            ],
          ),
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

  static Widget _buildPickerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required Color textColor,
    required Color subColor,
    required VoidCallback onTap,
  }) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: subColor, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final boxBg = isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary;

    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    Widget displayWidget;
    if (!hasImage) {
      displayWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: boxBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.accent.withValues(alpha: 0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    documentIcon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  Positioned(
                    right: 3,
                    bottom: 3,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 9,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chụp hoặc Tải ảnh lên',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    emptySubtitle ?? 'Chạm để chụp từ camera hoặc chọn thư viện',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11.5,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: const Icon(
                Icons.add_a_photo_rounded,
                color: AppColors.primary,
                size: 17,
              ),
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
          if (!isReadOnly)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_rounded, color: Colors.white, size: 12),
                    SizedBox(width: 5),
                    Text(
                      'Đổi ảnh',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 13),
                  SizedBox(width: 4),
                  Text(
                    'Đã tải lên',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            if (hasImage)
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 15, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  Text(
                    'Hợp lệ',
                    style: TextStyle(
                      color: const Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        TapScale(
          onTap: isReadOnly ? null : onPick,
          child: Container(
            height: hasImage ? 150 : null,
            constraints: hasImage ? null : const BoxConstraints(minHeight: 76),
            width: double.infinity,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: hasImage
                  ? Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.6),
                      width: 1.5,
                    )
                  : null,
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: displayWidget,
            ),
          ),
        ),
      ],
    );
  }
}
