import '../../domain/entities/deposit_result_entity.dart';

class DepositResultModel extends DepositResultEntity {
  DepositResultModel({
    required super.qrCodeUrl,
    required super.transactionCode,
  });

  factory DepositResultModel.fromJson(Map<String, dynamic> json) {
    return DepositResultModel(
      qrCodeUrl: json['qrCodeUrl'],
      transactionCode: json['transactionCode'],
    );
  }
}