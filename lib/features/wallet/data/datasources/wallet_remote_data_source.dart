import 'dart:async';

import 'package:book_drive_car/features/wallet/domain/entities/withdraw_request_entity.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/storage/user_local_storage.dart';
import '../models/deposit_result_model.dart';
import '../models/wallet_history_model.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getMyWallet();
  Future<DepositResultModel> deposit(int amount);
  Future<List<WalletHistoryModel>> getMyWalletHistory();
  Future<String> withdraw(WithdrawRequestEntity request); 
}

@LazySingleton(as: WalletRemoteDataSource)
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final Dio dio;
  final UserLocalStorage userLocalStorage;

  WalletRemoteDataSourceImpl(this.dio, this.userLocalStorage);

  Future<Options> _authOptions() async {
    final authHeader = await userLocalStorage.getAuthHeader();
    return Options(
      headers: {if (authHeader != null) 'Authorization': authHeader},
      validateStatus: (_) => true,
    );
  }

  String _extractErrorMessage(dynamic data, {required String fallback}) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    } else if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    return fallback;
  }

  @override
  Future<WalletModel> getMyWallet() async {
    try {
      final response = await dio.get(
        ApiConstants.myWallet,
        options: await _authOptions(),
      );

      final data = response.data;
      if (response.statusCode == 200) {
        return WalletModel.fromJson(data["data"]);
      }

      final message = _extractErrorMessage(
        data,
        fallback: 'Lay thong tin vi that bai',
      );
      debugPrint(
        '[WalletRemoteDataSource][getMyWallet] HTTP ${response.statusCode}: $message',
      );
      debugPrint('[WalletRemoteDataSource][getMyWallet] response.data = $data');
      throw Exception(message);
    } on DioException catch (e) {
      debugPrint(
        '[WalletRemoteDataSource][getMyWallet] DioException: ${e.message}',
      );
      debugPrint(
        '[WalletRemoteDataSource][getMyWallet] statusCode = ${e.response?.statusCode}',
      );
      debugPrint(
        '[WalletRemoteDataSource][getMyWallet] response.data = ${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[WalletRemoteDataSource][getMyWallet] Error: $e');
      rethrow;
    }
  }

  @override
  Future<DepositResultModel> deposit(int amount) async {
    try {
      final authHeader = await userLocalStorage.getAuthHeader();
      if (authHeader == null || authHeader.trim().isEmpty) {
        throw Exception(
          'Chua co thong tin dang nhap hop le. Vui long dang nhap lai.',
        );
      }

      final response = await dio.post(
        ApiConstants.deposits,
        data: {"amount": amount},
        options: await _authOptions(),
      );

      final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return DepositResultModel.fromJson(data["data"]);
      }

      final message = _extractErrorMessage(
        data,
        fallback: 'Nap tien that bai (${response.statusCode})',
      );
      debugPrint(
        '[WalletRemoteDataSource][deposit] HTTP ${response.statusCode}: $message',
      );
      debugPrint(
        '[WalletRemoteDataSource][deposit] authorization = ${authHeader.split(' ').first}',
      );
      debugPrint('[WalletRemoteDataSource][deposit] request.amount = $amount');
      debugPrint('[WalletRemoteDataSource][deposit] response.data = $data');
      throw Exception(message);
    } on DioException catch (e) {
      debugPrint(
        '[WalletRemoteDataSource][deposit] DioException: ${e.message}',
      );
      debugPrint(
        '[WalletRemoteDataSource][deposit] statusCode = ${e.response?.statusCode}',
      );
      debugPrint(
        '[WalletRemoteDataSource][deposit] response.data = ${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[WalletRemoteDataSource][deposit] Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<WalletHistoryModel>> getMyWalletHistory() async {
    try {
      final response = await dio.get(
        '${ApiConstants.myWallet}/history',
        options: await _authOptions(),
      );

      final data = response.data;
      if (response.statusCode == 200) {
        final rawList = data is Map<String, dynamic> ? data['data'] : null;
        if (rawList is List) {
          return rawList
              .whereType<Map>()
              .map(
                (item) => WalletHistoryModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        }
        return [];
      }

      final message = _extractErrorMessage(
        data,
        fallback: 'KhÃ´ng thá»ƒ táº£i lá»‹ch sá»­ giao dá»‹ch',
      );
      debugPrint(
        '[WalletRemoteDataSource][getMyWalletHistory] HTTP ${response.statusCode}: $message',
      );
      debugPrint(
        '[WalletRemoteDataSource][getMyWalletHistory] response.data = $data',
      );
      throw Exception(message);
    } on DioException catch (e) {
      debugPrint(
        '[WalletRemoteDataSource][getMyWalletHistory] DioException: ${e.message}',
      );
      debugPrint(
        '[WalletRemoteDataSource][getMyWalletHistory] statusCode = ${e.response?.statusCode}',
      );
      debugPrint(
        '[WalletRemoteDataSource][getMyWalletHistory] response.data = ${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[WalletRemoteDataSource][getMyWalletHistory] Error: $e');
      rethrow;
    }
  }

  @override
  Future<String> withdraw(WithdrawRequestEntity request) async {
    try {
      final response = await dio
          .post(
            ApiConstants.withdraw,
            data: {
              "amount": request.amount,
              "bankName": request.bankName,
              "bankAccount": request.bankAccount,
              "accountHolder": request.accountHolder,
            },
            options: await _authOptions(),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Yeu cau rut tien bi timeout');
            },
          );

      final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map<String, dynamic>) {
          final message = data["message"];
          if (message is String && message.trim().isNotEmpty) {
            return message;
          }
        }
        return 'T?o l?nh rút ti?n thành công';
      }

      final message = _extractErrorMessage(
        data,
        fallback: 'Rút ti?n th?t b?i (${response.statusCode})',
      );
      debugPrint(
        '[WalletRemoteDataSource][withdraw] HTTP ${response.statusCode}: $message',
      );
      debugPrint('[WalletRemoteDataSource][withdraw] response.data = $data');
      throw Exception(message);
    } on TimeoutException catch (e) {
      debugPrint('[WalletRemoteDataSource][withdraw] TimeoutException: $e');
      throw Exception('Yeu cau rut tien qua lau. Vui long thu lai.');
    } on DioException catch (e) {
      debugPrint('[WalletRemoteDataSource][withdraw] DioException: ${e.message}');
      debugPrint('[WalletRemoteDataSource][withdraw] statusCode = ${e.response?.statusCode}');
      debugPrint('[WalletRemoteDataSource][withdraw] response.data = ${e.response?.data}');
      throw Exception(
        _extractErrorMessage(
          e.response?.data,
          fallback: 'Khong the tao lenh rut tien',
        ),
      );
    } catch (e) {
      debugPrint('[WalletRemoteDataSource][withdraw] Error: $e');
      rethrow;
    }
  }
}

