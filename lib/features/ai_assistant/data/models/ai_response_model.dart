import 'package:book_drive_car/features/ai_assistant/domain/entities/ai_response_entity.dart';
import 'package:book_drive_car/features/home/data/models/car_model.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:flutter/foundation.dart';

class AiResponseModel extends AiResponseEntity {
  const AiResponseModel({
    required super.aiProvider,
    required super.aiStatus,
    required super.reply,
    required super.recommendations,
  });

  factory AiResponseModel.fromJson(Map<String, dynamic> json) {
    dynamic rawRecs = json['recommendations'] ??
        json['Recommendations'] ??
        json['recommendedCars'] ??
        json['cars'] ??
        json['vehicles'];

    if (rawRecs == null && json['data'] is Map) {
      final dataMap = json['data'] as Map;
      rawRecs = dataMap['recommendations'] ??
          dataMap['Recommendations'] ??
          dataMap['cars'] ??
          dataMap['vehicles'];
    } else if (rawRecs == null && json['data'] is List) {
      rawRecs = json['data'];
    }

    final List<CarEntity> parsedCars = [];

    if (rawRecs is List) {
      for (final item in rawRecs) {
        try {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            try {
              parsedCars.add(CarModel.fromJson(map));
            } catch (err) {
              debugPrint('⚠️ [AiResponseModel] CarModel.fromJson error: $err, fallback manual parse');
              parsedCars.add(_manualParseCar(map));
            }
          }
        } catch (e) {
          debugPrint('⚠️ [AiResponseModel] Skip item error: $e');
        }
      }
    }

    // Không hiển thị thương hiệu Gemini theo yêu cầu của người dùng
    String provider = json['aiProvider']?.toString() ?? 'CarNow AI';
    if (provider.toLowerCase().contains('gemini')) {
      provider = 'CarNow AI';
    }

    return AiResponseModel(
      aiProvider: provider,
      aiStatus: json['aiStatus']?.toString() ?? 'SUCCESS',
      reply: json['reply']?.toString() ?? '',
      recommendations: parsedCars,
    );
  }

  static CarEntity _manualParseCar(Map<String, dynamic> map) {
    final List<String> imageUrls = [];
    final rawImgs = map['imageUrls'] ?? map['images'];
    if (rawImgs is List) {
      for (final i in rawImgs) {
        if (i != null && i.toString().isNotEmpty) imageUrls.add(i.toString());
      }
    } else if (map['imageUrl'] != null) {
      imageUrls.add(map['imageUrl'].toString());
    }

    String fullLoc = '';
    String prov = '';
    final addr = map['address'];
    if (addr is Map) {
      prov = addr['city']?.toString() ?? '';
      final d = addr['addressDetail']?.toString() ?? '';
      final w = addr['ward']?.toString() ?? '';
      final c = addr['city']?.toString() ?? '';
      fullLoc = [d, w, c].where((s) => s.isNotEmpty).join(', ');
    } else if (addr != null) {
      fullLoc = addr.toString();
      prov = fullLoc;
    }

    int parseNum(dynamic val, [int fb = 0]) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fb;
      return fb;
    }

    double parseDouble(dynamic val, [double fb = 0.0]) {
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? fb;
      return fb;
    }

    return CarEntity(
      id: map['id']?.toString() ?? '',
      name: map['vehicleName']?.toString() ??
          map['name']?.toString() ??
          'Ô tô cho thuê',
      brand: map['brand']?.toString() ?? '',
      vehicleType: map['vehicleType']?.toString() ?? 'CAR',
      province: prov,
      imageIcon: imageUrls.isNotEmpty ? imageUrls.first : '',
      imageUrls: imageUrls,
      pricePerDay: parseNum(map['pricePerDay'] ?? map['price']),
      distanceKm: parseDouble(map['Distance'] ?? map['distance']),
      seats: parseNum(map['seatCount'] ?? map['seats'], 4),
      rating: parseDouble(map['rating'], 4.9),
      location: fullLoc,
      model: map['model']?.toString(),
      year: parseNum(map['year'], 2022),
      color: map['color']?.toString(),
      fuelType: map['fuelType']?.toString(),
      transmission: map['transmission']?.toString(),
      description: map['description']?.toString(),
      licensePlate: map['licensePlate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aiProvider': aiProvider,
      'aiStatus': aiStatus,
      'reply': reply,
      'recommendations': recommendations.map((e) {
        return {
          'id': e.id,
          'vehicleName': e.name,
          'brand': e.brand,
          'pricePerDay': e.pricePerDay,
          'seatCount': e.seats,
          'transmission': e.transmission,
          'fuelType': e.fuelType,
          'imageUrls': e.imageUrls,
        };
      }).toList(),
    };
  }
}
