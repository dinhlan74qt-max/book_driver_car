import 'dart:convert';
import 'dart:typed_data';

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

      // 1. Ưu tiên tìm các thông điệp chi tiết có nghĩa
      for (final key in const [
        'message',
        'mesaage',
        'detail',
        'description',
        'exception',
      ]) {
        final val = map[key];
        if (val != null) {
          final message = _extractErrorMessage(val, fallback: '');
          if (message.trim().isNotEmpty &&
              message.trim().toLowerCase() != 'internal server error' &&
              message.trim().toLowerCase() != 'null') {
            return message;
          }
        }
      }

      // 2. Kiểm tra trace nếu có (Spring Boot thường trả về trace chi tiết)
      if (map['trace'] != null) {
        final trace = map['trace'].toString();
        final firstLine = trace
            .split('\n')
            .firstWhere((l) => l.trim().isNotEmpty, orElse: () => trace);
        return 'Lỗi máy chủ: $firstLine';
      }

      // 3. Kiểm tra danh sách errors
      if (map['errors'] != null) {
        final err = _extractErrorMessage(map['errors'], fallback: '');
        if (err.trim().isNotEmpty) return err;
      }

      final nestedData = map['data'];
      final nestedMessage = _extractErrorMessage(nestedData, fallback: '');
      if (nestedMessage.trim().isNotEmpty) {
        return nestedMessage;
      }

      // 4. Nếu có error (Internal Server Error) kèm path
      if (map['error'] != null) {
        final errorStr = map['error'].toString().trim();
        final path = map['path']?.toString();
        if (errorStr.toLowerCase() == 'internal server error') {
          return 'Máy chủ gặp sự cố xử lý (Lỗi 500). Vui lòng kiểm tra tài khoản đã hoàn tất KYC chưa hoặc biển số xe có bị trùng không.';
        }
        return '$errorStr${path != null ? " ($path)" : ""}';
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
      'pricePerDay': request.pricePerDay.round(),
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

    final authOptions = await _authOptions();
    final vehicleJsonString = const JsonEncoder.withIndent('  ').convert(vehicleJson);

    debugPrint('\n==================== [ADD VEHICLE REQUEST] ====================');
    debugPrint('--> URL: ${ApiConstants.vehicles}');
    debugPrint('--> Headers: ${authOptions.headers}');
    debugPrint('--> [Part: vehicle (application/json)]:\n$vehicleJsonString');
    debugPrint('--> [Part: vehicleRegistration]: path=${request.vehicleRegistration.path}, name=${_fileNameOf(request.vehicleRegistration.path)}, exists=${request.vehicleRegistration.existsSync() ? "${request.vehicleRegistration.lengthSync()} bytes" : "false"}');
    debugPrint('--> [Part: files (${request.images.length} images)]:');
    for (int i = 0; i < request.images.length; i++) {
      final f = request.images[i];
      debugPrint('    [$i] path=${f.path}, name=${_fileNameOf(f.path)}, exists=${f.existsSync() ? "${f.lengthSync()} bytes" : "false"}');
    }
    if (request.contractPdfBytes != null && request.contractPdfBytes!.isNotEmpty) {
      debugPrint('--> [Part: contractPdf]: ${request.contractPdfBytes!.length} bytes');
    } else {
      debugPrint('--> [Part: contractPdf]: NONE (contractUrl: $contractUrl)');
    }
    debugPrint('================================================================\n');

    try {
      final response = await dio.post(
        ApiConstants.vehicles,
        data: formData,
        options: authOptions,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final percent = (sent / total * 100).toStringAsFixed(1);
            final sentKb = (sent / 1024).toStringAsFixed(0);
            final totalKb = (total / 1024).toStringAsFixed(0);
            debugPrint('[AddVehicle] 🚀 Đang tải lên: $sentKb KB / $totalKb KB ($percent%)');
          }
        },
      );

      final data = response.data;
      debugPrint('\n==================== [ADD VEHICLE RESPONSE] ====================');
      debugPrint('<-- HTTP Status: ${response.statusCode}');
      debugPrint('<-- Headers: ${response.headers.map}');
      debugPrint('<-- Raw Response Data:');
      try {
        if (data is Map || data is List) {
          debugPrint(const JsonEncoder.withIndent('  ').convert(data));
        } else {
          debugPrint('$data');
        }
      } catch (_) {
        debugPrint('$data');
      }
      debugPrint('================================================================\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map<String, dynamic>) {
          final vehicleData = data['data'];
          if (vehicleData is Map<String, dynamic>) {
            return VehicleModel.fromJson(vehicleData);
          }
        }
        throw Exception('Dữ liệu xe từ server không hợp lệ');
      }

      final errorMsg = _extractErrorMessage(data);
      debugPrint('[VehicleRemoteDataSource][addVehicle] ❌ Request failed with status ${response.statusCode}: $errorMsg');
      throw Exception(errorMsg);
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
      debugPrint('\n==================== [ADD VEHICLE DIO EXCEPTION] ====================');
      debugPrint('<-- HTTP Status: ${error.response?.statusCode}');
      debugPrint('<-- Error Type: ${error.type}');
      debugPrint('<-- Error Message: ${error.message}');
      debugPrint('<-- Response Data:');
      try {
        if (responseData is Map || responseData is List) {
          debugPrint(const JsonEncoder.withIndent('  ').convert(responseData));
        } else {
          debugPrint('$responseData');
        }
      } catch (_) {
        debugPrint('$responseData');
      }
      debugPrint('=====================================================================\n');

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
