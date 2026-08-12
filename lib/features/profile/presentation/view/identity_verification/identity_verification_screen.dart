import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/profile/data/datasources/verification_local_datasource.dart';
import 'package:book_drive_car/features/profile/data/datasources/verification_remote_data_source.dart';
import 'package:book_drive_car/features/profile/domain/entities/verification_entity.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/widgets/step1_basic_info_section.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/widgets/step2_cccd_section.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/widgets/step3_driver_license_section.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/widgets/step4_selfie_section.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/widgets/step5_emergency_contact_section.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/widgets/step6_agreement_section.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/widgets/verification_image_picker_box.dart';
import 'package:book_drive_car/features/profile/presentation/view/identity_verification/widgets/verification_step_indicator.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IdentityVerificationScreen extends StatefulWidget {
  final VerificationData? initialData;

  const IdentityVerificationScreen({super.key, this.initialData});

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Controllers - Step 1: Basic Info
  late final TextEditingController _fullNameController;
  late final TextEditingController _dobController;
  late final TextEditingController _cccdController;
  late final TextEditingController _addressController;

  // Controllers - Step 2: ID Photos
  String? _cccdFrontImage;
  String? _cccdBackImage;

  // Controllers - Step 3: Driver License
  late final TextEditingController _licenseNumberController;
  late final TextEditingController _licenseIssueDateController;
  late final TextEditingController _licenseExpiryDateController;
  String _selectedLicenseClass = 'B2';
  String? _licenseFrontImage;
  String? _licenseBackImage;

  // Controllers - Step 4: Selfie
  String? _selfieImage;

  // Controllers - Step 5: Emergency Contact
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;
  String _emergencyRelation = 'Bố/Mẹ';

  // Step 6: Agreement
  bool _hasAgreedTerms = false;

  // Validations & Alerts
  String? _ageWarning;
  String? _licenseWarning;

  final List<String> _licenseClasses = const ['B1 (Tự động)', 'B1', 'B2', 'C', 'D', 'E', 'A1', 'A2'];
  final List<String> _relations = const ['Bố/Mẹ', 'Anh/Chị/Em', 'Vợ/Chồng', 'Bạn bè', 'Khác'];

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;

    _fullNameController = TextEditingController(text: d?.fullName ?? '');
    _dobController = TextEditingController(text: d?.dob ?? '');
    _cccdController = TextEditingController(text: d?.cccdNumber ?? '');
    _addressController = TextEditingController(text: d?.address ?? '');

    _cccdFrontImage = d?.cccdFrontImage;
    _cccdBackImage = d?.cccdBackImage;

    _licenseNumberController = TextEditingController(text: d?.licenseNumber ?? '');
    _licenseIssueDateController = TextEditingController(text: d?.licenseIssueDate ?? '');
    _licenseExpiryDateController = TextEditingController(text: d?.licenseExpiryDate ?? '15/12/2030');
    _selectedLicenseClass = d?.licenseClass ?? 'B2';

    _licenseFrontImage = d?.licenseFrontImage;
    _licenseBackImage = d?.licenseBackImage;

    _selfieImage = d?.selfieImage;

    _emergencyNameController = TextEditingController(text: d?.emergencyContactName ?? '');
    _emergencyPhoneController = TextEditingController(text: d?.emergencyContactPhone ?? '');
    _emergencyRelation = d?.emergencyContactRelation ?? 'Bố/Mẹ';

    _hasAgreedTerms = d?.hasAgreedTerms ?? false;

    _fullNameController.addListener(_onFieldChanged);
    _dobController.addListener(_onFieldChanged);
    _cccdController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _licenseNumberController.addListener(_onFieldChanged);
    _licenseIssueDateController.addListener(_onFieldChanged);
    _licenseExpiryDateController.addListener(_onFieldChanged);
    _emergencyNameController.addListener(_onFieldChanged);
    _emergencyPhoneController.addListener(_onFieldChanged);

    if (_dobController.text.isNotEmpty) {
      _calculateAge(_dobController.text);
    }
    if (_licenseExpiryDateController.text.isNotEmpty) {
      _validateLicenseExpiry(_licenseExpiryDateController.text);
    }
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_onFieldChanged);
    _dobController.removeListener(_onFieldChanged);
    _cccdController.removeListener(_onFieldChanged);
    _addressController.removeListener(_onFieldChanged);
    _licenseNumberController.removeListener(_onFieldChanged);
    _licenseIssueDateController.removeListener(_onFieldChanged);
    _licenseExpiryDateController.removeListener(_onFieldChanged);
    _emergencyNameController.removeListener(_onFieldChanged);
    _emergencyPhoneController.removeListener(_onFieldChanged);

    _fullNameController.dispose();
    _dobController.dispose();
    _cccdController.dispose();
    _addressController.dispose();
    _licenseNumberController.dispose();
    _licenseIssueDateController.dispose();
    _licenseExpiryDateController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _calculateAge(String dobStr) {
    try {
      final parts = dobStr.split('/');
      if (parts.length == 3) {
        final birthDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        final today = DateTime.now();
        int age = today.year - birthDate.year;
        if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }
        if (age < 21) {
          setState(() => _ageWarning = 'Cảnh báo: Bạn hiện $age tuổi (chưa đủ 21 tuổi để thuê xe tự lái).');
        } else {
          setState(() => _ageWarning = null);
        }
      }
    } catch (_) {
      setState(() => _ageWarning = null);
    }
  }

  void _validateLicenseExpiry(String expiryStr) {
    try {
      final parts = expiryStr.split('/');
      if (parts.length == 3) {
        final expiryDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        if (expiryDate.isBefore(DateTime.now())) {
          setState(() => _licenseWarning = 'Cảnh báo: GPLX của bạn đã hết hạn sử dụng.');
        } else {
          setState(() => _licenseWarning = null);
        }
      }
    } catch (_) {
      setState(() => _licenseWarning = null);
    }
  }

  bool _isStepValid(int step) {
    switch (step) {
      case 0:
        return _fullNameController.text.trim().isNotEmpty &&
            _dobController.text.trim().isNotEmpty &&
            _cccdController.text.trim().length >= 9 &&
            _addressController.text.trim().isNotEmpty;
      case 1:
        return _cccdFrontImage != null &&
            _cccdFrontImage!.isNotEmpty &&
            _cccdBackImage != null &&
            _cccdBackImage!.isNotEmpty;
      case 2:
        return _licenseNumberController.text.trim().isNotEmpty &&
            _licenseIssueDateController.text.trim().isNotEmpty &&
            _licenseExpiryDateController.text.trim().isNotEmpty &&
            _licenseFrontImage != null &&
            _licenseFrontImage!.isNotEmpty &&
            _licenseBackImage != null &&
            _licenseBackImage!.isNotEmpty;
      case 3:
        return _selfieImage != null && _selfieImage!.isNotEmpty;
      case 4:
        return _emergencyNameController.text.trim().isNotEmpty &&
            _emergencyPhoneController.text.trim().length >= 10;
      case 5:
        return _hasAgreedTerms;
      default:
        return false;
    }
  }

  Future<void> _selectDate(TextEditingController controller, {bool isDob = false}) async {
    final now = DateTime.now();
    final initialDate = isDob ? DateTime(2000, 1, 1) : now;
    final firstDate = isDob ? DateTime(1940) : DateTime(2000);
    final lastDate = isDob ? now : DateTime(2045);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      final formatted = DateFormat('dd/MM/yyyy').format(picked);
      controller.text = formatted;
      if (isDob) _calculateAge(formatted);
      if (!isDob && controller == _licenseExpiryDateController) _validateLicenseExpiry(formatted);
    }
  }

  Future<void> _chooseImage(Function(String path) onSelected) async {
    await VerificationImagePickerBox.showImagePickerSheet(
      context: context,
      onSelected: onSelected,
    );
  }

  Future<void> _submitVerification() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final data = VerificationData(
      fullName: _fullNameController.text.trim(),
      dob: _dobController.text.trim(),
      cccdNumber: _cccdController.text.trim(),
      address: _addressController.text.trim(),
      cccdFrontImage: _cccdFrontImage,
      cccdBackImage: _cccdBackImage,
      licenseNumber: _licenseNumberController.text.trim(),
      licenseClass: _selectedLicenseClass,
      licenseIssueDate: _licenseIssueDateController.text.trim(),
      licenseExpiryDate: _licenseExpiryDateController.text.trim(),
      licenseFrontImage: _licenseFrontImage,
      licenseBackImage: _licenseBackImage,
      selfieImage: _selfieImage,
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
      emergencyContactRelation: _emergencyRelation,
      hasAgreedTerms: _hasAgreedTerms,
      status: VerificationStatus.pending,
      submittedAt: DateTime.now(),
    );

    try {
      if (sl.isRegistered<VerificationRemoteDataSource>()) {
        await sl<VerificationRemoteDataSource>().submitVerification(data);
      }
    } catch (_) {}

    await sl<VerificationLocalDataSource>().saveVerificationData(data);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    AppToast.showSuccess(context, 'Hồ sơ xác minh đã được gửi thành công!');
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Xác thực danh tính (KYC)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Thanh tiến trình các bước ─────────────────────────────────────
          VerificationStepIndicator(
            currentStep: _currentStep,
            isStepValid: _isStepValid,
            onStepTapped: (step) => setState(() => _currentStep = step),
          ),

          // ── Nội dung từng bước ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: _buildStepContent(_currentStep),
            ),
          ),

          // ── Bottom Navigation Bar ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Quay lại'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: _currentStep < 5
                      ? ElevatedButton(
                          onPressed: _isStepValid(_currentStep)
                              ? () => setState(() => _currentStep++)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white10,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Tiếp theo', style: TextStyle(fontWeight: FontWeight.w800)),
                        )
                      : ElevatedButton(
                          onPressed: _isSubmitting || !_hasAgreedTerms ? null : _submitVerification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white10,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Gửi hồ sơ xác minh', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return Step1BasicInfoSection(
          fullNameController: _fullNameController,
          dobController: _dobController,
          cccdController: _cccdController,
          addressController: _addressController,
          ageWarning: _ageWarning,
          onSelectDob: () => _selectDate(_dobController, isDob: true),
        );
      case 1:
        return Step2CccdSection(
          cccdFrontImage: _cccdFrontImage,
          cccdBackImage: _cccdBackImage,
          onPickFront: () => _chooseImage((path) => setState(() => _cccdFrontImage = path)),
          onPickBack: () => _chooseImage((path) => setState(() => _cccdBackImage = path)),
        );
      case 2:
        return Step3DriverLicenseSection(
          licenseNumberController: _licenseNumberController,
          licenseIssueDateController: _licenseIssueDateController,
          licenseExpiryDateController: _licenseExpiryDateController,
          selectedLicenseClass: _selectedLicenseClass,
          licenseClasses: _licenseClasses,
          licenseWarning: _licenseWarning,
          licenseFrontImage: _licenseFrontImage,
          licenseBackImage: _licenseBackImage,
          onClassChanged: (val) => setState(() => _selectedLicenseClass = val ?? 'B2'),
          onSelectIssueDate: () => _selectDate(_licenseIssueDateController),
          onSelectExpiryDate: () => _selectDate(_licenseExpiryDateController),
          onPickFront: () => _chooseImage((path) => setState(() => _licenseFrontImage = path)),
          onPickBack: () => _chooseImage((path) => setState(() => _licenseBackImage = path)),
        );
      case 3:
        return Step4SelfieSection(
          selfieImage: _selfieImage,
          onPickSelfie: () => _chooseImage((path) {
            setState(() => _selfieImage = path);
            AppToast.showSuccess(context, 'Đã cập nhật ảnh chân dung!');
          }),
        );
      case 4:
        return Step5EmergencyContactSection(
          emergencyNameController: _emergencyNameController,
          emergencyPhoneController: _emergencyPhoneController,
          emergencyRelation: _emergencyRelation,
          relations: _relations,
          onRelationChanged: (val) => setState(() => _emergencyRelation = val ?? 'Bố/Mẹ'),
        );
      case 5:
        return Step6AgreementSection(
          fullName: _fullNameController.text.trim(),
          dob: _dobController.text.trim(),
          cccdNumber: _cccdController.text.trim(),
          address: _addressController.text.trim(),
          licenseNumber: _licenseNumberController.text.trim(),
          licenseClass: _selectedLicenseClass,
          emergencyName: _emergencyNameController.text.trim(),
          emergencyPhone: _emergencyPhoneController.text.trim(),
          emergencyRelation: _emergencyRelation,
          hasAgreedTerms: _hasAgreedTerms,
          onAgreementChanged: (val) => setState(() => _hasAgreedTerms = val ?? false),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
