import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Step5EmergencyContactSection extends StatelessWidget {
  final TextEditingController emergencyNameController;
  final TextEditingController emergencyPhoneController;
  final String emergencyRelation;
  final List<String> relations;
  final ValueChanged<String?> onRelationChanged;

  const Step5EmergencyContactSection({
    super.key,
    required this.emergencyNameController,
    required this.emergencyPhoneController,
    required this.emergencyRelation,
    required this.relations,
    required this.onRelationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bước 5: Người liên hệ khẩn cấp',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Dùng để liên hệ trong các trường hợp cần hỗ trợ khẩn cấp.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: emergencyNameController,
          label: 'Họ tên người liên hệ khẩn cấp',
          hint: 'Nguyễn Văn B',
          icon: Icons.person_search_rounded,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: emergencyPhoneController,
          label: 'Số điện thoại khẩn cấp',
          hint: '0912345678',
          icon: Icons.phone_in_talk_rounded,
          keyboardType: TextInputType.phone,
          maxLength: 10,
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mối quan hệ',
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
                  value: emergencyRelation,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                  items: relations.map((rel) {
                    return DropdownMenuItem(
                      value: rel,
                      child: Text(rel),
                    );
                  }).toList(),
                  onChanged: onRelationChanged,
                ),
              ),
            ),
          ],
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
