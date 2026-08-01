import 'dart:convert';

import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/profile/data/models/address_model.dart';
import 'package:book_drive_car/features/profile/data/models/vehicle_model.dart';
import 'package:book_drive_car/features/profile/domain/entities/add_vehicle_request_entity.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class VehicleRemoteDataSource {
  Future<VehicleModel> addVehicle(AddVehicleRequestEntity request);
}

@LazySingleton(as: VehicleRemoteDataSource)
class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final Dio dio;
  final UserLocalStorage userLocalStorage;

  VehicleRemoteDataSourceImpl(this.dio, this.userLocalStorage);

  String _fileNameOf(String path) {
    return path.split(RegExp(r'[\\/]+')).last;
  }

  String _extractErrorMessage(dynamic data, {String fallback = 'Thêm xe thất bại'}) {
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
  Future<VehicleModel> addVehicle(AddVehicleRequestEntity request) async {
    final addressModel = AddressModel(
      addressDetail: request.address.addressDetail,
      ward: request.address.ward,
      district: request.address.district,
      city: request.address.city,
    );

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
      'address': addressModel.toJson(),
    };

    final formData = FormData();
    formData.fields.add(MapEntry('vehicle', jsonEncode(vehicleJson)));
    formData.files.add(
      MapEntry(
        'vehicleRegistration',
        await MultipartFile.fromFile(
          request.vehicleRegistration.path,
          filename: _fileNameOf(request.vehicleRegistration.path),
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
          ),
        ),
      );
    }

    final authHeader = await userLocalStorage.getAuthHeader();

    try {
      final response = await dio.post(
        ApiConstants.vehicles,
        data: formData,
        options: Options(
          headers: {
            if (authHeader != null) 'Authorization': authHeader,
          },
          validateStatus: (_) => true,
        ),
      );

      final data = response.data;
      final responseMessage = _extractErrorMessage(data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map<String, dynamic>) {
          final vehicleData = data['data'];
          if (vehicleData is Map<String, dynamic>) {
            return VehicleModel.fromJson(vehicleData);
          }
        }
        throw Exception('Dữ liệu xe từ server không hợp lệ');
      }

      throw Exception(responseMessage);
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
