import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/home/data/models/car_model.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class FavoriteRemoteDataSource {
  Future<List<CarModel>> getFavorites();
  Future<String> addFavorite(dynamic vehicleId);
  Future<String> removeFavorite(dynamic vehicleId);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final Dio dio;
  final UserLocalStorage userLocalStorage;

  FavoriteRemoteDataSourceImpl(this.dio, this.userLocalStorage);

  List<String> _candidateUrls(String path) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return [
      '${ApiConstants.baseUrl}$cleanPath',
      'http://192.168.1.52:8080$cleanPath',
      'http://10.0.2.2:8080$cleanPath',
      'http://localhost:8080$cleanPath',
    ];
  }

  String _extractErrorMessage(dynamic data, {String fallback = 'Đã có lỗi xảy ra'}) {
    if (data is Map) {
      final msg = data['message'] ?? data['error'] ?? data['detail'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString().trim();
      }
    } else if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return fallback;
  }

  bool _isPathNotFound404(dynamic data) {
    if (data is! Map) return true;
    final error = data['error']?.toString().toLowerCase();
    final message = data['message']?.toString().toLowerCase() ?? '';
    final path = data['path'];

    // Spring Boot mặc định khi không tìm thấy Controller / route
    if (error == 'not found' && (message.isEmpty || message.contains('no static resource') || message.contains('not found'))) {
      if (path != null && !message.contains('xe') && !message.contains('vehicle')) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<List<CarModel>> getFavorites() async {
    final authHeader = await userLocalStorage.getAuthHeader();
    final urls = _candidateUrls('/api/favorites');

    Response? lastResponse;
    String? lastError;

    for (final url in urls) {
      try {
        debugPrint('[FavoriteRemoteDataSource][getFavorites] GET $url');
        final response = await dio.get(
          url,
          options: Options(
            headers: {
              if (authHeader != null) 'Authorization': authHeader,
              'Accept': 'application/json',
            },
            connectTimeout: const Duration(milliseconds: 2500),
            sendTimeout: const Duration(milliseconds: 2500),
            receiveTimeout: const Duration(milliseconds: 2500),
            validateStatus: (_) => true,
          ),
        );

        lastResponse = response;
        final statusCode = response.statusCode ?? 500;
        final data = response.data;
        debugPrint('[FavoriteRemoteDataSource][getFavorites] HTTP $statusCode from $url data=$data');

        if (statusCode >= 200 && statusCode < 300) {
          debugPrint('[FavoriteRemoteDataSource][getFavorites] Success 200 from $url');
          if (data is Map) {
            final rawList = data['data'];
            if (rawList is List) {
              return rawList
                  .whereType<Map>()
                  .map((e) => CarModel.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
            }
          } else if (data is List) {
            return data
                .whereType<Map>()
                .map((e) => CarModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
          return [];
        }

        if (statusCode == 404 && _isPathNotFound404(data)) {
          debugPrint('[FavoriteRemoteDataSource][getFavorites] 404 path not found at $url, trying next candidate');
          continue;
        }

        lastError = _extractErrorMessage(data, fallback: 'Không thể tải danh sách yêu thích (mã $statusCode)');
      } catch (e) {
        debugPrint('[FavoriteRemoteDataSource][getFavorites] Network exception at $url: $e');
        lastError = e.toString();
      }
    }

    if (lastResponse != null && lastResponse.statusCode == 404) {
      return [];
    }

    throw Exception(lastError ?? 'Không thể kết nối đến máy chủ để lấy danh sách yêu thích');
  }

  @override
  Future<String> addFavorite(dynamic vehicleId) async {
    final parsedId = int.tryParse(vehicleId.toString()) ?? 0;
    if (parsedId <= 0) {
      throw Exception('Mã xe không hợp lệ: $vehicleId');
    }

    final authHeader = await userLocalStorage.getAuthHeader();
    final urls = _candidateUrls('/api/favorites');
    final payload = {'vehicleId': parsedId};

    Response? lastResponse;
    String? lastError;

    for (final url in urls) {
      try {
        debugPrint('[FavoriteRemoteDataSource][addFavorite] POST $url payload=$payload');
        final response = await dio.post(
          url,
          data: payload,
          options: Options(
            headers: {
              if (authHeader != null) 'Authorization': authHeader,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            connectTimeout: const Duration(milliseconds: 2500),
            sendTimeout: const Duration(milliseconds: 2500),
            receiveTimeout: const Duration(milliseconds: 2500),
            validateStatus: (_) => true,
          ),
        );

        lastResponse = response;
        final statusCode = response.statusCode ?? 500;
        final data = response.data;
        debugPrint('[FavoriteRemoteDataSource][addFavorite] HTTP $statusCode from $url data=$data');

        if (statusCode >= 200 && statusCode < 300) {
          debugPrint('[FavoriteRemoteDataSource][addFavorite] Success 200 from $url');
          return _extractErrorMessage(data, fallback: 'Đã thêm xe vào danh sách yêu thích');
        }

        // Nếu là lỗi 404:
        if (statusCode == 404) {
          final isPath404 = _isPathNotFound404(data);
          if (isPath404) {
            debugPrint('[FavoriteRemoteDataSource][addFavorite] 404 path not deployed at $url, trying next candidate');
            continue;
          } else {
            // Lỗi nghiệp vụ từ backend (ví dụ: "Không tìm thấy xe")
            final msg = _extractErrorMessage(data, fallback: 'Không tìm thấy xe');
            debugPrint('[FavoriteRemoteDataSource][addFavorite] Backend business 404: $msg');
            throw Exception(msg);
          }
        }

        lastError = _extractErrorMessage(data, fallback: 'Thêm yêu thích thất bại (mã $statusCode)');
      } catch (e) {
        if (e is Exception && !e.toString().contains('DioException')) {
          rethrow;
        }
        debugPrint('[FavoriteRemoteDataSource][addFavorite] Network exception at $url: $e');
        lastError = e.toString();
      }
    }

    throw Exception(lastError ?? 'Không thể kết nối đến máy chủ để thêm xe vào yêu thích');
  }

  @override
  Future<String> removeFavorite(dynamic vehicleId) async {
    final parsedId = int.tryParse(vehicleId.toString()) ?? 0;
    if (parsedId <= 0) {
      throw Exception('Mã xe không hợp lệ: $vehicleId');
    }

    final authHeader = await userLocalStorage.getAuthHeader();
    final urls = _candidateUrls('/api/favorites/$parsedId');

    Response? lastResponse;
    String? lastError;

    for (final url in urls) {
      try {
        debugPrint('[FavoriteRemoteDataSource][removeFavorite] DELETE $url');
        final response = await dio.delete(
          url,
          options: Options(
            headers: {
              if (authHeader != null) 'Authorization': authHeader,
              'Accept': 'application/json',
            },
            connectTimeout: const Duration(milliseconds: 2500),
            sendTimeout: const Duration(milliseconds: 2500),
            receiveTimeout: const Duration(milliseconds: 2500),
            validateStatus: (_) => true,
          ),
        );

        lastResponse = response;
        final statusCode = response.statusCode ?? 500;
        final data = response.data;
        debugPrint('[FavoriteRemoteDataSource][removeFavorite] HTTP $statusCode from $url data=$data');

        if (statusCode >= 200 && statusCode < 300) {
          debugPrint('[FavoriteRemoteDataSource][removeFavorite] Success 200 from $url');
          return _extractErrorMessage(data, fallback: 'Đã xóa xe khỏi danh sách yêu thích');
        }

        if (statusCode == 404 && _isPathNotFound404(data)) {
          debugPrint('[FavoriteRemoteDataSource][removeFavorite] 404 path not deployed at $url, trying next candidate');
          continue;
        }

        lastError = _extractErrorMessage(data, fallback: 'Xóa yêu thích thất bại (mã $statusCode)');
      } catch (e) {
        if (e is Exception && !e.toString().contains('DioException')) {
          rethrow;
        }
        debugPrint('[FavoriteRemoteDataSource][removeFavorite] Network exception at $url: $e');
        lastError = e.toString();
      }
    }

    throw Exception(lastError ?? 'Không thể kết nối đến máy chủ để xóa xe khỏi yêu thích');
  }
}
