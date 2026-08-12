import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/home/data/models/car_model.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
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
      final response = await dio.get(
        ApiConstants.vehicles,
        queryParameters: params.isNotEmpty ? params : null,
        options: Options(
          headers: {if (authHeader != null) 'Authorization': authHeader},
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200) {
        return _parseCars(response.data);
      }

      throw Exception(
        _extractErrorMessage(response.data, fallback: 'Không thể tìm kiếm xe'),
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
  Future<List<CarModel>> searchCarsByCity(String cityName) async {
    final authHeader = await userLocalStorage.getAuthHeader();
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/api/vehicles/city',
        queryParameters: {'name': cityName},
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
