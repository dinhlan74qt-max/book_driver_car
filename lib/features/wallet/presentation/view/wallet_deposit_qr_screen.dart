import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class WalletDepositQrScreen extends StatelessWidget {
  final int amount;
  final String qrCodeUrl;
  final String transactionCode;

  const WalletDepositQrScreen({
    super.key,
    required this.amount,
    required this.qrCodeUrl,
    required this.transactionCode,
  });

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.decimalPattern('vi_VN');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        centerTitle: true,
        title: const Text('Nạp tiền qua QR'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quét mã QR để nạp tiền',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mã QR, tiêu đề và nội dung giao dịch được server trả về. Hãy chuyển đúng số tiền để hệ thống ghi nhận chính xác.',
                style: TextStyle(
                  color: const Color(0xFF6B7280).withOpacity(0.95),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              qrCodeUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  height: 240,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes == null
                                          ? null
                                          : loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 240,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: const Text(
                                    'Không tải được mã QR',
                                    style: TextStyle(color: Color(0xFF6B7280)),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Số tiền cần nạp: ${priceFormat.format(amount)}đ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Mở app ngân hàng và quét mã bên trên để chuyển khoản.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: 'Tiêu đề',
                      value: 'Nạp tiền vào ví',
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: 'Subtitle',
                      value: 'Quét mã và chuyển đúng số tiền hiển thị',
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: 'Mã giao dịch',
                      value: transactionCode,
                      trailing: TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: transactionCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã sao chép mã giao dịch')),
                          );
                        },
                        child: const Text('Sao chép'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lưu ý',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sau khi thanh toán thành công, kéo xuống ví để tải lại số dư. Nếu ngân hàng chưa cập nhật ngay, hãy thử refresh thêm một lần nữa.',
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
