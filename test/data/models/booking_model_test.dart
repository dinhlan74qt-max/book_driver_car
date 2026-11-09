import 'package:book_drive_car/features/home/data/models/booking_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookingModel - fromJson', () {
    test('nên deserialize thành công với JSON hợp lệ', () {
      final json = {
        'id': 105,
        'vehicleId': 28,
        'startDate': '2026-11-10T08:00:00.000Z',
        'endDate': '2026-11-12T18:00:00.000Z',
        'note': 'Nhận xe tại sân bay',
        'status': 'PENDING',
      };

      final booking = BookingModel.fromJson(json);

      expect(booking.id, equals(105));
      expect(booking.vehicleId, equals(28));
      expect(booking.startDate, equals(DateTime.parse('2026-11-10T08:00:00.000Z')));
      expect(booking.endDate, equals(DateTime.parse('2026-11-12T18:00:00.000Z')));
      expect(booking.note, equals('Nhận xe tại sân bay'));
      expect(booking.status, equals('PENDING'));
    });

    test('nên sử dụng các fallback khi các trường quan trọng bị null hoặc rỗng', () {
      final fallbackDate = DateTime(2026, 11, 8);
      final json = <String, dynamic>{
        'id': '99',
      };

      final booking = BookingModel.fromJson(
        json,
        fallbackVehicleId: 15,
        fallbackStartDate: fallbackDate,
        fallbackEndDate: fallbackDate.add(const Duration(days: 2)),
        fallbackNote: 'Ghi chú dự phòng',
        fallbackStatus: 'WAITING',
      );

      expect(booking.id, equals(99));
      expect(booking.vehicleId, equals(15));
      expect(booking.startDate, equals(fallbackDate));
      expect(booking.endDate, equals(fallbackDate.add(const Duration(days: 2))));
      expect(booking.note, equals('Ghi chú dự phòng'));
      expect(booking.status, equals('WAITING'));
    });

    test('nên ép kiểu an toàn khi id hoặc vehicleId là chuỗi ký tự', () {
      final json = {
        'id': '200',
        'vehicleId': '45',
        'startDate': '2026-12-01T00:00:00.000Z',
        'endDate': '2026-12-03T00:00:00.000Z',
        'status': 'CONFIRMED',
      };

      final booking = BookingModel.fromJson(json);

      expect(booking.id, equals(200));
      expect(booking.vehicleId, equals(45));
      expect(booking.status, equals('CONFIRMED'));
    });
  });
}
