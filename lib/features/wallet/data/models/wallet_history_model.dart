import '../../domain/entities/wallet_transaction_entity.dart';

class WalletHistoryModel extends WalletTransactionEntity {
  const WalletHistoryModel({
    required super.id,
    required super.amount,
    required super.description,
    required super.transactionType,
    required super.createdAt,
    super.walletId,
    super.walletBalance,
  });

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse('$value') ?? fallback;
  }

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    final wallet = json['wallet'];
    final walletMap = wallet is Map ? Map<String, dynamic>.from(wallet) : null;
    final createdAtRaw = json['createdAt'];

    return WalletHistoryModel(
      id: _parseInt(json['id']),
      amount: _parseInt(json['amount']),
      description: json['description']?.toString() ?? '',
      transactionType: json['transactionType']?.toString() ?? '',
      createdAt: createdAtRaw == null
          ? null
          : DateTime.tryParse(createdAtRaw.toString()),
      walletId: walletMap == null ? null : _parseInt(walletMap['id']),
      walletBalance: walletMap == null ? null : _parseInt(walletMap['balance']),
    );
  }
}
