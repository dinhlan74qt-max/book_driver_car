import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/home/data/models/car_model.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

abstract class HomeRemoteDataSource {
  Future<List<CarModel>> getCars();
  Future<List<CarModel>> searchCars(Map<String, dynamic> params);
  Future<List<CarModel>> searchCarsByCity(String cityName);
  Future<CarModel> getCarDetail(String id);
}

@LazySingleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;
  final UserLocalStorage userLocalStorage;

  HomeRemoteDataSourceImpl(this.dio, this.userLocalStorage);

  String _extractErrorMessage(
    dynamic data, {
    String fallback = 'Đã có lỗi xảy ra',
  }) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) return message;
    } else if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    return fallback;
  }

  List<CarModel> _parseCars(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => CarModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (data is Map) {
      final list = data['data'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => CarModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return [];
  }

  @override
  Future<List<CarModel>> getCars() async {
    final authHeader = await userLocalStorage.getAuthHeader();
    try {
      final response = await dio.get(
        ApiConstants.vehicles,
        options: Options(
          headers: {if (authHeader != null) 'Authorization': authHeader},
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200) {
        return _parseCars(response.data);
      }

      throw Exception(
        _extractErrorMessage(
          response.data,
          fallback: 'Không thể tải danh sách xe',
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        _extractErrorMessage(
          e.response?.data,
          fallback: e.message ?? 'Không thể kết nối đến server',
        ),
      );
    }
  }

  @override
  Future<List<CarModel>> searchCars(Map<String, dynamic> params) async {
    final authHeader = await userLocalStorage.getAuthHeader();
    try {
      debugPrint(
        '[HomeRemoteDataSource][searchCars] POST ${ApiConstants.searchVehicles} payload=$params',
      );
      final response = await dio.post(
        ApiConstants.searchVehicles,
        data: params,
        options: Options(
          headers: {
            if (authHeader != null) 'Authorization': authHeader,
            'Content-Type': 'application/json',
          },
          validateStatus: (_) => true,
        ),
      );

      debugPrint(
        '[HomeRemoteDataSource][searchCars] HTTP ${response.statusCode} data=${response.data}',
      );

      if (response.statusCode == 200) {
        return _parseCars(response.data);
      }

      if (response.statusCode == 404 || response.statusCode == 405) {
        debugPrint(
          '[HomeRemoteDataSource][searchCars] Server returned ${response.statusCode}, falling back to legacy endpoint/client filtering',
        );
        return await _fallbackSearchCars(params, authHeader);
      }

      throw Exception(
        _extractErrorMessage(response.data, fallback: 'Không thể tìm kiếm xe'),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        debugPrint(
          '[HomeRemoteDataSource][searchCars] DioException ${e.response?.statusCode}, falling back to legacy endpoint/client filtering',
        );
        return await _fallbackSearchCars(params, authHeader);
      }
      throw Exception(
        _extractErrorMessage(
          e.response?.data,
          fallback: e.message ?? 'Không thể kết nối đến server',
        ),
      );
    }
  }

  Future<List<CarModel>> _fallbackSearchCars(
    Map<String, dynamic> params,
    String? authHeader,
  ) async {
    List<CarModel> cars = [];
    final city = params['city']?.toString().trim();

    if (city != null && city.isNotEmpty) {
      try {
        final cityResponse = await dio.get(
          '${ApiConstants.baseUrl}/api/vehicles/city',
          queryParameters: {'name': city},
          options: Options(
            headers: {if (authHeader != null) 'Authorization': authHeader},
            validateStatus: (_) => true,
          ),
        );
        if (cityResponse.statusCode == 200) {
          cars = _parseCars(cityResponse.data);
        }
      } catch (_) {}
    }

    if (cars.isEmpty) {
      try {
        final allResponse = await dio.get(
          ApiConstants.vehicles,
          options: Options(
            headers: {if (authHeader != null) 'Authorization': authHeader},
            validateStatus: (_) => true,
          ),
        );
        if (allResponse.statusCode == 200) {
          cars = _parseCars(allResponse.data);
        }
      } catch (_) {}
    }

    return _filterCarsLocally(cars, params);
  }

  List<CarModel> _filterCarsLocally(
    List<CarModel> cars,
    Map<String, dynamic> params,
  ) {
    return cars.where((car) {
      // 1. City / Province
      final city = params['city']?.toString().trim().toLowerCase();
      if (city != null && city.isNotEmpty) {
        final provinceMatch = car.province.toLowerCase().contains(city);
        final locMatch = car.location.toLowerCase().contains(city);
        if (!provinceMatch && !locMatch) return false;
      }

      // 2. Brand
      final brand = params['brand']?.toString().trim().toLowerCase();
      if (brand != null && brand.isNotEmpty) {
        final brandMatch = car.brand.toLowerCase().contains(brand);
        final nameMatch = car.name.toLowerCase().contains(brand);
        if (!brandMatch && !nameMatch) return false;
      }

      // 3. Model
      final model = params['model']?.toString().trim().toLowerCase();
      if (model != null && model.isNotEmpty) {
        final modelMatch = (car.model ?? '').toLowerCase().contains(model);
        final nameMatch = car.name.toLowerCase().contains(model);
        if (!modelMatch && !nameMatch) return false;
      }

      // 4. Seats
      final minSeats = params['minSeats'];
      if (minSeats is num && car.seats < minSeats) return false;
      final maxSeats = params['maxSeats'];
      if (maxSeats is num && car.seats > maxSeats) return false;

      // 5. Price
      final minPrice = params['minPrice'];
      if (minPrice is num && car.pricePerDay < minPrice) return false;
      final maxPrice = params['maxPrice'];
      if (maxPrice is num && car.pricePerDay > maxPrice) return false;

      return true;
    }).toList();
  }

  @override
  Future<List<CarModel>> searchCarsByCity(String cityName) async {
    final authHeader = await userLocalStorage.getAuthHeader();
    try {
      debugPrint(
        '[HomeRemoteDataSource][searchCarsByCity] POST ${ApiConstants.searchVehicles} city=$cityName',
      );
      final response = await dio.post(
        ApiConstants.searchVehicles,
        data: {'city': cityName},
        options: Options(
          headers: {
            if (authHeader != null) 'Authorization': authHeader,
            'Content-Type': 'application/json',
          },
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200) {
        return _parseCars(response.data);
      }

      // Fallback sang endpoint cũ nếu cần
      final fallbackResponse = await dio.get(
        '${ApiConstants.baseUrl}/api/vehicles/city',
        queryParameters: {'name': cityName},
        options: Options(
          headers: {if (authHeader != null) 'Authorization': authHeader},
          validateStatus: (_) => true,
        ),
      );

      if (fallbackResponse.statusCode == 200) {
        return _parseCars(fallbackResponse.data);
      }

      throw Exception(
        _extractErrorMessage(
          response.data,
          fallback: 'Không thể tải danh sách xe theo thành phố',
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        _extractErrorMessage(
          e.response?.data,
          fallback: e.message ?? 'Không thể kết nối đến server',
        ),
      );
    }
  }

  @override
  Future<CarModel> getCarDetail(String id) async {
    final authHeader = await userLocalStorage.getAuthHeader();
    try {
      final response = await dio.get(
        '${ApiConstants.vehicles}/$id',
        options: Options(
          headers: {if (authHeader != null) 'Authorization': authHeader},
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return CarModel.fromJson((data is Map) ? (data['data'] ?? data) : data);
      }

      throw Exception(
        _extractErrorMessage(
          response.data,
          fallback: 'Không thể tải chi tiết xe',
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        _extractErrorMessage(
          e.response?.data,
          fallback: e.message ?? 'Không thể kết nối đến server',
        ),
      );
    }
  }
}
