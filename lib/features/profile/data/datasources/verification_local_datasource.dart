import 'dart:convert';
import 'package:book_drive_car/features/profile/domain/entities/verification_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationLocalDataSource {
  static const String _keyVerificationData = 'user_verification_data_v1';

  Future<VerificationData> getVerificationData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyVerificationData);
    if (jsonStr == null || jsonStr.isEmpty) {
      return const VerificationData(status: VerificationStatus.unverified);
    }
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return VerificationData.fromJson(map);
    } catch (_) {
      return const VerificationData(status: VerificationStatus.unverified);
    }
  }

  Future<void> saveVerificationData(VerificationData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(data.toJson());
    await prefs.setString(_keyVerificationData, jsonStr);
  }

  Future<void> updateStatus(VerificationStatus status, {String? rejectionReason}) async {
    final current = await getVerificationData();
    final updated = current.copyWith(
      status: status,
      rejectionReason: rejectionReason,
      verifiedAt: status == VerificationStatus.verified ? DateTime.now() : current.verifiedAt,
    );
    await saveVerificationData(updated);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyVerificationData);
  }
}
