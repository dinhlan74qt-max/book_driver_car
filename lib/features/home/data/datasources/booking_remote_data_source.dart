import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import '../../../../core/storage/user_local_storage.dart';
import '../models/booking_availability_model.dart';
import '../../domain/entities/booking_request_entity.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking(BookingRequestEntity request);
  Future<List<BookingAvailabilityModel>> getBookedRanges(int vehicleId);
  Future<BookingModel> updateBookingStatus({
    required int id,
    required String status,
    String? reason,
  });
}

@LazySingleton(as: BookingRemoteDataSource)
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;
  final UserLocalStorage userLocalStorage;

  BookingRemoteDataSourceImpl(this.dio, this.userLocalStorage);

  String _formatApiDateTime(DateTime value) {
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(value);
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
  Future<BookingModel> createBooking(BookingRequestEntity request) async {
    final authHeader = await userLocalStorage.getAuthHeader();

    final response = await dio.post(
      ApiConstants.bookings, // "$baseUrl/api/booking"
      data: {
        "vehicleId": request.vehicleId,
        "startDate": _formatApiDateTime(request.startDate),
        "endDate": _formatApiDateTime(request.endDate),
        "note": request.note,
      },
      options: Options(
        headers: authHeader != null ? {'Authorization': authHeader} : null,
        validateStatus: (_) => true,
      ),
    );

    final data = response.data;
    if (response.statusCode == 200 || response.statusCode == 201) {
      final rawData = data is Map<String, dynamic> ? data['data'] ?? data : data;
      if (rawData is Map<String, dynamic>) {
        return BookingModel.fromJson(
          rawData,
          fallbackVehicleId: request.vehicleId,
          fallbackStartDate: request.startDate,
          fallbackEndDate: request.endDate,
        );
      }
      debugPrint(
        '[BookingRemoteDataSource][createBooking] invalid success payload = $data',
      );
      throw Exception('Đặt lịch thành công nhưng dữ liệu trả về không hợp lệ');
    }

    throw Exception(
      _extractErrorMessage(
        data,
        fallback: 'Đặt lịch thất bại (${response.statusCode})',
      ),
    );
  }

  @override
  Future<List<BookingAvailabilityModel>> getBookedRanges(int vehicleId) async {
    final authHeader = await userLocalStorage.getAuthHeader();
    final response = await dio.get(
      '${ApiConstants.bookingStatus}/$vehicleId',
      options: Options(
        headers: authHeader != null ? {'Authorization': authHeader} : null,
        validateStatus: (_) => true,
      ),
    );

    final data = response.data;
    if (response.statusCode == 200) {
      final rawList = data is Map<String, dynamic> ? data['data'] : null;
      if (rawList is List) {
        return rawList
            .whereType<Map>()
            .map(
              (item) => BookingAvailabilityModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }
      return [];
    }

    final message = _extractErrorMessage(
      data,
      fallback: 'Không thể tải lịch đã đặt',
    );
    debugPrint(
      '[BookingRemoteDataSource][getBookedRanges] HTTP ${response.statusCode}: $message',
    );
    throw Exception(message);
  }

  @override
  Future<BookingModel> updateBookingStatus({
    required int id,
    required String status,
    String? reason,
  }) async {
    final authHeader = await userLocalStorage.getAuthHeader();

    final response = await dio.post(
      '${ApiConstants.baseUrl}/api/booking/update-status',
      data: {
        'id': id,
        'status': status,
        if (reason != null) 'reason': reason,
      },
      options: Options(
        headers: authHeader != null ? {'Authorization': authHeader} : null,
        validateStatus: (_) => true,
      ),
    );

    final data = response.data;
    if (response.statusCode == 200 || response.statusCode == 201) {
      final rawData = data is Map<String, dynamic> ? data['data'] ?? data : data;
      if (rawData is Map<String, dynamic>) {
        return BookingModel.fromJson(rawData);
      }
      throw Exception('Cập nhật đơn thuê thành công nhưng dữ liệu trả về không hợp lệ');
    }

    throw Exception(
      _extractErrorMessage(
        data,
        fallback: 'Cập nhật trạng thái đơn thuê thất bại (${response.statusCode})',
      ),
    );
  }
}
