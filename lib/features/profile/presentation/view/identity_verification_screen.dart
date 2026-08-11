import 'dart:io';
import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/profile/data/datasources/verification_local_datasource.dart';
import 'package:book_drive_car/features/profile/data/datasources/verification_remote_data_source.dart';
import 'package:book_drive_car/features/profile/domain/entities/verification_entity.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  // Controllers - Step 2: ID Photos (Simulated paths)
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
        final now = DateTime.now();
        int age = now.year - birthDate.year;
        if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }
        setState(() {
          if (age < 18) {
            _ageWarning = 'Cảnh báo: Bạn chưa đủ 18 tuổi ($age tuổi). Chưa đủ điều kiện lái xe!';
          } else if (age < 21) {
            _ageWarning = 'Lưu ý: Bạn $age tuổi. Một số xe dung tích lớn yêu cầu từ 21 tuổi trở lên.';
          } else {
            _ageWarning = null;
          }
        });
      }
    } catch (_) {}
  }

  void _validateLicenseExpiry(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final expiry = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        final now = DateTime.now();
        setState(() {
          if (expiry.isBefore(now)) {
            _licenseWarning = 'Cảnh báo: Giấy phép lái xe của bạn ĐÃ HẾT HẠN!';
          } else if (expiry.difference(now).inDays < 60) {
            _licenseWarning = 'Lưu ý: Giấy phép lái xe sắp hết hạn trong vòng 60 ngày tới.';
          } else {
            _licenseWarning = null;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _pickDate(TextEditingController controller, {bool isDob = false, bool isExpiry = false}) async {
    final now = DateTime.now();
    final initialDate = isDob
        ? DateTime(2000, 1, 1)
        : (isExpiry ? DateTime(now.year + 5, 1, 1) : DateTime(2020, 1, 1));
    final firstDate = isDob ? DateTime(1940) : DateTime(2000);
    final lastDate = isDob ? now : DateTime(now.year + 30);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = DateFormat('dd/MM/yyyy').format(picked);
      controller.text = formatted;
      if (isDob) _calculateAge(formatted);
      if (isExpiry) _validateLicenseExpiry(formatted);
    }
  }

  bool _isStepValid(int step) {
    switch (step) {
      case 0:
        return _fullNameController.text.trim().isNotEmpty &&
            _dobController.text.trim().isNotEmpty &&
            _cccdController.text.trim().isNotEmpty &&
            _addressController.text.trim().isNotEmpty;
      case 1:
        return _cccdFrontImage != null && _cccdBackImage != null;
      case 2:
        return _licenseNumberController.text.trim().isNotEmpty &&
            _licenseExpiryDateController.text.trim().isNotEmpty &&
            _licenseFrontImage != null &&
            _licenseBackImage != null;
      case 3:
        return _selfieImage != null;
      case 4:
        return _emergencyNameController.text.trim().isNotEmpty &&
            _emergencyPhoneController.text.trim().isNotEmpty;
      case 5:
        return _hasAgreedTerms;
      default:
        return true;
    }
  }

  Future<void> _submitVerification() async {
    if (!_hasAgreedTerms) {
      AppToast.showError(context, 'Vui lòng tích chọn cam kết trước khi gửi hồ sơ!');
      return;
    }

    setState(() => _isSubmitting = true);

    final data = VerificationData(
      status: VerificationStatus.pending,
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
      hasAgreedTerms: true,
      submittedAt: DateTime.now(),
      rejectionReason: null,
    );

    await sl<VerificationLocalDataSource>().saveVerificationData(data);
    await sl<VerificationRemoteDataSource>().submitVerification(data);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    AppToast.showSuccess(context, 'Gửi hồ sơ xác minh thành công! Kết quả sẽ có trong 24h.');

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isRejected = widget.initialData?.status == VerificationStatus.rejected;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Xác minh danh tính (KYC)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Banner cảnh báo từ chối nếu nộp lại
          if (isRejected && widget.initialData?.rejectionReason != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.danger.withValues(alpha: 0.18),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Lý do từ chối trước đó: ${widget.initialData!.rejectionReason}',
                      style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // Stepper Header (6 Bước)
          Container(
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(6, (index) {
                  final isActive = index == _currentStep;
                  final isDone = index < _currentStep;
                  return Row(
                    children: [
                      TapScale(
                        onTap: () {
                          if (index <= _currentStep || _isStepValid(_currentStep)) {
                            setState(() => _currentStep = index);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : (isDone ? AppColors.primary.withValues(alpha: 0.2) : Colors.white10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive ? AppColors.primary : Colors.white24,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (isDone)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(Icons.check_rounded, color: AppColors.primary, size: 14),
                                ),
                              Text(
                                'B${index + 1}: ${_stepTitle(index)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                                  color: isActive ? Colors.white : (isDone ? AppColors.primary : Colors.white60),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (index < 5)
                        Container(
                          width: 16,
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          color: Colors.white24,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),

          // Nội dung từng bước
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: _buildStepContent(_currentStep),
            ),
          ),

          // Bottom Navigation Buttons
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

  String _stepTitle(int index) {
    switch (index) {
      case 0:
        return 'Cá nhân';
      case 1:
        return 'Ảnh CCCD';
      case 2:
        return 'GPLX';
      case 3:
        return 'Selfie';
      case 4:
        return 'Khẩn cấp';
      case 5:
        return 'Cam kết';
      default:
        return '';
    }
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildStep1BasicInfo();
      case 1:
        return _buildStep2CccdPhotos();
      case 2:
        return _buildStep3DriverLicense();
      case 3:
        return _buildStep4Selfie();
      case 4:
        return _buildStep5EmergencyContact();
      case 5:
        return _buildStep6Agreement();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── BƯỚC 1: Thông tin cá nhân ──────────────────────────────────────────────
  Widget _buildStep1BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Bước 1: Thông tin cá nhân cơ bản',
          subtitle: 'Vui lòng nhập chính xác họ tên và số CCCD khớp với giấy tờ.',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _fullNameController,
          label: 'Họ và tên đầy đủ',
          hint: 'Nguyễn Văn A',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _dobController,
          label: 'Ngày tháng năm sinh',
          hint: 'dd/mm/yyyy',
          icon: Icons.cake_outlined,
          readOnly: true,
          onTap: () => _pickDate(_dobController, isDob: true),
        ),
        if (_ageWarning != null) ...[
          const SizedBox(height: 8),
          _buildWarningBox(_ageWarning!, isError: _ageWarning!.contains('Chưa đủ điều kiện')),
        ],
        const SizedBox(height: 14),
        _buildTextField(
          controller: _cccdController,
          label: 'Số CCCD / CMND (12 chữ số)',
          hint: '048096001234',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _addressController,
          label: 'Địa chỉ thường trú / tạm trú',
          hint: '123 Trần Hưng Đạo, Hải Châu, Đà Nẵng',
          icon: Icons.location_on_outlined,
          maxLines: 2,
        ),
      ],
    );
  }

  Future<void> _chooseImage(Function(String path) onSelected) async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chọn nguồn hình ảnh', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Chụp từ Camera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Chọn từ Thư viện ảnh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_rounded, color: AppColors.headlightAmber),
              title: const Text('Dùng ảnh mẫu sẵn (Demo)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              onTap: () => Navigator.of(context).pop('DEMO'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    if (result == 'DEMO') {
      onSelected('https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600');
      return;
    }

    if (result is ImageSource) {
      try {
        final picker = ImagePicker();
        final XFile? file = await picker.pickImage(source: result, imageQuality: 80);
        if (file != null) {
          onSelected(file.path);
        }
      } catch (e) {
        debugPrint('Error picking image: $e');
      }
    }
  }

  // ── BƯỚC 2: Ảnh CCCD ───────────────────────────────────────────────────────
  Widget _buildStep2CccdPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Bước 2: Tải ảnh CCCD / CMND',
          subtitle: 'Chụp rõ nét 2 mặt giấy tờ căn cước công dân của bạn.',
        ),
        const SizedBox(height: 14),
        _buildInstructionBox(
          'Hướng dẫn chụp ảnh chuẩn:\n'
          '• Đặt giấy tờ vừa vặn trong khung viền hình ảnh.\n'
          '• Đảm bảo đủ ánh sáng, không chói lóa hay mờ chữ.\n'
          '• Không dùng ảnh chụp lại từ màn hình khác.',
        ),
        const SizedBox(height: 18),
        const Text('Ảnh mặt trước CCCD *', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _buildImagePickerBox(
          imagePath: _cccdFrontImage,
          label: 'Chụp / Chọn mặt trước CCCD',
          docIcon: Icons.badge_outlined,
          hint: 'Chụp rõ mặt trước CCCD gắn chip',
          onPick: () => _chooseImage((path) => setState(() => _cccdFrontImage = path)),
        ),
        const SizedBox(height: 18),
        const Text('Ảnh mặt sau CCCD *', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _buildImagePickerBox(
          imagePath: _cccdBackImage,
          label: 'Chụp / Chọn mặt sau CCCD',
          docIcon: Icons.fingerprint_rounded,
          hint: 'Chụp rõ mặt sau CCCD (phần chip & thông tin)',
          onPick: () => _chooseImage((path) => setState(() => _cccdBackImage = path)),
        ),
      ],
    );
  }

  // ── BƯỚC 3: Giấy phép lái xe ──────────────────────────────────────────────
  Widget _buildStep3DriverLicense() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Bước 3: Giấy phép lái xe (GPLX)',
          subtitle: 'Thông tin bằng lái xe ô tô để đảm bảo quyền lái xe an toàn.',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _licenseNumberController,
          label: 'Số Giấy phép lái xe',
          hint: '480123456789',
          icon: Icons.card_membership_rounded,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 14),
        const Text('Hạng bằng lái xe', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLicenseClass,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              items: _licenseClasses.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedLicenseClass = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _licenseIssueDateController,
                label: 'Ngày cấp',
                hint: 'dd/mm/yyyy',
                icon: Icons.calendar_today_rounded,
                readOnly: true,
                onTap: () => _pickDate(_licenseIssueDateController),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _licenseExpiryDateController,
                label: 'Ngày hết hạn',
                hint: 'dd/mm/yyyy',
                icon: Icons.event_busy_rounded,
                readOnly: true,
                onTap: () => _pickDate(_licenseExpiryDateController, isExpiry: true),
              ),
            ),
          ],
        ),
        if (_licenseWarning != null) ...[
          const SizedBox(height: 8),
          _buildWarningBox(_licenseWarning!, isError: _licenseWarning!.contains('ĐÃ HẾT HẠN')),
        ],
        const SizedBox(height: 18),
        const Text('Ảnh mặt trước GPLX *', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _buildImagePickerBox(
          imagePath: _licenseFrontImage,
          label: 'Tải ảnh mặt trước GPLX',
          docIcon: Icons.credit_card_rounded,
          hint: 'Chụp mặt trước Giấy phép lái xe ô tô',
          onPick: () => _chooseImage((path) => setState(() => _licenseFrontImage = path)),
        ),
        const SizedBox(height: 14),
        const Text('Ảnh mặt sau GPLX *', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _buildImagePickerBox(
          imagePath: _licenseBackImage,
          label: 'Tải ảnh mặt sau GPLX',
          docIcon: Icons.drive_eta_rounded,
          hint: 'Chụp mặt sau Giấy phép lái xe ô tô',
          onPick: () => _chooseImage((path) => setState(() => _licenseBackImage = path)),
        ),
      ],
    );
  }

  // ── BƯỚC 4: Chân dung (Selfie) ─────────────────────────────────────────────
  Widget _buildStep4Selfie() {
    Widget selfieDisplay;
    final hasSelfie = _selfieImage != null && _selfieImage!.isNotEmpty;

    if (!hasSelfie) {
      selfieDisplay = Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 80,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
          Positioned(
            right: 28,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else if (_selfieImage!.startsWith('http')) {
      selfieDisplay = Image.network(_selfieImage!, fit: BoxFit.cover);
    } else {
      selfieDisplay = Image.file(File(_selfieImage!), fit: BoxFit.cover);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Bước 4: Ảnh chân dung chính diện',
          subtitle: 'Chụp ảnh khuôn mặt để đối chiếu xác minh với CCCD.',
        ),
        const SizedBox(height: 14),
        _buildInstructionBox(
          'Yêu cầu chụp khuôn mặt:\n'
          '• Nhìn thẳng vào ống kính camera.\n'
          '• Không đeo kính râm, khẩu trang hoặc mũ che mặt.\n'
          '• Đảm bảo đủ ánh sáng rõ nét.',
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              TapScale(
                onTap: () => _chooseImage((path) {
                  setState(() => _selfieImage = path);
                  AppToast.showSuccess(context, 'Đã cập nhật ảnh chân dung!');
                }),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: hasSelfie ? 0.08 : 0.04),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasSelfie ? AppColors.primary : Colors.white24,
                      width: hasSelfie ? 2 : 1.2,
                    ),
                  ),
                  child: ClipOval(
                    child: selfieDisplay,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _chooseImage((path) {
                  setState(() => _selfieImage = path);
                  AppToast.showSuccess(context, 'Đã cập nhật ảnh chân dung!');
                }),
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(hasSelfie ? 'Chụp lại ảnh chân dung' : 'Chụp / Chọn ảnh chân dung'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── BƯỚC 5: Liên hệ khẩn cấp ─────────────────────────────────────────────
  Widget _buildStep5EmergencyContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Bước 5: Người liên hệ khẩn cấp',
          subtitle: 'Dùng để liên hệ trong các trường hợp cần hỗ trợ khẩn cấp.',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emergencyNameController,
          label: 'Họ tên người liên hệ khẩn cấp',
          hint: 'Nguyễn Văn B',
          icon: Icons.person_search_rounded,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _emergencyPhoneController,
          label: 'Số điện thoại liên hệ',
          hint: '0905123456',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 14),
        const Text('Mối quan hệ', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _emergencyRelation,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              items: _relations.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _emergencyRelation = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── BƯỚC 6: Cam kết điện tử ───────────────────────────────────────────────
  Widget _buildStep6Agreement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Bước 6: Cam kết & Xác nhận gửi',
          subtitle: 'Đọc kỹ thông tin cam kết pháp lý trước khi nộp hồ sơ.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'ĐIỀU KHOẢN CAM KẾT SỬ DỤNG DỊCH VỤ:',
                style: TextStyle(color: AppColors.headlightAmber, fontWeight: FontWeight.w800, fontSize: 13),
              ),
              SizedBox(height: 8),
              Text(
                '1. Tôi cam kết đầy đủ năng lực hành vi dân sự theo quy định pháp luật.\n'
                '2. Tuyệt đối không sử dụng rượu bia, chất kích thích khi vận hành xe thuê.\n'
                '3. Chịu toàn bộ trách nhiệm về giữ gìn và bảo quản tài sản xe trong suốt thời gian thuê.\n'
                '4. Thông tin và ảnh chụp giấy tờ nộp trên hoàn toàn là thật.',
                style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _hasAgreedTerms,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _hasAgreedTerms = val ?? false),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _hasAgreedTerms = !_hasAgreedTerms),
                child: const Text(
                  'Tôi đã đọc, hiểu rõ và đồng ý với tất cả cam kết điện tử trên.',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── WIDGET HELPER UI ───────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: (val) {
            onChanged?.call(val);
            if (mounted) setState(() {});
          },
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerBox({
    required String? imagePath,
    required String label,
    required VoidCallback onPick,
    IconData? docIcon,
    String? hint,
  }) {
    Widget displayWidget;
    final hasImage = imagePath != null && imagePath.isNotEmpty;

    if (!hasImage) {
      displayWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    docIcon ?? Icons.badge_outlined,
                    color: AppColors.primary.withValues(alpha: 0.85),
                    size: 26,
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hint ?? 'Nhấn để chụp hoặc tải ảnh lên',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.add_photo_alternate_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ],
        ),
      );
    } else {
      displayWidget = Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath.startsWith('http'))
            Image.network(imagePath, fit: BoxFit.cover)
          else
            Image.file(File(imagePath), fit: BoxFit.cover),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.edit_rounded, color: AppColors.primary, size: 12),
                  SizedBox(width: 4),
                  Text('Đổi ảnh', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return TapScale(
      onTap: onPick,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: hasImage ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? AppColors.primary : Colors.white24,
            width: hasImage ? 1.4 : 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: displayWidget,
        ),
      ),
    );
  }

  Widget _buildInstructionBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
    );
  }

  Widget _buildWarningBox(String text, {bool isError = false}) {
    final color = isError ? AppColors.danger : const Color(0xFFFFA000);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline_rounded : Icons.warning_amber_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.3)),
      ],
    );
  }
}
