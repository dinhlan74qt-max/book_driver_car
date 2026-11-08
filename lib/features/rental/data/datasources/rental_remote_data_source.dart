import 'dart:async';
import 'dart:convert';

import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/rental/data/models/rental_list_item_model.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';

abstract class RentalRemoteDataSource {
  Future<List<RentalListItemModel>> getRenterBookings();
  Future<void> cancelBooking(int bookingId, {String? reason});
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
        if (responseData is String) {
          final trimmed = responseData.trim().toLowerCase();
          if (trimmed.startsWith('<!doctype') ||
              trimmed.startsWith('<html') ||
              trimmed.contains('<form')) {
            throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
          }
        }
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

  @override
  Future<void> cancelBooking(int bookingId, {String? reason}) async {
    final authHeader = await userLocalStorage.getAuthHeader();
    final dtoJson = jsonEncode({
      'id': bookingId,
      'bookingId': bookingId,
      'status': 'CANCELLED',
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });

    final endpoints = <String>[
      '${ApiConstants.baseUrl}/api/booking/update-status',
      '${ApiConstants.baseUrl}/api/bookings/update-status',
      'http://192.168.1.52:8080/api/booking/update-status',
    ];

    Object? lastError;
    Response? lastResponse;

    for (final endpoint in endpoints) {
      // 1. Thử gửi dạng FormData với Dto (chuẩn Spring Boot Multipart @RequestPart("Dto"))
      try {
        debugPrint(
          '[RentalRemoteDataSource][cancelBooking] Trying FormData on $endpoint with id=$bookingId',
        );
        final formData = FormData.fromMap({
          'Dto': MultipartFile.fromString(
            dtoJson,
            contentType: MediaType('application', 'json'),
          ),
        });

        final response = await dio.post(
          endpoint,
          data: formData,
          options: Options(
            headers: {if (authHeader != null) 'Authorization': authHeader},
            connectTimeout: const Duration(seconds: 8),
            sendTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
            validateStatus: (_) => true,
          ),
        );

        lastResponse = response;
        debugPrint(
          '[RentalRemoteDataSource][cancelBooking] FormData HTTP ${response.statusCode} body=${response.data}',
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint(
            '[RentalRemoteDataSource][cancelBooking] Success via FormData on $endpoint',
          );
          return;
        }

        if (response.statusCode != 404 &&
            response.statusCode != 405 &&
            response.statusCode != 415) {
          throw Exception(
            _extractMessage(response.data) ??
                'Hủy đơn thuê thất bại (${response.statusCode})',
          );
        }
      } catch (e) {
        lastError = e;
        debugPrint(
          '[RentalRemoteDataSource][cancelBooking] FormData failed on $endpoint: $e',
        );
      }

      // 2. Thử gửi dạng raw JSON (chuẩn Spring Boot @RequestBody)
      try {
        debugPrint(
          '[RentalRemoteDataSource][cancelBooking] Trying JSON on $endpoint with id=$bookingId',
        );
        final response = await dio.post(
          endpoint,
          data: {
            'id': bookingId,
            'bookingId': bookingId,
            'status': 'CANCELLED',
            if (reason != null && reason.trim().isNotEmpty)
              'reason': reason.trim(),
          },
          options: Options(
            headers: {
              if (authHeader != null) 'Authorization': authHeader,
              'Content-Type': 'application/json',
            },
            connectTimeout: const Duration(seconds: 8),
            sendTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
            validateStatus: (_) => true,
          ),
        );

        lastResponse = response;
        debugPrint(
          '[RentalRemoteDataSource][cancelBooking] JSON HTTP ${response.statusCode} body=${response.data}',
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint(
            '[RentalRemoteDataSource][cancelBooking] Success via JSON on $endpoint',
          );
          return;
        }

        if (response.statusCode != 404 && response.statusCode != 405) {
          throw Exception(
            _extractMessage(response.data) ??
                'Hủy đơn thuê thất bại (${response.statusCode})',
          );
        }
      } catch (e) {
        lastError = e;
        debugPrint(
          '[RentalRemoteDataSource][cancelBooking] JSON failed on $endpoint: $e',
        );
      }
    }

    final message = lastResponse != null
        ? _extractMessage(lastResponse.data)
        : null;
    throw Exception(
      message ??
          (lastError != null
              ? _extractMessage(lastError)
              : 'Hủy đơn thuê thất bại'),
    );
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
