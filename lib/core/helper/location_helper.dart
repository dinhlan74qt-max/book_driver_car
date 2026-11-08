import 'dart:convert';
import 'package:book_drive_car/features/home/presentation/widget/city_search_suggestions.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationHelper {
  LocationHelper._();

  /// Tọa độ trung tâm của các tỉnh/thành phố tại Việt Nam
  static const Map<String, ({double lat, double lng})> _cityCentroids = {
    'Hà Nội': (lat: 21.0285, lng: 105.8542),
    'Hồ Chí Minh': (lat: 10.8231, lng: 106.6297),
    'Đà Nẵng': (lat: 16.0544, lng: 108.2022),
    'Hải Phòng': (lat: 20.8449, lng: 106.6881),
    'Cần Thơ': (lat: 10.0452, lng: 105.7469),
    'An Giang': (lat: 10.5216, lng: 105.1259),
    'Bà Rịa - Vũng Tàu': (lat: 10.5425, lng: 107.2429),
    'Bắc Giang': (lat: 21.2731, lng: 106.1946),
    'Bắc Kạn': (lat: 22.1470, lng: 105.8348),
    'Bạc Liêu': (lat: 9.2941, lng: 105.7278),
    'Bắc Ninh': (lat: 21.1861, lng: 106.0763),
    'Bến Tre': (lat: 10.2434, lng: 106.3756),
    'Bình Định': (lat: 14.1667, lng: 108.9000),
    'Bình Dương': (lat: 11.1667, lng: 106.6667),
    'Bình Phước': (lat: 11.7511, lng: 106.9013),
    'Bình Thuận': (lat: 11.0904, lng: 108.0722),
    'Cà Mau': (lat: 9.1769, lng: 105.1524),
    'Cao Bằng': (lat: 22.6657, lng: 106.2570),
    'Đắk Lắk': (lat: 12.6667, lng: 108.0383),
    'Đắk Nông': (lat: 12.0000, lng: 107.6833),
    'Điện Biên': (lat: 21.3853, lng: 103.0175),
    'Đồng Nai': (lat: 11.0667, lng: 107.0000),
    'Đồng Tháp': (lat: 10.4578, lng: 105.6322),
    'Gia Lai': (lat: 13.9833, lng: 108.0000),
    'Hà Giang': (lat: 22.8233, lng: 104.9839),
    'Hà Nam': (lat: 20.5833, lng: 105.9167),
    'Hà Tĩnh': (lat: 18.3560, lng: 105.8970),
    'Hải Dương': (lat: 20.9372, lng: 106.3150),
    'Hậu Giang': (lat: 9.7833, lng: 105.4667),
    'Hòa Bình': (lat: 20.8172, lng: 105.3376),
    'Hưng Yên': (lat: 20.6464, lng: 106.0511),
    'Khánh Hòa': (lat: 12.2388, lng: 109.1967),
    'Kiên Giang': (lat: 10.0139, lng: 105.0809),
    'Kon Tum': (lat: 14.3500, lng: 108.0000),
    'Lai Châu': (lat: 22.3964, lng: 103.4589),
    'Lâm Đồng': (lat: 11.9404, lng: 108.4583),
    'Lạng Sơn': (lat: 21.8537, lng: 106.7615),
    'Lào Cai': (lat: 22.4856, lng: 103.9707),
    'Long An': (lat: 10.5360, lng: 106.4095),
    'Nam Định': (lat: 20.4344, lng: 106.1773),
    'Nghệ An': (lat: 19.3333, lng: 104.8333),
    'Ninh Bình': (lat: 20.2506, lng: 105.9745),
    'Ninh Thuận': (lat: 11.5653, lng: 108.9882),
    'Phú Thọ': (lat: 21.3228, lng: 105.2140),
    'Phú Yên': (lat: 13.0882, lng: 109.0929),
    'Quảng Bình': (lat: 17.4690, lng: 106.6223),
    'Quảng Nam': (lat: 15.5394, lng: 108.0249),
    'Quảng Ngãi': (lat: 15.1205, lng: 108.7923),
    'Quảng Ninh': (lat: 21.0069, lng: 107.2925),
    'Quảng Trị': (lat: 16.7490, lng: 107.1855),
    'Sóc Trăng': (lat: 9.6033, lng: 105.9800),
    'Sơn La': (lat: 21.3283, lng: 103.9148),
    'Tây Ninh': (lat: 11.3100, lng: 106.0983),
    'Thái Bình': (lat: 20.4463, lng: 106.3366),
    'Thái Nguyên': (lat: 21.5942, lng: 105.8481),
    'Thanh Hóa': (lat: 19.8067, lng: 105.7852),
    'Thừa Thiên Huế': (lat: 16.4637, lng: 107.5909),
    'Tiền Giang': (lat: 10.3600, lng: 106.3600),
    'Trà Vinh': (lat: 9.9347, lng: 106.3455),
    'Tuyên Quang': (lat: 21.8236, lng: 105.2182),
    'Vĩnh Long': (lat: 10.2537, lng: 105.9722),
    'Vĩnh Phúc': (lat: 21.3089, lng: 105.6049),
    'Yên Bái': (lat: 21.7168, lng: 104.8974),
  };

  /// Lấy tên Tỉnh / Thành phố từ tọa độ (lat, lng).
  /// Ưu tiên Reverse Geocoding qua API, fallback về khoảng cách địa lý gần nhất.
  static Future<String> getProvinceFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // 1. Thử reverse geocode online qua OpenStreetMap Nominatim
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json&accept-language=vi',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'CarNowApp/1.0 (contact@carnow.vn)'},
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        if (address is Map<String, dynamic>) {
          final matched = _matchCityNameFromAddress(address);
          if (matched != null) {
            debugPrint('[LocationHelper] Reverse geocode matched: $matched');
            return matched;
          }
        }
      }
    } catch (e) {
      debugPrint('[LocationHelper] Nominatim reverse geocode error: $e');
    }

    // 2. Thử tiếp qua BigDataCloud free reverse geocode nếu Nominatim thất bại
    try {
      final uri = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$latitude&longitude=$longitude&localityLanguage=vi',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          final subdivision = data['principalSubdivision']?.toString() ?? '';
          final city = data['city']?.toString() ?? '';
          final matched = _findMatchingCity('$subdivision $city');
          if (matched != null) {
            debugPrint('[LocationHelper] BigDataCloud matched: $matched');
            return matched;
          }
        }
      }
    } catch (e) {
      debugPrint('[LocationHelper] BigDataCloud error: $e');
    }

    // 3. Fallback chính xác nhất: Tính khoảng cách địa lý tới trung tâm 63 tỉnh thành
    final nearest = getNearestCity(latitude, longitude);
    debugPrint('[LocationHelper] Fallback nearest centroid: $nearest');
    return nearest;
  }

  /// Trích xuất tên thành phố chuẩn từ address map
  static String? _matchCityNameFromAddress(Map<String, dynamic> address) {
    final candidateKeys = [
      'city',
      'state',
      'province',
      'region',
      'city_district',
      'county',
      'town',
    ];

    for (final key in candidateKeys) {
      final rawVal = address[key]?.toString();
      if (rawVal != null && rawVal.isNotEmpty) {
        final matched = _findMatchingCity(rawVal);
        if (matched != null) return matched;
      }
    }
    return null;
  }

  /// So khớp chuỗi bất kỳ với danh sách 63 tỉnh/thành phố chuẩn
  static String? _findMatchingCity(String rawText) {
    final normalizedInput = normalizeVietnameseText(rawText);

    for (final city in kVietnamCitySuggestions) {
      final normalizedCity = normalizeVietnameseText(city);
      if (normalizedInput.contains(normalizedCity) ||
          normalizedCity.contains(normalizedInput)) {
        return city;
      }
    }
    return null;
  }

  /// Tìm tỉnh thành có tọa độ trung tâm gần nhất với tọa độ truyền vào
  static String getNearestCity(double latitude, double longitude) {
    String nearestCity = 'Đà Nẵng';
    double minDistance = double.infinity;

    for (final entry in _cityCentroids.entries) {
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        entry.value.lat,
        entry.value.lng,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = entry.key;
      }
    }

    return nearestCity;
  }
}
