import 'dart:convert';

import 'package:book_drive_car/shared/services/car_query/model/car_make.dart';
import 'package:book_drive_car/shared/services/car_query/model/car_model.dart';
import 'package:book_drive_car/shared/services/car_query/model/car_trim.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CarQueryService {
  CarQueryService({String? jwt})
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://carapi.app/api/',
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: {
              'accept': 'application/json',
              if (jwt != null && jwt.isNotEmpty) 'Authorization': 'Bearer $jwt',
            },
          ),
        );

  final Dio _dio;
  static List<CarMake>? _cachedMakes;
  static final Map<String, List<CarModel>> _cachedModels = {};
  static final Map<String, List<CarTrim>> _cachedTrims = {};

  static const List<CarMake> _fallbackMakes = [
    CarMake(id: 'toyota', name: 'Toyota'),
    CarMake(id: 'honda', name: 'Honda'),
    CarMake(id: 'mazda', name: 'Mazda'),
    CarMake(id: 'hyundai', name: 'Hyundai'),
    CarMake(id: 'kia', name: 'Kia'),
    CarMake(id: 'ford', name: 'Ford'),
    CarMake(id: 'mitsubishi', name: 'Mitsubishi'),
    CarMake(id: 'vinfast', name: 'VinFast'),
  ];

  static const Map<String, List<CarModel>> _fallbackModels = {
    'Toyota': [
      CarModel(id: 'camry', name: 'Camry', makeId: 'toyota', makeName: 'Toyota'),
      CarModel(id: 'vios', name: 'Vios', makeId: 'toyota', makeName: 'Toyota'),
      CarModel(id: 'corolla-altis', name: 'Corolla Altis', makeId: 'toyota', makeName: 'Toyota'),
    ],
    'Honda': [
      CarModel(id: 'city', name: 'City', makeId: 'honda', makeName: 'Honda'),
      CarModel(id: 'cr-v', name: 'CR-V', makeId: 'honda', makeName: 'Honda'),
      CarModel(id: 'civic', name: 'Civic', makeId: 'honda', makeName: 'Honda'),
    ],
    'Mazda': [
      CarModel(id: 'mazda3', name: 'Mazda3', makeId: 'mazda', makeName: 'Mazda'),
      CarModel(id: 'cx-5', name: 'CX-5', makeId: 'mazda', makeName: 'Mazda'),
    ],
    'Hyundai': [
      CarModel(id: 'accent', name: 'Accent', makeId: 'hyundai', makeName: 'Hyundai'),
      CarModel(id: 'santa-fe', name: 'Santa Fe', makeId: 'hyundai', makeName: 'Hyundai'),
    ],
    'Kia': [
      CarModel(id: 'morning', name: 'Morning', makeId: 'kia', makeName: 'Kia'),
      CarModel(id: 'seltos', name: 'Seltos', makeId: 'kia', makeName: 'Kia'),
    ],
    'Ford': [
      CarModel(id: 'ranger', name: 'Ranger', makeId: 'ford', makeName: 'Ford'),
      CarModel(id: 'territory', name: 'Territory', makeId: 'ford', makeName: 'Ford'),
    ],
    'Mitsubishi': [
      CarModel(id: 'xpander', name: 'Xpander', makeId: 'mitsubishi', makeName: 'Mitsubishi'),
      CarModel(id: 'outlander', name: 'Outlander', makeId: 'mitsubishi', makeName: 'Mitsubishi'),
    ],
    'VinFast': [
      CarModel(id: 'vf5', name: 'VF 5', makeId: 'vinfast', makeName: 'VinFast'),
      CarModel(id: 'vf6', name: 'VF 6', makeId: 'vinfast', makeName: 'VinFast'),
    ],
  };

  static const Map<String, List<CarTrim>> _fallbackTrims = {
    'Toyota|Camry': [
      CarTrim(id: 'camry-2.0g', name: '2.0G', year: 2023, seats: 5, fuel: 'Xăng', transmission: 'Số tự động'),
      CarTrim(id: 'camry-2.5q', name: '2.5Q', year: 2023, seats: 5, fuel: 'Xăng', transmission: 'Số tự động'),
    ],
    'Toyota|Vios': [
      CarTrim(id: 'vios-1.5e', name: '1.5E', year: 2023, seats: 5, fuel: 'Xăng', transmission: 'Số sàn'),
      CarTrim(id: 'vios-1.5g', name: '1.5G', year: 2023, seats: 5, fuel: 'Xăng', transmission: 'Số tự động'),
    ],
    'Honda|City': [
      CarTrim(id: 'city-rs', name: 'RS', year: 2023, seats: 5, fuel: 'Xăng', transmission: 'Số tự động'),
      CarTrim(id: 'city-l', name: 'L', year: 2023, seats: 5, fuel: 'Xăng', transmission: 'Số tự động'),
    ],
    'Mazda|CX-5': [
      CarTrim(id: 'cx5-premium', name: 'Premium', year: 2023, seats: 5, fuel: 'Xăng', transmission: 'Số tự động'),
    ],
    'Hyundai|Accent': [
      CarTrim(id: 'accent-1.4at', name: '1.4 AT', year: 2023, seats: 5, fuel: 'Xăng', transmission: 'Số tự động'),
    ],
    'Kia|Morning': [
      CarTrim(id: 'morning-1.2at', name: '1.2 AT', year: 2023, seats: 4, fuel: 'Xăng', transmission: 'Số tự động'),
    ],
    'Ford|Ranger': [
      CarTrim(id: 'ranger-wildtrak', name: 'Wildtrak', year: 2023, seats: 5, fuel: 'Dầu', transmission: 'Số tự động'),
      CarTrim(id: 'ranger-xls', name: 'XLS', year: 2023, seats: 5, fuel: 'Dầu', transmission: 'Số sàn'),
    ],
    'Mitsubishi|Xpander': [
      CarTrim(id: 'xpander-at', name: 'AT', year: 2023, seats: 7, fuel: 'Xăng', transmission: 'Số tự động'),
    ],
    'VinFast|VF 5': [
      CarTrim(id: 'vf5-plus', name: 'Plus', year: 2023, seats: 5, fuel: 'Điện', transmission: 'Số tự động'),
    ],
  };

  ///==========================
  /// GET MAKES
  ///==========================
  Future<List<CarMake>> getMakes() async {
    final cached = _cachedMakes;
    if (cached != null) return cached;

    try {
      final rows = await _fetchCollectionOnce(
        'makes/v2',
      );
      final makes = rows.map(CarMake.fromJson).toList();
      final result = makes.isNotEmpty ? makes : _fallbackMakes;
      _cachedMakes = result;
      return result;
    } on DioException catch (e) {
      if (_isRateLimit(e)) {
        _cachedMakes = _fallbackMakes;
        return _fallbackMakes;
      }
      rethrow;
    } catch (_) {
      _cachedMakes = _fallbackMakes;
      return _fallbackMakes;
    }
  }

  ///==========================
  /// GET MODELS
  ///==========================
  Future<List<CarModel>> getModels(CarMake make) async {
    final cacheKey = make.name;
    final cached = _cachedModels[cacheKey];
    if (cached != null) return cached;

    try {
      final rows = await _fetchCollectionOnce(
        'models/v2',
        queryParameters: {
          'make': make.name,
          'verbose': 'yes',
        },
      );

      final models = rows.map(CarModel.fromJson).toList();
      if (models.isNotEmpty) {
        _cachedModels[cacheKey] = models;
        return models;
      }
    } on DioException catch (e) {
      if (!_isRateLimit(e)) rethrow;
    } catch (_) {}

    final result = _fallbackModels[make.name] ?? const [];
    _cachedModels[cacheKey] = result;
    return result;
  }

  ///==========================
  /// GET ALL TRIMS
  ///==========================
  Future<List<CarTrim>> getTrims({
    required CarMake make,
    required CarModel model,
  }) async {
    final cacheKey = '${make.name}|${model.name}';
    final cached = _cachedTrims[cacheKey];
    if (cached != null) return cached;

    try {
      final trims = await _fetchCollectionOnce(
        'trims/v2',
        queryParameters: {
          'make': make.name,
          'model': model.name,
          'verbose': 'yes',
        },
      );

      final parsed = trims.map(CarTrim.fromJson).toList();
      final fallback = _fallbackTrims['${make.name}|${model.name}'];
      final result = parsed.isNotEmpty ? parsed : (fallback ?? const []);
      _cachedTrims[cacheKey] = result;
      return result;
    } on DioException catch (e) {
      if (_isRateLimit(e)) {
        final result = _fallbackTrims['${make.name}|${model.name}'] ?? const [];
        _cachedTrims[cacheKey] = result;
        return result;
      }
      rethrow;
    } catch (_) {
      final result = _fallbackTrims['${make.name}|${model.name}'] ?? const [];
      _cachedTrims[cacheKey] = result;
      return result;
    }
  }

  ///==========================
  /// REQUEST HELPERS
  ///==========================
  Future<List<Map<String, dynamic>>> _fetchCollectionOnce(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _requestJson(
      path,
      queryParameters: {
        if (queryParameters != null) ...queryParameters,
        'page': 1,
        'limit': 1000,
      },
    );

    final data = response['data'];
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return const [];
  }

  bool _isRateLimit(DioException e) => e.response?.statusCode == 429;

  Future<Map<String, dynamic>> _requestJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );

      dynamic body = response.data;

      if (body is String) {
        body = body.trim();
        if (body.isNotEmpty) {
          body = jsonDecode(body);
        }
      }

      if (body is Map) {
        return Map<String, dynamic>.from(body);
      }

      if (body is List) {
        return <String, dynamic>{'data': body};
      }

      throw FormatException(
        'CarAPI response is not a JSON object: ${body.runtimeType}',
      );
    } on DioException catch (e, st) {
      debugPrint('CarAPI request failed');
      debugPrint('Path: $path');
      debugPrint('Query: $queryParameters');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Error: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    } on FormatException catch (e, st) {
      debugPrint('CarAPI parse failed');
      debugPrint('Path: $path');
      debugPrint('Query: $queryParameters');
      debugPrint('Error: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    } catch (e, st) {
      debugPrint('Unexpected CarAPI error');
      debugPrint('Path: $path');
      debugPrint('Query: $queryParameters');
      debugPrint('Error: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }
}
