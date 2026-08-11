import 'dart:convert';
import 'dart:async';

import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/profile/data/models/address_model.dart';
import 'package:book_drive_car/features/profile/data/models/vehicle_model.dart';
import 'package:book_drive_car/features/profile/domain/entities/add_vehicle_request_entity.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';

abstract class VehicleRemoteDataSource {
  Future<VehicleModel> addVehicle(AddVehicleRequestEntity request);
  Future<List<VehicleModel>> getMyVehicles();
}

@LazySingleton(as: VehicleRemoteDataSource)
class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final Dio dio;
  final UserLocalStorage userLocalStorage;

  VehicleRemoteDataSourceImpl(this.dio, this.userLocalStorage);

  String _fileNameOf(String path) {
    return path.split(RegExp(r'[\\/]+')).last;
  }

  MediaType _contentTypeOf(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lowerPath.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (lowerPath.endsWith('.pdf')) {
      return MediaType('application', 'pdf');
    }
    return MediaType('application', 'octet-stream');
  }

  String _extractErrorMessage(
    dynamic data, {
    String fallback = 'Thêm xe thất bại',
  }) {
    if (data == null) {
      return fallback;
    }

    if (data is String) {
      return data.trim().isNotEmpty ? data.trim() : fallback;
    }

    if (data is List) {
      final messages = data
          .map((item) => _extractErrorMessage(item, fallback: ''))
          .where((message) => message.trim().isNotEmpty)
          .toList();
      return messages.isNotEmpty ? messages.join('\n') : fallback;
    }

    if (data is Map) {
      final map = data.map((key, value) => MapEntry(key.toString(), value));

      for (final key in const [
        'message',
        'mesaage',
        'error',
        'errors',
        'detail',
        'description',
      ]) {
        final message = _extractErrorMessage(map[key], fallback: '');
        if (message.trim().isNotEmpty) {
          return message;
        }
      }

      final nestedData = map['data'];
      final nestedMessage = _extractErrorMessage(nestedData, fallback: '');
      if (nestedMessage.trim().isNotEmpty) {
        return nestedMessage;
      }

      for (final value in map.values) {
        if (value is Map || value is List) {
          final message = _extractErrorMessage(value, fallback: '');
          if (message.trim().isNotEmpty) {
            return message;
          }
        }
      }
    }

    return fallback;
  }

  Future<Options> _authOptions() async {
    final authHeader = await userLocalStorage.getAuthHeader();
    print(authHeader);
    return Options(
      headers: {if (authHeader != null) 'Authorization': authHeader},
      validateStatus: (_) => true,
    );
  }

  @override
  Future<VehicleModel> addVehicle(AddVehicleRequestEntity request) async {
    final addressModel = AddressModel(
      addressDetail: request.address.addressDetail,
      ward: request.address.ward,
      district: request.address.district,
      city: request.address.city,
    );
    final contractUrl = request.contractUrl?.trim() ?? '';
    final contractPdfLength = request.contractPdfBytes?.length ?? 0;
    print(
      'request.contractUrl: ${contractUrl.isEmpty ? "[empty]" : contractUrl}',
    );
    print('request.contractPdfBytes.length: $contractPdfLength');
    if (contractPdfLength > 0) {
      final previewCount = contractPdfLength > 16 ? 16 : contractPdfLength;
      final previewBytes = request.contractPdfBytes!.sublist(0, previewCount);
      print(
        'request.contractPdfBytes.preview(first $previewCount bytes): $previewBytes',
      );
    }
    final vehicleJson = {
      'vehicleName': request.vehicleName,
      'vehicleType': request.vehicleType,
      'brand': request.brand,
      'model': request.model,
      'year': request.year,
      'color': request.color,
      'licensePlate': request.licensePlate,
      'seatCount': request.seatCount,
      'fuelType': request.fuelType,
      'transmission': request.transmission,
      'pricePerDay': request.pricePerDay,
      'description': request.description,
      if (contractUrl.isNotEmpty) 'contractUrl': contractUrl,
      'address': addressModel.toJson(),
    };

    final formData = FormData();
    formData.files.add(
      MapEntry(
        'vehicle',
        MultipartFile.fromString(
          jsonEncode(vehicleJson),
          contentType: MediaType('application', 'json'),
        ),
      ),
    );
    formData.files.add(
      MapEntry(
        'vehicleRegistration',
        await MultipartFile.fromFile(
          request.vehicleRegistration.path,
          filename: _fileNameOf(request.vehicleRegistration.path),
          contentType: _contentTypeOf(request.vehicleRegistration.path),
        ),
      ),
    );

    for (final file in request.images) {
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(
            file.path,
            filename: _fileNameOf(file.path),
            contentType: _contentTypeOf(file.path),
          ),
        ),
      );
    }

    if (request.contractPdfBytes != null &&
        request.contractPdfBytes!.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'contractPdf',
          MultipartFile.fromBytes(
            request.contractPdfBytes!,
            filename:
                'contract_signed_${DateTime.now().millisecondsSinceEpoch}.pdf',
            contentType: MediaType('application', 'pdf'),
          ),
        ),
      );
    }

    try {
      final response = await dio.post(
        ApiConstants.vehicles,
        data: formData,
        options: await _authOptions(),
      );

      final data = response.data;
      final bodyStatus = data is Map<String, dynamic> ? data['status'] : null;
      final bodyMessage = data is Map<String, dynamic> ? data['message'] : null;
      final bodyData = data is Map<String, dynamic> ? data['data'] : null;

      debugPrint(
        '[VehicleRemoteDataSource][addVehicle] HTTP ${response.statusCode} body.status=$bodyStatus body.message=$bodyMessage body.data=$bodyData',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map<String, dynamic>) {
          final vehicleData = data['data'];
          if (vehicleData is Map<String, dynamic>) {
            return VehicleModel.fromJson(vehicleData);
          }
        }
        throw Exception('Dữ liệu xe từ server không hợp lệ');
      }

      throw Exception(_extractErrorMessage(data));
    } on DioException catch (error) {
      final isTimeout =
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.message?.toLowerCase().contains('timeout') == true;

      if (isTimeout) {
        throw Exception(
          'TIMEOUT: Dữ liệu đã được gửi đi nếu chưa hiển thị vui lòng nhập lại',
        );
      }

      final responseData = error.response?.data;
      final bodyStatus = responseData is Map<String, dynamic>
          ? responseData['status']
          : null;
      final bodyMessage = responseData is Map<String, dynamic>
          ? responseData['message']
          : null;
      final bodyData = responseData is Map<String, dynamic>
          ? responseData['data']
          : null;

      debugPrint(
        '[VehicleRemoteDataSource][addVehicle] DioException HTTP ${error.response?.statusCode} body.status=$bodyStatus body.message=$bodyMessage body.data=$bodyData',
      );

      throw Exception(
        _extractErrorMessage(
          responseData,
          fallback: error.message ?? 'Không thể kết nối đến server',
        ),
      );
    }
  }

  @override
  Future<List<VehicleModel>> getMyVehicles() async {
    try {
      final response = await dio.get(
        ApiConstants.myVehicles,
        options: await _authOptions(),
      );

      final data = response.data;
      if (response.statusCode == 200) {
        final rawVehicles = data is Map<String, dynamic> ? data['data'] : null;
        if (rawVehicles is List) {
          return rawVehicles
              .whereType<Map<String, dynamic>>()
              .map(VehicleModel.fromJson)
              .toList();
        }
        if (rawVehicles is Map<String, dynamic>) {
          return [VehicleModel.fromJson(rawVehicles)];
        }
        return [];
      }

      throw Exception(
        _extractErrorMessage(data, fallback: 'Lấy danh sách xe thất bại'),
      );
    } on DioException catch (error) {
      final responseData = error.response?.data;
      throw Exception(
        _extractErrorMessage(
          responseData,
          fallback: error.message ?? 'Không thể kết nối đến server',
        ),
      );
    }
  }
}
