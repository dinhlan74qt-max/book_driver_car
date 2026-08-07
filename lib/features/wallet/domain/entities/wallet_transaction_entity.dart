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

  bool get isCredit {
    final type = transactionType.toUpperCase();
    return type == 'DEPOSIT' || type == 'TOPUP' || type == 'REFUND';
  }
}
