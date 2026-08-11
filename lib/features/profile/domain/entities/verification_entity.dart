import 'package:flutter/material.dart';

enum VerificationStatus {
  unverified(
    'UNVERIFIED',
    'Chưa xác minh',
    Color(0xFFFFA000),
    Icons.warning_amber_rounded,
  ),
  pending(
    'PENDING',
    'Đang chờ duyệt',
    Color(0xFF1976D2),
    Icons.access_time_rounded,
  ),
  verified(
    'VERIFIED',
    'Đã xác minh',
    Color(0xFF388E3C),
    Icons.verified_rounded,
  ),
  rejected(
    'REJECTED',
    'Bị từ chối',
    Color(0xFFD32F2F),
    Icons.error_outline_rounded,
  ),
  expired(
    'EXPIRED',
    'GPLX hết hạn',
    Color(0xFFE65100),
    Icons.running_with_errors_rounded,
  );

  final String code;
  final String label;
  final Color color;
  final IconData icon;

  const VerificationStatus(this.code, this.label, this.color, this.icon);

  static VerificationStatus fromString(String? code) {
    return VerificationStatus.values.firstWhere(
      (e) => e.code == code?.toUpperCase(),
      orElse: () => VerificationStatus.unverified,
    );
  }
}

class VerificationData {
  final VerificationStatus status;
  final String? fullName;
  final String? dob;
  final String? cccdNumber;
  final String? address;
  final String? cccdFrontImage;
  final String? cccdBackImage;
  final String? licenseNumber;
  final String? licenseClass;
  final String? licenseIssueDate;
  final String? licenseExpiryDate;
  final String? licenseFrontImage;
  final String? licenseBackImage;
  final String? selfieImage;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final bool hasAgreedTerms;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;

  const VerificationData({
    this.status = VerificationStatus.unverified,
    this.fullName,
    this.dob,
    this.cccdNumber,
    this.address,
    this.cccdFrontImage,
    this.cccdBackImage,
    this.licenseNumber,
    this.licenseClass = 'B2',
    this.licenseIssueDate,
    this.licenseExpiryDate,
    this.licenseFrontImage,
    this.licenseBackImage,
    this.selfieImage,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation = 'Bố/Mẹ',
    this.hasAgreedTerms = false,
    this.rejectionReason,
    this.submittedAt,
    this.verifiedAt,
  });

  VerificationData copyWith({
    VerificationStatus? status,
    String? fullName,
    String? dob,
    String? cccdNumber,
    String? address,
    String? cccdFrontImage,
    String? cccdBackImage,
    String? licenseNumber,
    String? licenseClass,
    String? licenseIssueDate,
    String? licenseExpiryDate,
    String? licenseFrontImage,
    String? licenseBackImage,
    String? selfieImage,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    bool? hasAgreedTerms,
    String? rejectionReason,
    DateTime? submittedAt,
    DateTime? verifiedAt,
  }) {
    return VerificationData(
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      cccdNumber: cccdNumber ?? this.cccdNumber,
      address: address ?? this.address,
      cccdFrontImage: cccdFrontImage ?? this.cccdFrontImage,
      cccdBackImage: cccdBackImage ?? this.cccdBackImage,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseClass: licenseClass ?? this.licenseClass,
      licenseIssueDate: licenseIssueDate ?? this.licenseIssueDate,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      licenseFrontImage: licenseFrontImage ?? this.licenseFrontImage,
      licenseBackImage: licenseBackImage ?? this.licenseBackImage,
      selfieImage: selfieImage ?? this.selfieImage,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation:
          emergencyContactRelation ?? this.emergencyContactRelation,
      hasAgreedTerms: hasAgreedTerms ?? this.hasAgreedTerms,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.code,
      'fullName': fullName,
      'dob': dob,
      'cccdNumber': cccdNumber,
      'address': address,
      'cccdFrontImage': cccdFrontImage,
      'cccdBackImage': cccdBackImage,
      'licenseNumber': licenseNumber,
      'licenseClass': licenseClass,
      'licenseIssueDate': licenseIssueDate,
      'licenseExpiryDate': licenseExpiryDate,
      'licenseFrontImage': licenseFrontImage,
      'licenseBackImage': licenseBackImage,
      'selfieImage': selfieImage,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'emergencyContactRelation': emergencyContactRelation,
      'hasAgreedTerms': hasAgreedTerms,
      'rejectionReason': rejectionReason,
      'submittedAt': submittedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  factory VerificationData.fromJson(Map<String, dynamic> json) {
    return VerificationData(
      status: VerificationStatus.fromString(json['status'] as String?),
      fullName: json['fullName'] as String?,
      dob: json['dob'] as String?,
      cccdNumber: json['cccdNumber'] as String?,
      address: json['address'] as String?,
      cccdFrontImage: json['cccdFrontImage'] as String?,
      cccdBackImage: json['cccdBackImage'] as String?,
      licenseNumber: json['licenseNumber'] as String?,
      licenseClass: json['licenseClass'] as String? ?? 'B2',
      licenseIssueDate: json['licenseIssueDate'] as String?,
      licenseExpiryDate: json['licenseExpiryDate'] as String?,
      licenseFrontImage: json['licenseFrontImage'] as String?,
      licenseBackImage: json['licenseBackImage'] as String?,
      selfieImage: json['selfieImage'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      emergencyContactRelation:
          json['emergencyContactRelation'] as String? ?? 'Bố/Mẹ',
      hasAgreedTerms: json['hasAgreedTerms'] as bool? ?? false,
      rejectionReason: json['rejectionReason'] as String?,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'] as String)
          : null,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'] as String)
          : null,
    );
  }
}
