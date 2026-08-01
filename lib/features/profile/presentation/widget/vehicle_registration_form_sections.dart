import 'dart:typed_data';

import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/profile/presentation/widget/province_open_api_location_picker.dart';
import 'package:book_drive_car/features/profile/presentation/widget/vehicle_registration_widgets.dart';
import 'package:book_drive_car/shared/services/car_query/model/car_make.dart';
import 'package:book_drive_car/shared/services/car_query/model/car_model.dart';
import 'package:book_drive_car/shared/services/car_query/model/car_trim.dart';
import 'package:flutter/material.dart';

class VehicleRegistrationPhotoItem {
  final String title;
  final String subtitle;
  final String illustrationAsset;
  final bool flipIllustrationHorizontally;
  final Uint8List? previewBytes;
  final VoidCallback onTap;

  const VehicleRegistrationPhotoItem({
    required this.title,
    required this.subtitle,
    required this.illustrationAsset,
    required this.flipIllustrationHorizontally,
    required this.previewBytes,
    required this.onTap,
  });
}

class VehicleRegistrationStepOne extends StatelessWidget {
  final TextEditingController colorController;
  final TextEditingController licensePlateController;
  final TextEditingController descriptionController;
  final TextEditingController seatCountController;
  final TextEditingController detailAddressController;
  final List<CarMake> makes;
  final List<CarModel> models;
  final List<CarTrim> trims;
  final CarMake? selectedMake;
  final CarModel? selectedModel;
  final CarTrim? selectedTrim;
  final int? selectedYear;
  final String? selectedFuelType;
  final String? selectedTransmission;
  final String? selectedProvince;
  final String? selectedDistrict;
  final String? selectedWard;
  final bool isLoadingMakes;
  final bool isLoadingModels;
  final bool isLoadingTrims;
  final List<int> yearOptions;
  final String? Function(String?) requiredValidator;
  final String? Function(dynamic value, String label, String? emptyHint)
  dropdownValidator;
  final VoidCallback onPickMake;
  final VoidCallback onPickModel;
  final VoidCallback onPickTrim;
  final VoidCallback onPickYear;
  final ValueChanged<String?> onProvinceChanged;
  final ValueChanged<String?> onDistrictChanged;
  final ValueChanged<String?> onWardChanged;
  final VoidCallback onToggleFuelPetrol;
  final VoidCallback onToggleFuelDiesel;
  final VoidCallback onToggleTransmissionManual;
  final VoidCallback onToggleTransmissionAutomatic;

  const VehicleRegistrationStepOne({
    super.key,
    required this.colorController,
    required this.licensePlateController,
    required this.descriptionController,
    required this.seatCountController,
    required this.detailAddressController,
    required this.makes,
    required this.models,
    required this.trims,
    required this.selectedMake,
    required this.selectedModel,
    required this.selectedTrim,
    required this.selectedYear,
    required this.selectedFuelType,
    required this.selectedTransmission,
    required this.selectedProvince,
    required this.selectedDistrict,
    required this.selectedWard,
    required this.isLoadingMakes,
    required this.isLoadingModels,
    required this.isLoadingTrims,
    required this.yearOptions,
    required this.requiredValidator,
    required this.dropdownValidator,
    required this.onPickMake,
    required this.onPickModel,
    required this.onPickTrim,
    required this.onPickYear,
    required this.onProvinceChanged,
    required this.onDistrictChanged,
    required this.onWardChanged,
    required this.onToggleFuelPetrol,
    required this.onToggleFuelDiesel,
    required this.onToggleTransmissionManual,
    required this.onToggleTransmissionAutomatic,
  });

