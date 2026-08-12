import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';

class Step1BasicInfoSection extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController dobController;
  final TextEditingController cccdController;
  final TextEditingController addressController;
  final String? ageWarning;
  final VoidCallback onSelectDob;

  const Step1BasicInfoSection({
    super.key,
    required this.fullNameController,
    required this.dobController,
    required this.cccdController,
    required this.addressController,
    required this.ageWarning,
    required this.onSelectDob,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bước 1: Thông tin cá nhân cơ bản',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Vui lòng nhập chính xác họ tên và số CCCD khớp với giấy tờ.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: fullNameController,
          label: 'Họ và tên đầy đủ',
          hint: 'NGUYỄN VĂN A',
          icon: Icons.person_rounded,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ngày tháng năm sinh',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TapScale(
              onTap: onSelectDob,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cake_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dobController.text.isNotEmpty ? dobController.text : 'Chọn ngày sinh (DD/MM/YYYY)',
                        style: TextStyle(
                          color: dobController.text.isNotEmpty ? Colors.white : Colors.white38,
                          fontSize: 14,
                          fontWeight: dobController.text.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_month_rounded, color: Colors.white38, size: 20),
                  ],
                ),
              ),
            ),
            if (ageWarning != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.danger),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ageWarning!,
                      style: const TextStyle(color: AppColors.danger, fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: cccdController,
          label: 'Số CCCD / CMND (12 số)',
          hint: '001201012345',
          icon: Icons.badge_rounded,
          keyboardType: TextInputType.number,
          maxLength: 12,
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: addressController,
          label: 'Địa chỉ thường trú theo CCCD',
          hint: 'Số nhà, Phường/Xã, Quận/Huyện, Tỉnh/TP',
          icon: Icons.location_on_rounded,
          maxLines: 2,
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
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
          textCapitalization: textCapitalization,
          maxLines: maxLines,
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
