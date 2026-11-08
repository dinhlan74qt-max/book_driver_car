import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
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
  final bool isReadOnly;

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
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final rowBg = isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary;

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
                    colors: [Color(0xFF10B981), Color(0xFF0E3A5D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.verified_rounded,
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
                      'Bước 6: Rà soát & Xác nhận hồ sơ',
                      style: AppTypography.titleMedium.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Vui lòng kiểm tra kỹ thông tin đã khai báo trước khi gửi duyệt.',
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

        // ── Summary Sheet Card ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1
              _buildSectionTitle(
                icon: Icons.person_outline_rounded,
                title: 'Thông tin cá nhân & CCCD',
                color: AppColors.primary,
                textColor: textPrimary,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Họ và tên:', fullName, textSecondary, textPrimary, rowBg),
              _buildSummaryRow('Ngày sinh:', dob, textSecondary, textPrimary, Colors.transparent),
              _buildSummaryRow('Số CCCD:', cccdNumber, textSecondary, textPrimary, rowBg),
              _buildSummaryRow('Địa chỉ thường trú:', address, textSecondary, textPrimary, Colors.transparent),

              Divider(color: borderColor, height: 28),

              // Section 2
              _buildSectionTitle(
                icon: Icons.drive_eta_rounded,
                title: 'Giấy phép lái xe (GPLX)',
                color: AppColors.accent,
                textColor: textPrimary,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Số GPLX:', licenseNumber, textSecondary, textPrimary, rowBg),
              _buildSummaryRow('Hạng bằng:', licenseClass, textSecondary, textPrimary, Colors.transparent),

              Divider(color: borderColor, height: 28),

              // Section 3
              _buildSectionTitle(
                icon: Icons.contact_phone_outlined,
                title: 'Người liên hệ khẩn cấp',
                color: const Color(0xFF10B981),
                textColor: textPrimary,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                'Người liên hệ:',
                '$emergencyName ($emergencyRelation)',
                textSecondary,
                textPrimary,
                rowBg,
              ),
              _buildSummaryRow('Số điện thoại:', emergencyPhone, textSecondary, textPrimary, Colors.transparent),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Legal & Responsibility Note ────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                : const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                  : const Color(0xFFFDE68A),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.gavel_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bằng việc gửi hồ sơ, bạn cam kết các thông tin và hình ảnh giấy tờ cung cấp là hoàn toàn chính xác, trùng khớp bản gốc và tự chịu trách nhiệm trước pháp luật.',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Interactive Terms Agreement Checkbox Card ──────────────────────
        TapScale(
          onTap: isReadOnly ? null : () => onAgreementChanged(!hasAgreedTerms),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: hasAgreedTerms
                  ? (isDark
                      ? AppColors.darkPrimary.withValues(alpha: 0.15)
                      : const Color(0xFFDCEAF5))
                  : surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasAgreedTerms ? AppColors.primary : borderColor,
                width: hasAgreedTerms ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: hasAgreedTerms,
                  onChanged: isReadOnly ? null : onAgreementChanged,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Tôi đã đọc, hiểu rõ và đồng ý với ',
                        ),
                        TextSpan(
                          text: 'Điều khoản dịch vụ & Chính sách bảo mật',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text: ' của CarNow.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required Color color,
    required Color textColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
    Color rowBg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
