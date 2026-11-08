import 'dart:convert';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/profile/data/models/owner_booking_model.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';

abstract class OwnerBookingRemoteDataSource {
  Future<List<OwnerBookingModel>> getOwnerBookings();
  Future<OwnerBookingModel> updateBookingStatus({
    required String id,
    required String status,
    String? reason,
    Uint8List? contractPdfBytes,
    String? contractPdfFileName,
  });
}

@LazySingleton(as: OwnerBookingRemoteDataSource)
class OwnerBookingRemoteDataSourceImpl implements OwnerBookingRemoteDataSource {
  final Dio dio;
  final UserLocalStorage userLocalStorage;

  OwnerBookingRemoteDataSourceImpl(this.dio, this.userLocalStorage);

  List<OwnerBookingModel> _parseBookingList(dynamic data) {
    final rawList = data is Map<String, dynamic>
        ? data['data']
        : data is List
        ? data
        : const [];

    if (rawList is! List) {
      return const [];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(OwnerBookingModel.fromJson)
        .toList();
  }

  Exception _buildFetchException(dynamic data, int? statusCode) {
    final message = data is Map<String, dynamic>
        ? (data['message']?.toString() ??
              data['error']?.toString() ??
              'Không tải được danh sách đơn đặt xe')
        : 'Không tải được danh sách đơn đặt xe';
    return Exception(
      '$message${statusCode != null ? ' (HTTP $statusCode)' : ''}',
    );
  }

  @override
  Future<List<OwnerBookingModel>> getOwnerBookings() async {
    final authHeader = await userLocalStorage.getAuthHeader();
    final endpoints = <String>[
      '${ApiConstants.baseUrl}/api/booking/owner/list',
      '${ApiConstants.baseUrl}/api/booking/owenr/list',
      '${ApiConstants.baseUrl}/api/bookings/owner',
    ];

    Object? lastError;
    for (final endpoint in endpoints) {
      try {
        final response = await dio.get(
          endpoint,
          options: Options(
            headers: {if (authHeader != null) 'Authorization': authHeader},
            validateStatus: (_) => true,
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return _parseBookingList(response.data);
        }

        lastError = _buildFetchException(response.data, response.statusCode);
      } catch (e) {
        lastError = e;
      }
    }

    debugPrint(
      '[OwnerBookingRemoteDataSource] getOwnerBookings failed: $lastError',
    );
    throw Exception(
      lastError?.toString().replaceFirst('Exception: ', '') ??
          'Không tải được danh sách đơn đặt xe',
    );
  }

  @override
  Future<OwnerBookingModel> updateBookingStatus({
    required String id,
    required String status,
    String? reason,
    Uint8List? contractPdfBytes,
    String? contractPdfFileName,
  }) async {
    final authHeader = await userLocalStorage.getAuthHeader();
    final parsedId = int.tryParse(id) ?? id;
    final hasPdf = contractPdfBytes != null && contractPdfBytes.isNotEmpty;

    final endpoints = <String>[
      '${ApiConstants.baseUrl}/api/booking/update-status',
      '${ApiConstants.baseUrl}/api/bookings/update-status',
      'http://192.168.1.52:8080/api/booking/update-status',
      'http://10.0.2.2:8080/api/booking/update-status',
      'http://localhost:8080/api/booking/update-status',
    ];

    Object? lastError;
    for (final endpoint in endpoints) {
      try {
        debugPrint(
          '[OwnerBookingRemoteDataSource] updateBookingStatus trying=$endpoint '
          'id=$id status=$status hasPdf=$hasPdf reason=${reason ?? "[none]"}',
        );
        final dtoJson = jsonEncode({
          'id': parsedId,
          'status': status,
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        });

        final requestData = FormData.fromMap({
          'Dto': MultipartFile.fromString(
            dtoJson,
            contentType: MediaType('application', 'json'),
          ),
          if (hasPdf)
            'contractPdf': MultipartFile.fromBytes(
              contractPdfBytes!,
              filename:
                  contractPdfFileName ??
                  'owner_signed_contract_${DateTime.now().millisecondsSinceEpoch}.pdf',
              contentType: MediaType('application', 'pdf'),
            ),
        });

        debugPrint(
          '[OwnerBookingRemoteDataSource] updateBookingStatus payload.Dto=$dtoJson '
          'pdfBytes=${contractPdfBytes?.length ?? 0}',
        );

        final response = await dio.post(
          endpoint,
          data: requestData,
          options: Options(
            headers: {if (authHeader != null) 'Authorization': authHeader},
            connectTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            validateStatus: (_) => true,
          ),
        );

        debugPrint(
          '[OwnerBookingRemoteDataSource] updateBookingStatus HTTP ${response.statusCode} '
          'endpoint=$endpoint body=${response.data}',
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          final payload = data is Map<String, dynamic>
              ? data['data'] ?? data
              : data;
          if (payload is Map<String, dynamic>) {
            return OwnerBookingModel.fromJson(payload);
          }

          throw Exception(
            'Cập nhật thành công nhưng dữ liệu phản hồi không hợp lệ',
          );
        }

        // Nếu multipart không được chấp nhận, thử fallback bằng JSON
        if (response.statusCode == 404 ||
            response.statusCode == 405 ||
            response.statusCode == 415) {
          try {
            debugPrint(
              '[OwnerBookingRemoteDataSource] updateBookingStatus trying JSON fallback on $endpoint',
            );
            final jsonResponse = await dio.post(
              endpoint,
              data: {
                'id': parsedId,
                'status': status,
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

            if (jsonResponse.statusCode == 200 ||
                jsonResponse.statusCode == 201) {
              final data = jsonResponse.data;
              final payload = data is Map<String, dynamic>
                  ? data['data'] ?? data
                  : data;
              if (payload is Map<String, dynamic>) {
                return OwnerBookingModel.fromJson(payload);
              }
            }
          } catch (e) {
            debugPrint('[OwnerBookingRemoteDataSource] JSON fallback error: $e');
          }
        }

        lastError = _buildFetchException(response.data, response.statusCode);
      } catch (e) {
        lastError = e;
      }
    }

    debugPrint(
      '[OwnerBookingRemoteDataSource] updateBookingStatus failed: $lastError',
    );
    throw Exception(
      lastError?.toString().replaceFirst('Exception: ', '') ??
          'Không cập nhật được trạng thái đơn đặt xe',
    );
  }
}
