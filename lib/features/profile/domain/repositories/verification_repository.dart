import '../entities/verification_entity.dart';

abstract class VerificationRepository {
  Future<VerificationData> getVerificationData();
  Future<void> saveVerificationData(VerificationData data);
  Future<void> updateStatus(VerificationStatus status, {String? rejectionReason});
  Future<VerificationStatus?> fetchRemoteVerificationStatus();
  Future<void> submitVerification(VerificationData data);
  Future<VerificationData> syncVerification();
}

