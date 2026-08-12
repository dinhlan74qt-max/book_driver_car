import 'package:book_drive_car/core/theme/app_colors.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bước 3: Thông tin Giấy phép lái xe (GPLX)',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Bắt buộc để đủ điều kiện thuê xe tự lái trên hệ thống.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: licenseNumberController,
          label: 'Số Giấy phép lái xe (12 số)',
          hint: '790123456789',
          icon: Icons.drive_eta_rounded,
          keyboardType: TextInputType.number,
          maxLength: 12,
        ),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hạng giấy phép lái xe',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedLicenseClass,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                  items: licenseClasses.map((cls) {
                    return DropdownMenuItem(
                      value: cls,
                      child: Text(cls),
                    );
                  }).toList(),
                  onChanged: onClassChanged,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Ngày cấp',
                value: licenseIssueDateController.text,
                onTap: onSelectIssueDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: 'Ngày hết hạn',
                value: licenseExpiryDateController.text,
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
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    licenseWarning!,
                    style: const TextStyle(color: AppColors.danger, fontSize: 11.5, fontWeight: FontWeight.w600),
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
          documentIcon: Icons.credit_card_rounded,
          emptySubtitle: 'Chụp rõ mặt trước bằng lái xe ô tô',
          onPick: onPickFront,
        ),
        const SizedBox(height: 16),
        VerificationImagePickerBox(
          label: 'Ảnh mặt sau GPLX *',
          imagePath: licenseBackImage,
          documentIcon: Icons.drive_eta_rounded,
          emptySubtitle: 'Chụp rõ mặt sau và phần ghi chú hạng xe',
          onPick: onPickBack,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TapScale(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isNotEmpty ? value : 'DD/MM/YYYY',
                    style: TextStyle(
                      color: value.isNotEmpty ? Colors.white : Colors.white38,
                      fontSize: 13,
                      fontWeight: value.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.calendar_today_rounded, color: Colors.white38, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
