enum TxType { topup, payment, refund }

class WalletTransaction {
  final String id;
  final String title;
  final int amount; // dương: cộng, âm: trừ
  final TxType type;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.createdAt,
  });
}