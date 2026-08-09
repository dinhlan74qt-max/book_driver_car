import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  WalletModel({required super.id, required super.balance});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse('$value') ?? 0;
    }

    return WalletModel(
      id: parseInt(json['id']),
      balance: parseInt(json['balance']),
    );
  }
}
