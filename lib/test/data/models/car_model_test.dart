import 'package:book_drive_car/features/home/data/models/car_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CarModel - fromJson', () {
    test('nên deserialize thành công với JSON đầy đủ dữ liệu và nested address Map', () {
      final json = {
        'id': 28,
        'vehicleName': 'Mazda 3 Luxury',
        'brand': 'Mazda',
        'vehicleType': 'CAR',
        'pricePerDay': 900000,
        'Distance': 1.5,
        'seatCount': 5,
        'rating': 4.9,
        'model': 'Mazda 3',
        'year': 2023,
        'color': 'Đỏ',
        'fuelType': 'Xăng',
        'transmission': 'Tự động',
        'description': 'Xe gia đình mới đẹp',
        'licensePlate': '30A-999.88',
        'imageUrls': ['https://example.com/car1.jpg', 'https://example.com/car2.jpg'],
        'address': {
          'addressDetail': 'Số 15 Cầu Giấy',
          'ward': 'Dịch Vọng',
          'city': 'Hà Nội',
        },
        'user': {
          'fullname': 'Nguyễn Văn Chủ Xe',
          'phone': '0912345678',
        },
      };

      final car = CarModel.fromJson(json);

      expect(car.id, equals('28'));
      expect(car.name, equals('Mazda 3 Luxury'));
      expect(car.brand, equals('Mazda'));
      expect(car.vehicleType, equals('CAR'));
      expect(car.pricePerDay, equals(900000));
      expect(car.distanceKm, equals(1.5));
      expect(car.seats, equals(5));
      expect(car.rating, equals(4.9));
      expect(car.year, equals(2023));
      expect(car.color, equals('Đỏ'));
      expect(car.licensePlate, equals('30A-999.88'));
      expect(car.province, equals('Hà Nội'));
      expect(car.location, equals('Số 15 Cầu Giấy, Dịch Vọng, Hà Nội'));
      expect(car.imageIcon, equals('https://example.com/car1.jpg'));
      expect(car.imageUrls.length, equals(2));
      expect(car.ownerName, equals('Nguyễn Văn Chủ Xe'));
      expect(car.ownerPhone, equals('0912345678'));
    });

    test('nên gán giá trị mặc định (fallback) cho seats, rating và chuỗi rỗng khi JSON thiếu trường', () {
      final json = <String, dynamic>{
        'id': '101',
        'vehicleName': 'Toyota Vios',
      };

      final car = CarModel.fromJson(json);

      expect(car.id, equals('101'));
      expect(car.name, equals('Toyota Vios'));
      expect(car.seats, equals(4)); // Mặc định 4 chỗ khi thiếu
      expect(car.rating, equals(4.8)); // Mặc định 4.8 khi thiếu
      expect(car.pricePerDay, equals(0));
      expect(car.distanceKm, equals(0.0));
      expect(car.imageUrls, isEmpty);
      expect(car.imageIcon, equals(''));
      expect(car.province, equals(''));
      expect(car.location, equals(''));
      expect(car.ownerName, isNull);
      expect(car.ownerPhone, isNull);
    });

    test('nên xử lý address dạng String thay vì Map', () {
      final json = {
        'id': '50',
        'vehicleName': 'Honda City',
        'address': 'Quận 1, TP Hồ Chí Minh',
      };

      final car = CarModel.fromJson(json);

      expect(car.location, equals('Quận 1, TP Hồ Chí Minh'));
      expect(car.province, equals('Quận 1, TP Hồ Chí Minh'));
    });

    test('nên tự động ép kiểu linh hoạt khi id, pricePerDay hoặc distance là chuỗi số', () {
      final json = {
        'id': '77',
        'vehicleName': 'Kia Morning',
        'pricePerDay': '500000',
        'Distance': '3.2',
        'seatCount': '4',
      };

      final car = CarModel.fromJson(json);

      expect(car.id, equals('77'));
      expect(car.pricePerDay, equals(500000));
      expect(car.distanceKm, equals(3.2));
      expect(car.seats, equals(4));
    });
  });
}