  @override
  Widget build(BuildContext context) {
    final selectionFields = [
      VehicleRegistrationLabeledField(
        label: 'Hãng xe',
        child: VehicleRegistrationBottomSheetSelectorField<CarMake>(
          value: selectedMake,
          hintText: isLoadingMakes ? 'Đang tải hãng xe...' : 'Chọn hãng xe',
          enabled: !isLoadingMakes && makes.isNotEmpty,
          onTap: onPickMake,
          displayBuilder: (value) => value?.name ?? '',
          validator: (value) {
            if (isLoadingMakes) return 'Đang tải hãng xe...';
            if (makes.isEmpty) return 'Chưa tải được danh sách hãng xe';
            if (value == null) return 'Hãng xe không được để trống';
            return null;
          },
        ),
      ),
      VehicleRegistrationLabeledField(
        label: 'Dòng xe',
        child: VehicleRegistrationBottomSheetSelectorField<CarModel>(
          value: selectedModel,
          hintText: selectedMake == null
              ? 'Chọn hãng xe trước'
              : isLoadingModels
              ? 'Đang tải dòng xe...'
              : 'Chọn dòng xe',
          enabled:
              selectedMake != null && !isLoadingModels && models.isNotEmpty,
          onTap: onPickModel,
          displayBuilder: (value) => value?.name ?? '',
          validator: (value) {
            if (selectedMake == null) return 'Hãy chọn hãng xe trước';
            if (isLoadingModels) return 'Đang tải dòng xe...';
            if (models.isEmpty) return 'Chưa tải được danh sách dòng xe';
            if (value == null) return 'Dòng xe không được để trống';
            return null;
          },
        ),
      ),
      VehicleRegistrationLabeledField(
        label: 'Phiên bản xe',
        child: VehicleRegistrationBottomSheetSelectorField<CarTrim>(
          value: selectedTrim,
          hintText: selectedModel == null
              ? 'Chọn dòng xe trước'
              : isLoadingTrims
              ? 'Đang tải phiên bản xe...'
              : 'Chọn phiên bản xe',
          enabled: selectedModel != null && !isLoadingTrims && trims.isNotEmpty,
          onTap: onPickTrim,
          displayBuilder: (value) => [
            if (value?.year != null) '${value?.year}',
            if ((value?.name ?? '').trim().isNotEmpty) value!.name,
          ].join(' - '),
          validator: (value) {
            if (selectedModel == null) return 'Hãy chọn dòng xe trước';
            if (isLoadingTrims) return 'Đang tải phiên bản xe...';
            if (trims.isEmpty) return 'Chưa tải được danh sách phiên bản xe';
            if (value == null) return 'Phiên bản xe không được để trống';
            return null;
          },
        ),
      ),
      VehicleRegistrationLabeledField(
        label: 'Năm sản xuất',
        child: VehicleRegistrationBottomSheetSelectorField<int>(
          value: selectedYear,
          hintText: yearOptions.isEmpty
              ? 'Chưa có dữ liệu năm sản xuất'
              : 'Chọn năm sản xuất',
          enabled: yearOptions.isNotEmpty,
          onTap: onPickYear,
          displayBuilder: (value) => value?.toString() ?? '',
          validator: (value) => dropdownValidator(
            value,
            'Năm sản xuất',
            yearOptions.isEmpty ? 'Chưa có dữ liệu năm sản xuất' : null,
          ),
        ),
      ),
      VehicleRegistrationLabeledField(
        label: 'Số chỗ',
        controller: seatCountController,
        hintText: 'Nhập số chỗ',
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Số chỗ không được để trống';
          }
          if (int.tryParse(value.trim()) == null) {
            return 'Số chỗ phải là số';
          }
          return null;
        },
      ),
      VehicleRegistrationBinaryChoiceGroup(
        label: 'Nhiên liệu',
        firstLabel: 'Xăng',
        secondLabel: 'Dầu',
        firstSelected: selectedFuelType == 'Xăng',
        secondSelected: selectedFuelType == 'Dầu',
        onFirstTap: onToggleFuelPetrol,
        onSecondTap: onToggleFuelDiesel,
      ),
      VehicleRegistrationBinaryChoiceGroup(
        label: 'Hộp số',
        firstLabel: 'Số sàn',
        secondLabel: 'Số tự động',
        firstSelected: selectedTransmission == 'Số sàn',
        secondSelected: selectedTransmission == 'Số tự động',
        onFirstTap: onToggleTransmissionManual,
        onSecondTap: onToggleTransmissionAutomatic,
      ),
      VehicleRegistrationLabeledField(
        label: 'Màu xe',
        controller: colorController,
        hintText: 'Nhập màu xe',
        validator: requiredValidator,
      ),
      VehicleRegistrationLabeledField(
        label: 'Biển số xe',
        controller: licensePlateController,
        hintText: 'Nhập biển số',
        validator: requiredValidator,
      ),
      VehicleRegistrationLabeledField(
        label: 'Mô tả xe',
        controller: descriptionController,
        hintText: 'Nhập mô tả ngắn về xe',
        maxLines: 4,
        validator: requiredValidator,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VehicleRegistrationSectionTitle(
          title: 'Thông tin xe',
          subtitle: 'Bước 1: Nhập thông tin cơ bản và vị trí xe.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            if (isWide) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: selectionFields
                    .map(
                      (child) => SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: child,
                      ),
                    )
                    .toList(),
              );
            }

            return Column(
              children: [
                for (final child in selectionFields) ...[
                  child,
                  const SizedBox(height: 14),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        const VehicleRegistrationSectionTitle(
          title: 'Vị trí xe',
          subtitle: 'Chọn nơi xe đang đậu hoặc nơi chủ xe muốn nhận khách.',
        ),
        const SizedBox(height: 12),
        ProvinceOpenApiLocationPicker(
          provinceName: selectedProvince,
          districtName: selectedDistrict,
          wardName: selectedWard,
          onProvinceChanged: onProvinceChanged,
          onDistrictChanged: onDistrictChanged,
          onWardChanged: onWardChanged,
        ),
        const SizedBox(height: 14),
        VehicleRegistrationLabeledField(
          label: 'Vị trí chi tiết',
          controller: detailAddressController,
          hintText: 'Số nhà, ngõ, đường, tòa nhà...',
          validator: requiredValidator,
        ),
      ],
    );
  }
}

