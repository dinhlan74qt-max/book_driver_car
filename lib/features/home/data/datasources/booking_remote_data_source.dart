import 'dart:typed_data';
import 'dart:convert';

import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:book_drive_car/features/profile/domain/entities/address_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/storage/user_local_storage.dart';
import '../../domain/entities/verified_user_entity.dart';
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
  Future<VerifiedUserEntity> checkVerified();
  Future<String> uploadContractPdf({
    required Uint8List pdfBytes,
    required String fileName,
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

  VerifiedUserEntity _parseVerifiedUser(dynamic data) {
    if (data is Map<String, dynamic>) {
      final addressData = data['address'];
      final isVerifiedRaw = data['isCccdVerified'];
      final isVerified = isVerifiedRaw is bool
          ? isVerifiedRaw
          : isVerifiedRaw is String
          ? isVerifiedRaw.trim().toLowerCase() == 'true'
          : throw Exception('Server chưa trả về isCccdVerified trong data');
      return VerifiedUserEntity(
        fullname: data['fullname']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        phone: data['phone']?.toString() ?? '',
        cccd: data['cccd']?.toString(),
        isCccdVerified: isVerified,
        address: addressData is Map<String, dynamic>
            ? AddressEntity(
                addressDetail: addressData['addressDetail']?.toString() ?? '',
                ward: addressData['ward']?.toString() ?? '',
                district: addressData['district']?.toString() ?? '',
                city: addressData['city']?.toString() ?? '',
              )
            : null,
      );
    }

    throw Exception('Dữ liệu xác thực không hợp lệ');
  }

  @override
  Future<BookingModel> createBooking(BookingRequestEntity request) async {
    final authHeader = await userLocalStorage.getAuthHeader();
    final hasPdf =
        request.contractPdfBytes != null &&
        request.contractPdfBytes!.isNotEmpty;

    final formData = FormData();
    formData.files.add(
      MapEntry(
        'Dto',
        MultipartFile.fromString(
          jsonEncode({
            'vehicleId': request.vehicleId,
            'startDate': _formatApiDateTime(request.startDate),
            'endDate': _formatApiDateTime(request.endDate),
            'note': request.note,
          }),
          contentType: MediaType('application', 'json'),
        ),
      ),
    );

    if (hasPdf) {
      formData.files.add(
        MapEntry(
          'contractPdf',
          MultipartFile.fromBytes(
            request.contractPdfBytes!,
            filename:
                request.contractPdfFileName ??
                'contract_signed_${DateTime.now().millisecondsSinceEpoch}.pdf',
            contentType: MediaType('application', 'pdf'),
          ),
        ),
      );
    }

    final response = await dio.post(
      ApiConstants.bookings,
      data: formData,
      options: Options(
        headers: authHeader != null ? {'Authorization': authHeader} : null,
        validateStatus: (_) => true,
      ),
    );

    final data = response.data;
    if (response.statusCode == 200 || response.statusCode == 201) {
      final rawData = data is Map<String, dynamic>
          ? data['data'] ?? data
          : data;
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
  Future<VerifiedUserEntity> checkVerified() async {
    final authHeader = await userLocalStorage.getAuthHeader();
    debugPrint(
      '[BookingRemoteDataSource][checkVerified] GET ${ApiConstants.checkVerified}',
    );
    debugPrint(
      '[BookingRemoteDataSource][checkVerified] auth=${authHeader ?? "[none]"}',
    );
    final response = await dio.get(
      ApiConstants.checkVerified,
      options: Options(
        headers: authHeader != null ? {'Authorization': authHeader} : null,
        validateStatus: (_) => true,
      ),
    );

    final data = response.data;
    debugPrint(
      '[BookingRemoteDataSource][checkVerified] HTTP ${response.statusCode} body=$data',
    );
    if (response.statusCode == 200) {
      final rawData = data is Map<String, dynamic>
          ? data['data'] ?? data
          : data;
      final verifiedUser = _parseVerifiedUser(rawData);
      debugPrint(
        '[BookingRemoteDataSource][checkVerified] parsed isCccdVerified=${verifiedUser.isVerified} fullname=${verifiedUser.fullname} email=${verifiedUser.email} cccd=${verifiedUser.cccd ?? ""}',
      );
      if (!verifiedUser.isVerified) {
        throw Exception('Tài khoản chưa được xác thực');
      }
      return verifiedUser;
    }

    throw Exception(
      _extractErrorMessage(data, fallback: 'Tài khoản chưa được xác thực'),
    );
  }

  @override
  Future<String> uploadContractPdf({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    final authHeader = await userLocalStorage.getAuthHeader();
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        pdfBytes,
        filename: fileName,
        contentType: MediaType('application', 'pdf'),
      ),
    });

    final response = await dio.post(
      ApiConstants.contractUpload,
      data: formData,
      options: Options(
        headers: authHeader != null ? {'Authorization': authHeader} : null,
        validateStatus: (_) => true,
      ),
    );

    final data = response.data;
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data is Map<String, dynamic>) {
        final direct = data['contractUrl'] ?? data['url'];
        if (direct is String && direct.trim().isNotEmpty) return direct;
        final nested = data['data'];
        if (nested is Map<String, dynamic>) {
          final nestedUrl = nested['contractUrl'] ?? nested['url'];
          if (nestedUrl is String && nestedUrl.trim().isNotEmpty) {
            return nestedUrl;
          }
        }
      }
      return '';
    }

    throw Exception(
      _extractErrorMessage(data, fallback: 'Tải hợp đồng thất bại'),
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
      data: {'id': id, 'status': status, if (reason != null) 'reason': reason},
      options: Options(
        headers: authHeader != null ? {'Authorization': authHeader} : null,
        validateStatus: (_) => true,
      ),
    );

    final data = response.data;
    if (response.statusCode == 200 || response.statusCode == 201) {
      final rawData = data is Map<String, dynamic>
          ? data['data'] ?? data
          : data;
      if (rawData is Map<String, dynamic>) {
        return BookingModel.fromJson(rawData);
      }
      throw Exception(
        'Cập nhật đơn thuê thành công nhưng dữ liệu trả về không hợp lệ',
      );
    }

    throw Exception(
      _extractErrorMessage(
        data,
        fallback:
            'Cập nhật trạng thái đơn thuê thất bại (${response.statusCode})',
      ),
    );
  }
}
