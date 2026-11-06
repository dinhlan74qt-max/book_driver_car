import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/home/domain/repositories/booking_repository.dart';
import 'package:book_drive_car/features/profile/data/datasources/verification_local_datasource.dart';
import 'package:book_drive_car/features/profile/data/datasources/verification_remote_data_source.dart';
import 'package:book_drive_car/features/profile/domain/entities/verification_entity.dart';
import 'package:book_drive_car/features/profile/domain/repositories/verification_repository.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: VerificationRepository)
class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationLocalDataSource localDataSource;
  final VerificationRemoteDataSource remoteDataSource;
  final Dio dio;
  final UserLocalStorage userLocalStorage;
  final BookingRepository bookingRepository;

  VerificationRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.dio,
    required this.userLocalStorage,
    required this.bookingRepository,
  });

  @override
  Future<VerificationData> getVerificationData() {
    return localDataSource.getVerificationData();
  }

  @override
  Future<void> saveVerificationData(VerificationData data) {
    return localDataSource.saveVerificationData(data);
  }

  @override
  Future<void> updateStatus(VerificationStatus status, {String? rejectionReason}) {
    return localDataSource.updateStatus(status, rejectionReason: rejectionReason);
  }

  @override
  Future<void> submitVerification(VerificationData data) {
    return remoteDataSource.submitVerification(data);
  }

  @override
  Future<VerificationStatus?> fetchRemoteVerificationStatus() async {
    try {
      final token = await userLocalStorage.getToken();
      final response = await dio.get(
        ApiConstants.verificationStatus,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
          validateStatus: (code) => code != null && code < 500,
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final raw = data is Map ? (data['data'] ?? data['status'] ?? data) : data;
        final statusStr = raw is String ? raw : (raw is Map ? raw['status'] : null);
        if (statusStr != null) {
          return VerificationStatus.fromString(statusStr.toString());
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<VerificationData> syncVerification() async {
    final current = await localDataSource.getVerificationData();
    VerificationData vData = current;

    try {
      final serverStatus = await fetchRemoteVerificationStatus();
      if (serverStatus != null && serverStatus != current.status) {
        vData = current.copyWith(status: serverStatus);
        await localDataSource.saveVerificationData(vData);
      }
    } catch (_) {
      try {
        final serverUser = await bookingRepository.checkVerified();
        vData = current.copyWith(
          status: VerificationStatus.verified,
          fullName: serverUser.fullname,
          cccdNumber: serverUser.cccd ?? current.cccdNumber,
          address: serverUser.addressText.isNotEmpty
              ? serverUser.addressText
              : current.address,
        );
        await localDataSource.saveVerificationData(vData);
      } catch (_) {
        // Retain local state
      }
    }

    return vData;
  }
}

