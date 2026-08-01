import 'package:dio/dio.dart';

class ProvinceDivision {
  final int code;
  final String name;
  final List<DistrictDivision> districts;

  const ProvinceDivision({
    required this.code,
    required this.name,
    this.districts = const [],
  });

  factory ProvinceDivision.fromJson(Map<String, dynamic> json) {
    final districtsJson = json['districts'];
    return ProvinceDivision(
      code: (json['code'] as num).toInt(),
      name: (json['name'] as String?)?.trim() ?? '',
      districts: districtsJson is List
          ? districtsJson
              .whereType<Map>()
              .map((item) => DistrictDivision.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
    );
  }
}

class DistrictDivision {
  final int code;
  final String name;
  final int provinceCode;
  final List<WardDivision> wards;

  const DistrictDivision({
    required this.code,
    required this.name,
    required this.provinceCode,
    this.wards = const [],
  });

  factory DistrictDivision.fromJson(Map<String, dynamic> json) {
    final wardsJson = json['wards'];
    return DistrictDivision(
      code: (json['code'] as num).toInt(),
      name: (json['name'] as String?)?.trim() ?? '',
      provinceCode: (json['province_code'] as num?)?.toInt() ?? 0,
      wards: wardsJson is List
          ? wardsJson
              .whereType<Map>()
              .map((item) => WardDivision.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
    );
  }
}

class WardDivision {
  final int code;
  final String name;
  final int districtCode;
  final int provinceCode;

  const WardDivision({
    required this.code,
    required this.name,
    required this.districtCode,
    required this.provinceCode,
  });

  factory WardDivision.fromJson(Map<String, dynamic> json) {
    return WardDivision(
      code: (json['code'] as num).toInt(),
      name: (json['name'] as String?)?.trim() ?? '',
      districtCode: (json['district_code'] as num?)?.toInt() ?? 0,
      provinceCode: (json['province_code'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProvinceOpenApiService {
  ProvinceOpenApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://provinces.open-api.vn/api/v1/',
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                headers: const {'accept': 'application/json'},
              ),
            );

  final Dio _dio;

  static List<ProvinceDivision>? _cachedProvinces;
  static final Map<int, List<DistrictDivision>> _cachedDistricts = {};
  static final Map<int, List<WardDivision>> _cachedWards = {};

  Future<List<ProvinceDivision>> getProvinces() async {
    final cached = _cachedProvinces;
    if (cached != null) return cached;

    final response = await _dio.get(
      'p/',
      queryParameters: const {'depth': 2},
    );

    final provinces = _parseList(response.data, ProvinceDivision.fromJson);
    _cachedProvinces = provinces;
    return provinces;
  }

  Future<List<DistrictDivision>> getDistricts(int provinceCode) async {
    final cached = _cachedDistricts[provinceCode];
    if (cached != null) return cached;

    final response = await _dio.get(
      'p/$provinceCode',
      queryParameters: const {'depth': 2},
    );

    final province = ProvinceDivision.fromJson(_asMap(response.data));
    final districts = province.districts;
    _cachedDistricts[provinceCode] = districts;
    return districts;
  }

  Future<List<WardDivision>> getWards(int districtCode) async {
    final cached = _cachedWards[districtCode];
    if (cached != null) return cached;

    final response = await _dio.get(
      'd/$districtCode',
      queryParameters: const {'depth': 2},
    );

    final district = DistrictDivision.fromJson(_asMap(response.data));
    final wards = district.wards;
    _cachedWards[districtCode] = wards;
    return wards;
  }

  List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) mapper,
  ) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => mapper(Map<String, dynamic>.from(item)))
          .toList();
    }
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}
