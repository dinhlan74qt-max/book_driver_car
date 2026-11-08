import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/home/domain/repositories/booking_repository.dart';
import 'package:book_drive_car/features/profile/data/datasources/verification_local_datasource.dart';
import 'package:book_drive_car/features/profile/data/datasources/verification_remote_data_source.dart';
import 'package:book_drive_car/features/profile/domain/entities/verification_entity.dart';
import 'package:book_drive_car/features/profile/domain/repositories/verification_repository.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

  bool _isTrueOrOne(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is num) return val == 1;
    final s = val.toString().trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'verified' || s == 'approved';
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
      debugPrint('[fetchRemoteVerificationStatus] HTTP ${response.statusCode} data=${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is bool) {
          return data ? VerificationStatus.verified : null;
        }
        if (data is num) {
          if (data == 1) return VerificationStatus.verified;
          if (data == 0) return VerificationStatus.unverified;
        }
        if (data is Map) {
          if (_isTrueOrOne(data['isVerified']) ||
              _isTrueOrOne(data['isCccdVerified']) ||
              _isTrueOrOne(data['verified']) ||
              _isTrueOrOne(data['cccdVerified'])) {
            return VerificationStatus.verified;
          }
          final inner = data['data'];
          if (inner is bool) {
            return inner ? VerificationStatus.verified : null;
          }
          if (inner is num) {
            if (inner == 1) return VerificationStatus.verified;
            if (inner == 0) return VerificationStatus.unverified;
          }
          if (inner is Map) {
            if (_isTrueOrOne(inner['isVerified']) ||
                _isTrueOrOne(inner['isCccdVerified']) ||
                _isTrueOrOne(inner['verified']) ||
                _isTrueOrOne(inner['cccdVerified'])) {
              return VerificationStatus.verified;
            }
            final innerStatus = inner['status'] ?? inner['verificationStatus'];
            if (innerStatus != null) {
              return VerificationStatus.fromString(innerStatus.toString());
            }
          }
          final rawStatus = data['status'] ?? data['verificationStatus'];
          if (rawStatus != null && rawStatus is! int) {
            return VerificationStatus.fromString(rawStatus.toString());
          }
          if (rawStatus is int && rawStatus == 1) {
            return VerificationStatus.verified;
          }
        } else if (data is String) {
          final trimmed = data.trim().toLowerCase();
          if (trimmed.startsWith('<!doctype') ||
              trimmed.startsWith('<html') ||
              trimmed.contains('<form')) {
            debugPrint(
              '[fetchRemoteVerificationStatus] Server trả về HTML login page (token hết hạn hoặc redirect), bỏ qua không ghi đè trạng thái.',
            );
            return null;
          }
          if (trimmed == '1') return VerificationStatus.verified;
          if (trimmed == '0') return VerificationStatus.unverified;
          return VerificationStatus.fromString(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[fetchRemoteVerificationStatus] error=$e');
      return null;
    }
  }

  @override
  Future<VerificationData> syncVerification() async {
    final current = await localDataSource.getVerificationData();
    VerificationData vData = current;

    debugPrint('\n==================== [SYNC KYC STATUS] ====================');
    debugPrint('Current Local KYC Status: ${current.status}');

    // 1. Kiểm tra ưu tiên qua endpoint chính của Backend: /api/users/checkverified
    try {
      debugPrint('--> [1/2] Calling checkVerified (${ApiConstants.checkVerified})...');
      final serverUser = await bookingRepository.checkVerified();
      debugPrint('<-- checkVerified result: isCccdVerified=${serverUser.isCccdVerified}, fullname=${serverUser.fullname}, cccd=${serverUser.cccd}');
      if (serverUser.isCccdVerified) {
        vData = vData.copyWith(
          status: VerificationStatus.verified,
          fullName: serverUser.fullname.isNotEmpty ? serverUser.fullname : vData.fullName,
          cccdNumber: serverUser.cccd ?? vData.cccdNumber,
          address: serverUser.addressText.isNotEmpty ? serverUser.addressText : vData.address,
        );
        await localDataSource.saveVerificationData(vData);
        debugPrint('✅ KYC is VERIFIED according to /api/users/checkverified!');
        debugPrint('===========================================================\n');
        return vData;
      }
    } catch (e) {
      debugPrint('<-- checkVerified response/exception: $e');
    }

    // 2. Kiểm tra thêm qua endpoint /api/users/veri/status
    try {
      debugPrint('--> [2/2] Calling fetchRemoteVerificationStatus (${ApiConstants.verificationStatus})...');
      final serverStatus = await fetchRemoteVerificationStatus();
      debugPrint('<-- fetchRemoteVerificationStatus: $serverStatus');
      if (serverStatus != null) {
        vData = vData.copyWith(status: serverStatus);
        await localDataSource.saveVerificationData(vData);
        debugPrint('✅ Updated KYC status to $serverStatus from /api/users/veri/status');
      }
    } catch (e) {
      debugPrint('<-- fetchRemoteVerificationStatus error: $e');
    }

    debugPrint('Final Synced KYC Status: ${vData.status}');
    debugPrint('===========================================================\n');
    return vData;
  }
}

