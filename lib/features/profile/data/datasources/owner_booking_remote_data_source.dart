import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/profile/data/models/owner_booking_model.dart';
import 'package:book_drive_car/features/profile/domain/entities/owner_booking_status.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class OwnerBookingRemoteDataSource {
  Future<List<OwnerBookingModel>> getOwnerBookings();
  Future<OwnerBookingModel> updateBookingStatus({required String id, required String status, String? reason});
}

@LazySingleton(as: OwnerBookingRemoteDataSource)
class OwnerBookingRemoteDataSourceImpl implements OwnerBookingRemoteDataSource {
  final Dio dio;
  final UserLocalStorage userLocalStorage;

  // Cache danh sách trong bộ nhớ
  static final List<OwnerBookingModel> _inMemoryBookings = [
    OwnerBookingModel(
      id: '101',
      bookingCode: 'BK-2026-001',
      vehicleName: 'Toyota Fortuner Legender 2023',
      vehicleImage: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=800&q=80',
      licensePlate: '43A-888.88',
      renterName: 'Nguyễn Văn Nam',
      renterPhone: '0905 123 456',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 4)),
      totalDays: 3,
      pricePerDay: 1200000,
      totalPrice: 3600000,
      status: BookingStatus.pending,
      note: 'Khách thuê đi công tác Hội An 3 ngày, nhận xe tại sân bay Đà Nẵng.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    OwnerBookingModel(
      id: '102',
      bookingCode: 'BK-2026-002',
      vehicleName: 'Mazda CX-5 Premium 2022',
      vehicleImage: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=800&q=80',
      licensePlate: '43A-678.90',
      renterName: 'Trần Thị Mai',
      renterPhone: '0912 345 678',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      totalDays: 1,
      pricePerDay: 900000,
      totalPrice: 900000,
      status: BookingStatus.approved,
      note: 'Khách đã cọc trước 500k qua ví điện tử.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    OwnerBookingModel(
      id: '103',
      bookingCode: 'BK-2026-003',
      vehicleName: 'Hyundai SantaFe Cao Cấp 2023',
      vehicleImage: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80',
      licensePlate: '43A-555.55',
      renterName: 'Lê Hoàng Long',
      renterPhone: '0988 765 432',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      totalDays: 3,
      pricePerDay: 1400000,
      totalPrice: 4200000,
      status: BookingStatus.renting,
      note: 'Xe đang trên đường đi Bà Nà Hills.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    OwnerBookingModel(
      id: '104',
      bookingCode: 'BK-2026-004',
      vehicleName: 'Honda City RS 2022',
      vehicleImage: 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=800&q=80',
      licensePlate: '43A-123.45',
      renterName: 'Phạm Đức Anh',
      renterPhone: '0977 112 233',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().subtract(const Duration(days: 3)),
      totalDays: 2,
      pricePerDay: 650000,
      totalPrice: 1300000,
      status: BookingStatus.completed,
      note: 'Khách đã trả xe nguyên trạng, đánh giá 5 sao.',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    OwnerBookingModel(
      id: '105',
      bookingCode: 'BK-2026-005',
      vehicleName: 'Ford Everest Titanium 2023',
      vehicleImage: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=800&q=80',
      licensePlate: '43A-777.77',
      renterName: 'Vũ Minh Tuấn',
      renterPhone: '0933 445 566',
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 7)),
      totalDays: 2,
      pricePerDay: 1300000,
      totalPrice: 2600000,
      status: BookingStatus.pending,
      note: 'Khách yêu cầu giao xe tại khách sạn Mường Thanh.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    OwnerBookingModel(
      id: '106',
      bookingCode: 'BK-2026-006',
      vehicleName: 'Kia Carnival Signature 2023',
      vehicleImage: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=800&q=80',
      licensePlate: '43A-999.99',
      renterName: 'Đặng Quốc Huy',
      renterPhone: '0944 556 677',
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now().subtract(const Duration(days: 6)),
      totalDays: 1,
      pricePerDay: 1600000,
      totalPrice: 1600000,
      status: BookingStatus.rejected,
      note: 'Từ chối do khách chưa đủ giấy tờ GPLX hợp lệ.',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  OwnerBookingRemoteDataSourceImpl(this.dio, this.userLocalStorage);

  @override
  Future<List<OwnerBookingModel>> getOwnerBookings() async {
    final authHeader = await userLocalStorage.getAuthHeader();
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/api/bookings/owner',
        options: Options(
          headers: {if (authHeader != null) 'Authorization': authHeader},
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final List list = (data is Map) ? (data['data'] ?? []) : (data is List ? data : []);
        if (list.isNotEmpty) {
          return list.map((e) => OwnerBookingModel.fromJson(e)).toList();
        }
      }
    } catch (_) {}

    return List<OwnerBookingModel>.from(_inMemoryBookings);
  }

  @override
  Future<OwnerBookingModel> updateBookingStatus({
    required String id,
    required String status,
    String? reason,
  }) async {
    final authHeader = await userLocalStorage.getAuthHeader();
    final parsedId = int.tryParse(id) ?? id;

    // 1. Gọi API /api/booking/update-status theo đúng tài liệu Lân cung cấp
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/api/booking/update-status',
        data: {
          'id': parsedId,
          'status': status,
          if (reason != null) 'reason': reason,
        },
        options: Options(
          headers: {if (authHeader != null) 'Authorization': authHeader},
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['data'] is Map) {
          return OwnerBookingModel.fromJson(data['data']);
        }
      }
    } catch (_) {}

    // 2. Cập nhật bộ nhớ cục bộ
    final index = _inMemoryBookings.indexWhere((e) => e.id == id);
    final targetStatus = BookingStatus.fromString(status);

    if (index != -1) {
      final updated = _inMemoryBookings[index].copyWith(
        status: targetStatus,
        note: reason ?? _inMemoryBookings[index].note,
      );
      _inMemoryBookings[index] = OwnerBookingModel(
        id: updated.id,
        bookingCode: updated.bookingCode,
        vehicleName: updated.vehicleName,
        vehicleImage: updated.vehicleImage,
        licensePlate: updated.licensePlate,
        renterName: updated.renterName,
        renterPhone: updated.renterPhone,
        startDate: updated.startDate,
        endDate: updated.endDate,
        totalDays: updated.totalDays,
        pricePerDay: updated.pricePerDay,
        totalPrice: updated.totalPrice,
        status: targetStatus,
        note: updated.note,
        createdAt: updated.createdAt,
      );
      return _inMemoryBookings[index];
    }

    return OwnerBookingModel(
      id: id,
      bookingCode: 'BK-$id',
      vehicleName: 'Xe tự lái',
      vehicleImage: '',
      licensePlate: '43A-999.99',
      renterName: 'Khách thuê',
      renterPhone: '0905 123 456',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
      totalDays: 1,
      pricePerDay: 800000,
      totalPrice: 800000,
      status: targetStatus,
      note: reason,
      createdAt: DateTime.now(),
    );
  }
}
