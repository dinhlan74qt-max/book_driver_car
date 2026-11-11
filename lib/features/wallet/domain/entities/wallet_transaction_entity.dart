class WalletTransactionEntity {
  final int id;
  final int amount;
  final String description;
  final String transactionType;
  final DateTime? createdAt;
  final int? walletId;
  final int? walletBalance;

  const WalletTransactionEntity({
    required this.id,
    required this.amount,
    required this.description,
    required this.transactionType,
    required this.createdAt,
    this.walletId,
    this.walletBalance,
  });

  /// Kiểm tra giao dịch là Tiền vào (Credit: +) hay Tiền ra (Debit: -)
  bool get isCredit {
    final type = transactionType.toUpperCase().trim();
    // Tiền cộng vào ví (+): Nạp tiền, Nhận tiền thuê xe, Hoàn tiền
    if (type == 'DEPOSIT' ||
        type == 'TOPUP' ||
        type == 'RENT_RECEIVE' ||
        type == 'REFUND' ||
        type.contains('RECEIVE') ||
        type.contains('REFUND')) {
      return true;
    }
    // Tiền trừ khỏi ví (-): Rút tiền, Thanh toán tiền thuê
    if (type == 'WITHDRAW' ||
        type == 'RENT_PAYMENT' ||
        type == 'PAYMENT') {
      return false;
    }
    // Fallback thông minh theo nội dung ghi chú nếu loại giao dịch không xác định
    final desc = description.toLowerCase();
    if (desc.contains('nhận') ||
        desc.contains('nạp') ||
        desc.contains('hoàn') ||
        desc.contains('cộng')) {
      return true;
    }
    if (desc.contains('rút') ||
        desc.contains('thanh toán') ||
        desc.contains('trừ') ||
        desc.contains('phí')) {
      return false;
    }
    return amount > 0;
  }

  /// Tên tiếng Việt chuẩn cho từng loại trạng thái giao dịch
  String get typeDisplayName {
    final type = transactionType.toUpperCase().trim();
    switch (type) {
      case 'DEPOSIT':
      case 'TOPUP':
        return 'Nạp tiền';
      case 'WITHDRAW':
        return 'Rút tiền';
      case 'RENT_PAYMENT':
      case 'PAYMENT':
        return 'Thanh toán tiền thuê';
      case 'RENT_RECEIVE':
        return 'Nhận tiền thuê';
      case 'REFUND':
        return 'Hoàn tiền';
      default:
        if (type.contains('RECEIVE')) return 'Nhận tiền thuê';
        if (type.contains('PAYMENT')) return 'Thanh toán tiền thuê';
        if (type.contains('WITHDRAW')) return 'Rút tiền';
        if (type.contains('DEPOSIT') || type.contains('TOPUP')) return 'Nạp tiền';
        if (type.contains('REFUND')) return 'Hoàn tiền';
        return type.isNotEmpty ? type : 'Giao dịch';
    }
  }

  /// Tiêu đề hiển thị ưu tiên nội dung mô tả, fallback về tên loại giao dịch
  String get displayTitle {
    if (description.isNotEmpty &&
        description.toUpperCase() != transactionType.toUpperCase()) {
      return description;
    }
    return typeDisplayName;
  }
}
