import 'dart:convert';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/profile/domain/entities/verification_entity.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

abstract class VerificationRemoteDataSource {
  Future<void> submitVerification(VerificationData data);
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final Dio dio;
  final UserLocalStorage userLocalStorage;

  VerificationRemoteDataSourceImpl(this.dio, this.userLocalStorage);

  String _fileNameOf(String path) {
    return path.split('/').last.split('\\').last;
  }

  MediaType _contentTypeOf(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    return MediaType('image', 'jpeg');
  }

  @override
  Future<void> submitVerification(VerificationData data) async {
    // 1. Metadata thông tin cá nhân & GPLX dưới dạng JSON part (application/json)
    final verificationJson = {
      'fullName': data.fullName,
      'dob': data.dob,
      'cccdNumber': data.cccdNumber,
      'address': data.address,
      'licenseNumber': data.licenseNumber,
      'licenseClass': data.licenseClass,
      'licenseIssueDate': data.licenseIssueDate,
      'licenseExpiryDate': data.licenseExpiryDate,
      'emergencyContactName': data.emergencyContactName,
      'emergencyContactPhone': data.emergencyContactPhone,
      'emergencyContactRelation': data.emergencyContactRelation,
      'hasAgreedTerms': data.hasAgreedTerms,
      'submittedAt': data.submittedAt?.toIso8601String(),
    };

    // 2. Gom toàn bộ file ảnh vào 1 List<MultipartFile> để gửi danh sách file lên Server
    final imagePaths = [
      if (data.cccdFrontImage != null && !data.cccdFrontImage!.startsWith('http')) data.cccdFrontImage!,
      if (data.cccdBackImage != null && !data.cccdBackImage!.startsWith('http')) data.cccdBackImage!,
      if (data.licenseFrontImage != null && !data.licenseFrontImage!.startsWith('http')) data.licenseFrontImage!,
      if (data.licenseBackImage != null && !data.licenseBackImage!.startsWith('http')) data.licenseBackImage!,
      if (data.selfieImage != null && !data.selfieImage!.startsWith('http')) data.selfieImage!,
    ];

    final formData = FormData();
    formData.files.add(
      MapEntry(
        'verification',
        MultipartFile.fromString(
          jsonEncode(verificationJson),
          contentType: MediaType('application', 'json'),
        ),
      ),
    );

    for (final path in imagePaths) {
      try {
        final file = await MultipartFile.fromFile(
          path,
          filename: _fileNameOf(path),
          contentType: _contentTypeOf(path),
        );
        formData.files.add(MapEntry('files', file));
      } catch (e) {
        debugPrint('[VerificationRemoteDataSource] Skip non-file image path: $path ($e)');
      }
    }

    try {
      final token = await userLocalStorage.getToken();
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('[VerificationRemoteDataSource] Submitting 1 single request to ${ApiConstants.verification} with 1 JSON part and ${formData.files.where((e) => e.key == 'files').length} image files in List "files"');
      final response = await dio.post(
        ApiConstants.verification,
        data: formData,
        options: options,
      );
      debugPrint('[VerificationRemoteDataSource] Response status: ${response.statusCode}');
    } catch (e) {
      debugPrint('[VerificationRemoteDataSource] Verification submission error: $e');
    }
  }
}
