import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Step6AgreementSection extends StatelessWidget {
  final String fullName;
  final String dob;
  final String cccdNumber;
  final String address;
  final String licenseNumber;
  final String licenseClass;
  final String emergencyName;
  final String emergencyPhone;
  final String emergencyRelation;
  final bool hasAgreedTerms;
  final ValueChanged<bool?> onAgreementChanged;

  const Step6AgreementSection({
    super.key,
    required this.fullName,
    required this.dob,
    required this.cccdNumber,
    required this.address,
    required this.licenseNumber,
    required this.licenseClass,
    required this.emergencyName,
    required this.emergencyPhone,
    required this.emergencyRelation,
    required this.hasAgreedTerms,
    required this.onAgreementChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bước 6: Kiểm tra & Xác nhận hồ sơ',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Vui lòng rà soát kỹ các thông tin đã khai báo trước khi gửi duyệt.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.badge_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text('Thông tin cá nhân & CCCD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              _buildSummaryRow('Họ tên:', fullName),
              _buildSummaryRow('Ngày sinh:', dob),
              _buildSummaryRow('Số CCCD:', cccdNumber),
              _buildSummaryRow('Địa chỉ:', address),
              const Divider(color: Colors.white12, height: 20),
              const Row(
                children: [
                  Icon(Icons.drive_eta_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text('Giấy phép lái xe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              _buildSummaryRow('Số GPLX:', licenseNumber),
              _buildSummaryRow('Hạng bằng:', licenseClass),
              const Divider(color: Colors.white12, height: 20),
              const Row(
                children: [
                  Icon(Icons.contact_phone_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text('Liên hệ khẩn cấp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              _buildSummaryRow('Người liên hệ:', '$emergencyName ($emergencyRelation)'),
              _buildSummaryRow('Số điện thoại:', emergencyPhone),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.security_rounded, color: Colors.amber, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hồ sơ của bạn sẽ được đội ngũ hỗ trợ kiểm tra và phản hồi kết quả trong vòng 1-2 giờ làm việc.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: hasAgreedTerms,
          onChanged: onAgreementChanged,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'Tôi cam đoan mọi thông tin và hình ảnh giấy tờ cung cấp là chính xác, hợp pháp và chịu hoàn toàn trách nhiệm trước pháp luật.',
            style: TextStyle(color: Colors.white, fontSize: 12.5, height: 1.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12.5)),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}
