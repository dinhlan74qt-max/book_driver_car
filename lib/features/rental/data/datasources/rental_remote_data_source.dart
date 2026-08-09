import 'dart:async';

import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/rental/data/models/rental_list_item_model.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

abstract class RentalRemoteDataSource {
  Future<List<RentalListItemModel>> getRenterBookings();
}

@LazySingleton(as: RentalRemoteDataSource)
class RentalRemoteDataSourceImpl implements RentalRemoteDataSource {
  final Dio dio;
  final UserLocalStorage userLocalStorage;

  RentalRemoteDataSourceImpl(this.dio, this.userLocalStorage);

  @override
  Future<List<RentalListItemModel>> getRenterBookings() async {
    final authHeader = await userLocalStorage.getAuthHeader();

    try {
      debugPrint(
        '[RentalRemoteDataSource] GET ${ApiConstants.renterBookings} auth=${authHeader != null ? "yes" : "no"}',
      );

      final response = await dio.get(
        ApiConstants.renterBookings,
        options: Options(
          headers: authHeader != null ? {'Authorization': authHeader} : null,
          validateStatus: (_) => true,
          receiveTimeout: const Duration(seconds: 15),
          connectTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request tới đơn thuê bị timeout');
        },
      );

      debugPrint(
        '[RentalRemoteDataSource] status=${response.statusCode} body=${response.data}',
      );

      final responseData = response.data;
      if (response.statusCode == 200) {
        final rawList = responseData is Map
            ? (responseData as Map)['data']
            : responseData;

        final list = rawList is List ? rawList : const [];
        debugPrint('[RentalRemoteDataSource] parsed_count=${list.length}');

        return list
            .whereType<Map>()
            .map(
              (item) => RentalListItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      final message = _extractMessage(responseData);
      debugPrint(
        '[RentalRemoteDataSource] HTTP ${response.statusCode} error=$message',
      );
      throw Exception(message ?? 'Lấy danh sách đơn thuê thất bại');
    } on DioException catch (e, st) {
      debugPrint(
        '[RentalRemoteDataSource] DioException type=${e.type} status=${e.response?.statusCode} data=${e.response?.data} message=${e.message}',
      );
      debugPrintStack(stackTrace: st);
      throw Exception(
        _extractMessage(e.response?.data) ?? 'Không thể tải danh sách đơn thuê',
      );
    } catch (e, st) {
      debugPrint('[RentalRemoteDataSource] Unexpected error: $e');
      debugPrintStack(stackTrace: st);
      throw Exception(_extractMessage(e) ?? 'Không thể tải danh sách đơn thuê');
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Exception) {
      return data.toString().replaceFirst('Exception: ', '');
    }
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    } else if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    return null;
  }
}
