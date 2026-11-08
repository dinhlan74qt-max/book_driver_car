import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/widgets/verification_image_picker_box.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';

class Step3DriverLicenseSection extends StatelessWidget {
  final TextEditingController licenseNumberController;
  final TextEditingController licenseIssueDateController;
  final TextEditingController licenseExpiryDateController;
  final String selectedLicenseClass;
  final List<String> licenseClasses;
  final String? licenseWarning;
  final String? licenseFrontImage;
  final String? licenseBackImage;
  final ValueChanged<String?> onClassChanged;
  final VoidCallback onSelectIssueDate;
  final VoidCallback onSelectExpiryDate;
  final VoidCallback onPickFront;
  final VoidCallback onPickBack;
  final bool isReadOnly;

  const Step3DriverLicenseSection({
    super.key,
    required this.licenseNumberController,
    required this.licenseIssueDateController,
    required this.licenseExpiryDateController,
    required this.selectedLicenseClass,
    required this.licenseClasses,
    required this.licenseWarning,
    required this.licenseFrontImage,
    required this.licenseBackImage,
    required this.onClassChanged,
    required this.onSelectIssueDate,
    required this.onSelectExpiryDate,
    required this.onPickFront,
    required this.onPickBack,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final inputBg = isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Card ───────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E3A5D), Color(0xFFE86000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.drive_eta_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bước 3: Giấy phép lái xe (GPLX)',
                      style: AppTypography.titleMedium.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Điều kiện bắt buộc để thuê xe tự lái và nhận bảo hiểm.',
                      style: AppTypography.caption.copyWith(
                        color: textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        _buildTextField(
          context: context,
          controller: licenseNumberController,
          label: 'Số Giấy phép lái xe (12 số) *',
          hint: '790123456789',
          icon: Icons.credit_card_rounded,
          keyboardType: TextInputType.number,
          maxLength: 12,
        ),

        const SizedBox(height: 16),

        // License Class Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hạng giấy phép lái xe *',
              style: TextStyle(
                color: textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedLicenseClass,
                  dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textSecondary,
                  ),
                  items: licenseClasses.map((cls) {
                    return DropdownMenuItem(
                      value: cls,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.directions_car_filled_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(cls),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: isReadOnly ? null : onClassChanged,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Issue Date and Expiry Date Row
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                context: context,
                controller: licenseIssueDateController,
                label: 'Ngày cấp *',
                hint: 'DD/MM/YYYY',
                onTap: onSelectIssueDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                context: context,
                controller: licenseExpiryDateController,
                label: 'Ngày hết hạn *',
                hint: 'DD/MM/YYYY',
                onTap: onSelectExpiryDate,
              ),
            ),
          ],
        ),

        if (licenseWarning != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    licenseWarning!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        VerificationImagePickerBox(
          label: 'Ảnh mặt trước GPLX *',
          imagePath: licenseFrontImage,
          documentIcon: Icons.badge_outlined,
          emptySubtitle: 'Chụp rõ nét mặt trước bằng lái xe',
          isReadOnly: isReadOnly,
          onPick: onPickFront,
        ),

        const SizedBox(height: 20),

        VerificationImagePickerBox(
          label: 'Ảnh mặt sau GPLX *',
          imagePath: licenseBackImage,
          documentIcon: Icons.drive_eta_rounded,
          emptySubtitle: 'Chụp rõ mặt sau, thời hạn và dấu mộc',
          isReadOnly: isReadOnly,
          onPick: onPickBack,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final inputBg = isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        TapScale(
          onTap: isReadOnly ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isNotEmpty ? controller.text : hint,
                    style: TextStyle(
                      color: controller.text.isNotEmpty
                          ? textPrimary
                          : textSecondary.withValues(alpha: 0.6),
                      fontSize: 13.5,
                      fontWeight: controller.text.isNotEmpty
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: textSecondary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final inputBg = isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: TextStyle(
            color: textPrimary,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: textSecondary.withValues(alpha: 0.6),
              fontSize: 13.5,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: inputBg,
            counterText: '',
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 1.1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 1.1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