class VehicleRegistrationStepTwo extends StatelessWidget {
  final List<VehicleRegistrationPhotoItem> photos;

  const VehicleRegistrationStepTwo({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VehicleRegistrationSectionTitle(
          title: 'Chụp ảnh xe',
          subtitle: 'Bước 2: Tải đủ 4 ảnh mặt trước, sau, trái và phải.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final tileWidth = isWide
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            final rendered = photos
                .map(
                  (photo) => SizedBox(
                    width: tileWidth,
                    child: VehicleRegistrationPhotoTile(
                      title: photo.title,
                      subtitle: photo.subtitle,
                      illustrationAsset: photo.illustrationAsset,
                      flipIllustrationHorizontally:
                          photo.flipIllustrationHorizontally,
                      previewBytes: photo.previewBytes,
                      onTap: photo.onTap,
                    ),
                  ),
                )
                .toList();
            if (isWide) {
              return Wrap(spacing: 12, runSpacing: 12, children: rendered);
            }
            return Column(
              children: [
                for (final child in rendered) ...[
                  child,
                  const SizedBox(height: 14),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class VehicleRegistrationStepThree extends StatelessWidget {
  final Uint8List? documentPreviewBytes;
  final String? documentFileName;
  final VoidCallback onTap;

  const VehicleRegistrationStepThree({
    super.key,
    required this.documentPreviewBytes,
    required this.documentFileName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VehicleRegistrationSectionTitle(
          title: 'Giấy tờ xe',
          subtitle: 'Bước 3: Tải ảnh giấy tờ xe thật rõ để xác thực.',
        ),
        const SizedBox(height: 16),
        VehicleRegistrationDocumentUploadCard(
          title: 'Tải ảnh giấy tờ xe',
          subtitle:
              'Có thể dùng giấy đăng ký xe, cavet hoặc giấy tờ tương đương.',
          previewBytes: documentPreviewBytes,
          fileName: documentFileName,
          onTap: onTap,
        ),
      ],
    );
  }
}

class VehicleRegistrationStepFour extends StatelessWidget {
  final TextEditingController priceController;
  final String formattedPrice;
  final String? Function(String?) requiredValidator;
  final ValueChanged<String> onChanged;

  const VehicleRegistrationStepFour({
    super.key,
    required this.priceController,
    required this.formattedPrice,
    required this.requiredValidator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VehicleRegistrationSectionTitle(
          title: 'Giá thuê',
          subtitle: 'Bước 4: Nhập mức giá mong muốn theo ngày.',
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mức giá hiển thị',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$formattedPrice VNĐ / ngày',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Bạn có thể chỉnh lại trước khi lưu.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        VehicleRegistrationPriceCard(
          controller: priceController,
          validator: requiredValidator,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class VehicleRegistrationSubmittingOverlay extends StatelessWidget {
  const VehicleRegistrationSubmittingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          const ModalBarrier(dismissible: false, color: Colors.black26),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.6),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Đang gửi dữ liệu lên server...',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Vui lòng chờ trong giây lát',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
