import 'dart:io';
import 'dart:typed_data';

import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/helper/vehicle_price_formatter_helper.dart';
import 'package:book_drive_car/features/profile/domain/entities/address_entity.dart';
import 'package:book_drive_car/features/profile/domain/entities/add_vehicle_request_entity.dart';
import 'package:book_drive_car/features/profile/domain/entities/vehicle_entity.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/add_vehicle_bloc.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/add_vehicle_event.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/add_vehicle_state.dart';
import 'package:book_drive_car/features/profile/presentation/widget/vehicle_registration_form_sections.dart';
import 'package:book_drive_car/features/profile/presentation/widget/vehicle_registration_widgets.dart';
import 'package:book_drive_car/core/helper/validator_helper.dart';
import 'package:book_drive_car/core/helper/vehicle_media_picker_helper.dart';
import 'package:book_drive_car/shared/data/mock_data/car_query_services.dart';
import 'package:book_drive_car/shared/services/car_query/model/car_make.dart';
import 'package:book_drive_car/shared/services/car_query/model/car_model.dart';
import 'package:book_drive_car/shared/services/car_query/model/car_trim.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

enum _VehiclePhotoSlot { front, rear, left, right }

enum _VehicleMediaSource { gallery, camera }

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _carQueryService = CarQueryService();
  final _mediaPickerHelper = VehicleMediaPickerHelper();
  late final AddVehicleBloc _addVehicleBloc;

  final _colorController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _pricePerDayController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _seatCountController = TextEditingController();
  final _detailAddressController = TextEditingController();

  final List<CarMake> _makes = [];
  final List<CarModel> _models = [];
  final List<CarTrim> _trims = [];

  final Map<_VehiclePhotoSlot, VehiclePickedMedia> _vehiclePhotoPaths = {};
  VehiclePickedMedia? _vehicleDocument;

  int _currentStep = 0;
  bool _isLoadingMakes = false;
  bool _isLoadingModels = false;
  bool _isLoadingTrims = false;
  bool _isFormattingPrice = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  String _vehicleType = 'CAR';
  CarMake? _selectedMake;
  CarModel? _selectedModel;
  CarTrim? _selectedTrim;
  int? _selectedYear;
  String? _selectedFuelType;
  String? _selectedTransmission;
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  List<int> get _yearOptions =>
      _trims.map((trim) => trim.year).whereType<int>().toSet().toList()
        ..sort((a, b) => b.compareTo(a));

  @override
  void initState() {
    super.initState();
    _addVehicleBloc = sl<AddVehicleBloc>();
    _colorController.addListener(_onFormFieldChanged);
    _licensePlateController.addListener(_onFormFieldChanged);
    _descriptionController.addListener(_onFormFieldChanged);
    _seatCountController.addListener(_onFormFieldChanged);
    _detailAddressController.addListener(_onFormFieldChanged);
    _pricePerDayController.addListener(_onPriceChanged);
    _loadMakes();
  }

  @override
  void dispose() {
    _colorController.removeListener(_onFormFieldChanged);
    _licensePlateController.removeListener(_onFormFieldChanged);
    _descriptionController.removeListener(_onFormFieldChanged);
    _seatCountController.removeListener(_onFormFieldChanged);
    _detailAddressController.removeListener(_onFormFieldChanged);
    _pricePerDayController.removeListener(_onPriceChanged);
    _addVehicleBloc.close();
    _colorController.dispose();
    _licensePlateController.dispose();
    _pricePerDayController.dispose();
    _descriptionController.dispose();
    _seatCountController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  void _onFormFieldChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onPriceChanged() {
    if (_isFormattingPrice) {
      return;
    }

    final formatted = VehiclePriceFormatterHelper.formatPriceInput(
      _pricePerDayController.text,
    );
    if (formatted != _pricePerDayController.text) {
      _isFormattingPrice = true;
      _pricePerDayController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      _isFormattingPrice = false;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  bool get _isStepOneReady {
    return _selectedMake != null &&
        _selectedModel != null &&
        _selectedTrim != null &&
        _selectedYear != null &&
        _seatCountController.text.trim().isNotEmpty &&
        int.tryParse(_seatCountController.text.trim()) != null &&
        (_selectedFuelType?.trim().isNotEmpty ?? false) &&
        (_selectedTransmission?.trim().isNotEmpty ?? false) &&
        _colorController.text.trim().isNotEmpty &&
        _licensePlateController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _selectedProvince != null &&
        _selectedDistrict != null &&
        _selectedWard != null &&
        _detailAddressController.text.trim().isNotEmpty;
  }

  bool get _isStepTwoReady => _vehiclePhotoPaths.length >= 4;

  bool get _isStepThreeReady => _vehicleDocument != null;

  bool get _isStepFourReady {
    return VehiclePriceFormatterHelper.parsePriceInput(
          _pricePerDayController.text,
        ) !=
        null;
  }

  bool get _canProceedCurrentStep {
    switch (_currentStep) {
      case 0:
        return _isStepOneReady;
      case 1:
        return _isStepTwoReady;
      case 2:
        return _isStepThreeReady;
      case 3:
        return _isStepFourReady;
      default:
        return false;
    }
  }

  bool _validateStepOneAndShowErrors() {
    if (_selectedMake == null ||
        _selectedModel == null ||
        _selectedTrim == null ||
        _selectedYear == null ||
        _seatCountController.text.trim().isEmpty ||
        int.tryParse(_seatCountController.text.trim()) == null ||
        (_selectedFuelType?.trim().isEmpty ?? true) ||
        (_selectedTransmission?.trim().isEmpty ?? true) ||
        _colorController.text.trim().isEmpty ||
        _licensePlateController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _selectedProvince == null ||
        _selectedDistrict == null ||
        _selectedWard == null ||
        _detailAddressController.text.trim().isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập đầy đủ thông tin xe',
        type: AppToastType.warning,
      );
      return false;
    }

    if (!ValidatorHelper.validateLicensePlate(_licensePlateController.text)) {
      AppToast.show(
        context,
        message: 'Vui lòng điền biển số xe hợp lệ',
        type: AppToastType.warning,
      );
      return false;
    }

    return true;
  }

  Future<void> _loadMakes() async {
    setState(() {
      _isLoadingMakes = true;
      _errorMessage = null;
      _selectedMake = null;
      _selectedModel = null;
      _selectedTrim = null;
      _selectedYear = null;
      _selectedFuelType = null;
      _selectedTransmission = null;
      _models.clear();
      _trims.clear();
    });

    try {
      final makes = await _carQueryService.getMakes();
      if (!mounted) return;
      setState(() {
        _makes
          ..clear()
          ..addAll(makes);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không tải được danh sách hãng xe. Vui lòng thử lại.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingMakes = false);
      }
    }
  }

  Future<void> _loadModels(CarMake make) async {
    setState(() {
      _isLoadingModels = true;
      _errorMessage = null;
      _selectedModel = null;
      _selectedTrim = null;
      _selectedYear = null;
      _selectedFuelType = null;
      _selectedTransmission = null;
      _models.clear();
      _trims.clear();
    });

    try {
      final models = await _carQueryService.getModels(make);
      if (!mounted) return;
      setState(() {
        _models
          ..clear()
          ..addAll(models);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không tải được danh sách dòng xe. Vui lòng thử lại.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingModels = false);
      }
    }
  }

  Future<void> _loadTrims(CarMake make, CarModel model) async {
    setState(() {
      _isLoadingTrims = true;
      _errorMessage = null;
      _selectedTrim = null;
      _selectedYear = null;
      _selectedFuelType = null;
      _selectedTransmission = null;
      _trims.clear();
    });

    try {
      final trims = await _carQueryService.getTrims(make: make, model: model);
      if (!mounted) return;
      setState(() {
        _trims
          ..clear()
          ..addAll(trims);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Không tải được dữ liệu phiên bản xe. Vui lòng thử lại.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingTrims = false);
      }
    }
  }

  void _onMakeChanged(CarMake? make) {
    if (make == null) return;
    setState(() {
      _selectedMake = make;
      _selectedModel = null;
      _selectedTrim = null;
      _selectedYear = null;
      _selectedFuelType = null;
      _selectedTransmission = null;
      _models.clear();
      _trims.clear();
    });
    _loadModels(make);
  }

  void _onModelChanged(CarModel? model) {
    if (model == null || _selectedMake == null) return;
    setState(() {
      _selectedModel = model;
      _selectedTrim = null;
      _selectedYear = null;
      _selectedFuelType = null;
      _selectedTransmission = null;
      _trims.clear();
    });
    _loadTrims(_selectedMake!, model);
  }

  void _onTrimChanged(CarTrim? trim) {
    setState(() {
      _selectedTrim = trim;
      _selectedYear = trim?.year;
      _selectedFuelType = trim?.fuel;
      _selectedTransmission = trim?.transmission;
    });
  }

  void _setFuelType(String value) {
    setState(() {
      _selectedFuelType = _selectedFuelType == value ? null : value;
    });
  }

  void _setTransmission(String value) {
    setState(() {
      _selectedTransmission = _selectedTransmission == value ? null : value;
    });
  }

  Future<void> _pickVehiclePhoto(_VehiclePhotoSlot slot, String title) async {
    _hideKeyboard();
    final source = await _showPhotoSourceBottomSheet(title);
    if (!mounted || source == null) return;

    VehiclePickedMedia? media;
    switch (source) {
      case _VehicleMediaSource.gallery:
        media = await _mediaPickerHelper.pickFromGallery(
          context,
          cropLandscape: true,
          cropTitle: 'Cắt ảnh xe',
        );
        break;
      case _VehicleMediaSource.camera:
        media = await _mediaPickerHelper.pickFromCamera(
          context,
          cropLandscape: true,
          cropTitle: 'Cắt ảnh xe',
        );
        break;
    }

    if (!mounted || media == null) return;

    final pickedMedia = media;
    setState(() {
      _vehiclePhotoPaths[slot] = pickedMedia;
    });

    AppToast.show(
      context,
      message: 'Đã chọn ảnh $title',
      type: AppToastType.success,
    );
  }

  Future<void> _pickVehicleDocument() async {
    _hideKeyboard();
    final source = await _showPhotoSourceBottomSheet('Tải ảnh giấy tờ xe');
    if (!mounted || source == null) return;

    VehiclePickedMedia? media;
    switch (source) {
      case _VehicleMediaSource.gallery:
        media = await _mediaPickerHelper.pickFromGallery(
          context,
          cropLandscape: false,
          cropTitle: 'Tải ảnh giấy tờ xe',
        );
        break;
      case _VehicleMediaSource.camera:
        media = await _mediaPickerHelper.pickFromCamera(
          context,
          cropLandscape: false,
          cropTitle: 'Tải ảnh giấy tờ xe',
        );
        break;
    }

    if (!mounted || media == null) return;

    final pickedMedia = media;
    setState(() {
      _vehicleDocument = pickedMedia;
    });

    AppToast.show(
      context,
      message: 'Đã tải ảnh giấy tờ xe',
      type: AppToastType.success,
    );
  }

  Future<void> _pickMake() async {
    if (_isLoadingMakes || _makes.isEmpty) return;
    _hideKeyboard();
    final make = await _showSelectionBottomSheet<CarMake>(
      title: 'Chọn hãng xe',
      subtitle: 'Danh sách hãng xe được hiển thị dưới dạng popup trượt lên.',
      selectedValue: _selectedMake,
      items: _makes
          .map((make) => SelectionItem<CarMake>(value: make, label: make.name))
          .toList(),
    );
    if (!mounted || make == null) return;
    _onMakeChanged(make);
  }

  Future<void> _pickModel() async {
    if (_selectedMake == null || _isLoadingModels || _models.isEmpty) return;
    _hideKeyboard();
    final model = await _showSelectionBottomSheet<CarModel>(
      title: 'Chọn dòng xe',
      subtitle: 'Chọn đúng dòng xe để hệ thống tự tải phiên bản liên quan.',
      selectedValue: _selectedModel,
      items: _models
          .map(
            (model) => SelectionItem<CarModel>(value: model, label: model.name),
          )
          .toList(),
    );
    if (!mounted || model == null) return;
    _onModelChanged(model);
  }

  Future<void> _pickTrim() async {
    if (_selectedModel == null || _isLoadingTrims || _trims.isEmpty) return;
    _hideKeyboard();
    final trim = await _showSelectionBottomSheet<CarTrim>(
      title: 'Chọn phiên bản xe',
      subtitle: 'Popup này hiển thị các phiên bản xe của dòng đang chọn.',
      selectedValue: _selectedTrim,
      items: _trims
          .map(
            (trim) => SelectionItem<CarTrim>(
              value: trim,
              label: [
                if (trim.year != null) '${trim.year}',
                if (trim.name.trim().isNotEmpty) trim.name,
              ].join(' - '),
            ),
          )
          .toList(),
    );
    if (!mounted || trim == null) return;
    _onTrimChanged(trim);
  }

  Future<void> _pickYear() async {
    if (_yearOptions.isEmpty ||
        _isLoadingMakes ||
        _isLoadingModels ||
        _isLoadingTrims) {
      return;
    }
    _hideKeyboard();
    final year = await _showSelectionBottomSheet<int>(
      title: 'Chọn năm sản xuất',
      subtitle: 'Các năm sản xuất được gom lại từ danh sách phiên bản xe.',
      selectedValue: _selectedYear,
      items: _yearOptions
          .map(
            (year) => SelectionItem<int>(value: year, label: year.toString()),
          )
          .toList(),
    );
    if (!mounted || year == null) return;
    setState(() => _selectedYear = year);
  }

  Future<T?> _showSelectionBottomSheet<T>({
    required String title,
    required String subtitle,
    required List<SelectionItem<T>> items,
    required T? selectedValue,
  }) {
    _hideKeyboard();
    final height = MediaQuery.of(context).size.height * 0.6;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            height: height,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 46,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item.value == selectedValue;
                      return Material(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.08)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => Navigator.of(context).pop(item.value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goNext() {
    _hideKeyboard();
    switch (_currentStep) {
      case 0:
        if (!_validateStepOneAndShowErrors()) return;
        break;
      case 1:
        if (_vehiclePhotoPaths.length < 4) {
          AppToast.show(
            context,
            message: 'Vui lòng tải đủ 4 ảnh xe',
            type: AppToastType.warning,
          );
          return;
        }
        break;
      case 2:
        if (_vehicleDocument == null) {
          AppToast.show(
            context,
            message: 'Vui lòng tải ảnh giấy tờ xe',
            type: AppToastType.warning,
          );
          return;
        }
        break;
      case 3:
        if (!(_formKey.currentState?.validate() ?? false)) return;
        break;
    }

    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
    } else {
      _submitVehicle();
    }
  }

  void _goBack() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _currentStep -= 1);
  }

  void _handleHeaderBack() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _currentStep -= 1);
  }

  void _handleHeaderClose() {
    if (_currentStep == 0) return;
    Navigator.of(context).pop();
  }

  Uint8List? _photoBytes(_VehiclePhotoSlot slot) =>
      _vehiclePhotoPaths[slot]?.bytes;

  String _photoSubtitle(_VehiclePhotoSlot slot, String placeholder) {
    final media = _vehiclePhotoPaths[slot];
    if (media == null) return placeholder;
    return 'Đã chọn: ${media.name}';
  }

  Future<File> _writeTempFile(VehiclePickedMedia media, String prefix) async {
    final directory = Directory.systemTemp.createTempSync('car_now_vehicle');
    final safeName = media.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final file = File('${directory.path}/$prefix$safeName');
    await file.writeAsBytes(media.bytes, flush: true);
    return file;
  }

  Future<AddVehicleRequestEntity> _buildAddVehicleRequest() async {
    final photoOrder = const [
      _VehiclePhotoSlot.front,
      _VehiclePhotoSlot.rear,
      _VehiclePhotoSlot.left,
      _VehiclePhotoSlot.right,
    ];

    final imageFiles = <File>[];
    for (final slot in photoOrder) {
      final media = _vehiclePhotoPaths[slot];
      if (media == null) continue;
      imageFiles.add(await _writeTempFile(media, 'photo_${slot.name}_'));
    }

    final document = _vehicleDocument;
    if (document == null) {
      throw StateError('vehicle document is missing');
    }

    return AddVehicleRequestEntity(
      vehicleName:
          '${_selectedMake!.name} ${_selectedModel!.name} ${_selectedYear!}',
      vehicleType: _vehicleType,
      brand: _selectedMake!.name,
      model: _selectedModel!.name,
      year: _selectedYear!,
      color: _colorController.text.trim(),
      licensePlate: _licensePlateController.text.trim(),
      vehicleRegistration: await _writeTempFile(document, 'registration_'),
      seatCount: int.parse(_seatCountController.text.trim()),
      fuelType: _selectedFuelType!.trim(),
      transmission: _selectedTransmission!.trim(),
      pricePerDay: VehiclePriceFormatterHelper.parsePriceInput(
        _pricePerDayController.text,
      )!.toDouble(),
      description: _descriptionController.text.trim(),
      address: AddressEntity(
        addressDetail: _detailAddressController.text.trim(),
        ward: _selectedWard!,
        district: _selectedDistrict!,
        city: _selectedProvince!,
      ),
      images: imageFiles,
    );
  }

  Future<void> _submitVehicle() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppToast.show(
        context,
        message: 'Vui lòng điền đầy đủ thông tin',
        type: AppToastType.warning,
      );
      return;
    }

    if (!_validateStepOneAndShowErrors()) return;
    if (_vehiclePhotoPaths.length < 4) {
      AppToast.show(
        context,
        message: 'Vui lòng tải đủ 4 ảnh xe',
        type: AppToastType.warning,
      );
      return;
    }
    if (_vehicleDocument == null) {
      AppToast.show(
        context,
        message: 'Vui lòng tải ảnh giấy tờ xe',
        type: AppToastType.warning,
      );
      return;
    }

    try {
      final request = await _buildAddVehicleRequest();
      _addVehicleBloc.add(AddVehicleSubmitted(request));
    } catch (e) {
      debugPrint('VehicleRegistrationScreen _submitVehicle error: $e');
      if (!mounted) return;
      AppToast.show(context, message: e.toString(), type: AppToastType.error);
    }
  }

  Widget _buildActionBar({required bool isSubmitting}) {
    final isLast = _currentStep == 3;
    final canProceed = _canProceedCurrentStep;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canProceed && !isSubmitting ? _goNext : null,
            child: isSubmitting && isLast
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Text(isLast ? 'Lưu thông tin xe' : 'Tiếp tục'),
          ),
        ),
      ),
    );
  }

  Widget _buildStepOne() {
    return VehicleRegistrationStepOne(
      colorController: _colorController,
      licensePlateController: _licensePlateController,
      descriptionController: _descriptionController,
      seatCountController: _seatCountController,
      detailAddressController: _detailAddressController,
      makes: _makes,
      models: _models,
      trims: _trims,
      selectedMake: _selectedMake,
      selectedModel: _selectedModel,
      selectedTrim: _selectedTrim,
      selectedYear: _selectedYear,
      selectedFuelType: _selectedFuelType,
      selectedTransmission: _selectedTransmission,
      selectedProvince: _selectedProvince,
      selectedDistrict: _selectedDistrict,
      selectedWard: _selectedWard,
      isLoadingMakes: _isLoadingMakes,
      isLoadingModels: _isLoadingModels,
      isLoadingTrims: _isLoadingTrims,
      yearOptions: _yearOptions,
      requiredValidator: _requiredValidator,
      dropdownValidator: _dropdownValidator,
      onPickMake: _pickMake,
      onPickModel: _pickModel,
      onPickTrim: _pickTrim,
      onPickYear: _pickYear,
      onProvinceChanged: (value) {
        setState(() {
          _selectedProvince = value;
          _selectedDistrict = null;
          _selectedWard = null;
        });
      },
      onDistrictChanged: (value) {
        setState(() {
          _selectedDistrict = value;
          _selectedWard = null;
        });
      },
      onWardChanged: (value) {
        setState(() => _selectedWard = value);
      },
      onToggleFuelPetrol: () => _setFuelType('Xăng'),
      onToggleFuelDiesel: () => _setFuelType('Dầu'),
      onToggleTransmissionManual: () => _setTransmission('Số sàn'),
      onToggleTransmissionAutomatic: () => _setTransmission('Số tự động'),
    );
  }

  Widget _buildStepTwo() {
    final photos = [
      VehicleRegistrationPhotoItem(
        title: 'Chụp mặt trước',
        subtitle: _photoSubtitle(
          _VehiclePhotoSlot.front,
          'Rõ đầu xe, biển số và đèn trước.',
        ),
        illustrationAsset: 'assets/icons/car_front.svg',
        flipIllustrationHorizontally: false,
        previewBytes: _photoBytes(_VehiclePhotoSlot.front),
        onTap: () =>
            _pickVehiclePhoto(_VehiclePhotoSlot.front, 'Chụp mặt trước'),
      ),
      VehicleRegistrationPhotoItem(
        title: 'Chụp mặt sau',
        subtitle: _photoSubtitle(
          _VehiclePhotoSlot.rear,
          'Rõ đuôi xe và biển số sau.',
        ),
        illustrationAsset: 'assets/icons/car_rear.svg',
        flipIllustrationHorizontally: false,
        previewBytes: _photoBytes(_VehiclePhotoSlot.rear),
        onTap: () => _pickVehiclePhoto(_VehiclePhotoSlot.rear, 'Chụp mặt sau'),
      ),
      VehicleRegistrationPhotoItem(
        title: 'Chụp bên trái',
        subtitle: _photoSubtitle(
          _VehiclePhotoSlot.left,
          'Toàn thân xe nhìn từ phía trái.',
        ),
        illustrationAsset: 'assets/icons/car_left.svg',
        flipIllustrationHorizontally: false,
        previewBytes: _photoBytes(_VehiclePhotoSlot.left),
        onTap: () => _pickVehiclePhoto(_VehiclePhotoSlot.left, 'Chụp bên trái'),
      ),
      VehicleRegistrationPhotoItem(
        title: 'Chụp bên phải',
        subtitle: _photoSubtitle(
          _VehiclePhotoSlot.right,
          'Toàn thân xe nhìn từ phía phải.',
        ),
        illustrationAsset: 'assets/icons/car_left.svg',
        flipIllustrationHorizontally: true,
        previewBytes: _photoBytes(_VehiclePhotoSlot.right),
        onTap: () =>
            _pickVehiclePhoto(_VehiclePhotoSlot.right, 'Chụp bên phải'),
      ),
    ];

    return VehicleRegistrationStepTwo(photos: photos);
  }

  Widget _buildStepThree() {
    return VehicleRegistrationStepThree(
      documentPreviewBytes: _vehicleDocument?.bytes,
      documentFileName: _vehicleDocument?.name,
      onTap: _pickVehicleDocument,
    );
  }

  Widget _buildStepFour() {
    return VehicleRegistrationStepFour(
      priceController: _pricePerDayController,
      formattedPrice: _formatCurrency(_pricePerDayController.text.trim()),
      requiredValidator: _requiredValidator,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildStepScrollView(Widget child, int stepIndex) {
    return SingleChildScrollView(
      key: PageStorageKey<int>(stepIndex),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStepOne();
      case 1:
        return _buildStepTwo();
      case 2:
        return _buildStepThree();
      case 3:
        return _buildStepFour();
      default:
        return const SizedBox.shrink();
    }
  }

  Future<_VehicleMediaSource?> _showPhotoSourceBottomSheet(String title) {
    _hideKeyboard();
    return showModalBottomSheet<_VehicleMediaSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.34,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 46,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Chọn nguồn ảnh để tiếp tục.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                    children: [
                      _SourceTile(
                        icon: Icons.photo_library_rounded,
                        title: 'Chọn ảnh từ thư viện',
                        subtitle: 'Lấy ảnh có sẵn trên thiết bị.',
                        onTap: () => Navigator.of(
                          context,
                        ).pop(_VehicleMediaSource.gallery),
                      ),
                      const SizedBox(height: 10),
                      _SourceTile(
                        icon: Icons.photo_camera_rounded,
                        title: 'Chụp bằng camera',
                        subtitle: 'Mở camera để chụp ảnh mới.',
                        onTap: () => Navigator.of(
                          context,
                        ).pop(_VehicleMediaSource.camera),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatCurrency(String value) {
    return VehiclePriceFormatterHelper.formatCurrency(value);
  }

  @override
  Widget build(BuildContext context) {
    final steps = const [
      VehicleRegistrationStepItem(
        icon: Icons.badge_outlined,
        label: 'Thông tin',
      ),
      VehicleRegistrationStepItem(
        icon: Icons.photo_library_outlined,
        label: 'Hình ảnh',
      ),
      VehicleRegistrationStepItem(
        icon: Icons.description_outlined,
        label: 'Giấy tờ xe',
      ),
      VehicleRegistrationStepItem(icon: Icons.payments_outlined, label: 'Giá'),
    ];

    return BlocProvider.value(
      value: _addVehicleBloc,
      child: BlocConsumer<AddVehicleBloc, AddVehicleState>(
        listener: (context, state) {
          if (state is AddVehicleSuccess) {
            AppToast.show(
              context,
              message: 'Đã lưu xe thành công',
              type: AppToastType.success,
            );
            if (mounted) {
              Navigator.of(context).pop(state.vehicle);
            }
          } else if (state is AddVehicleFailure) {
            debugPrint(
              'VehicleRegistrationScreen AddVehicleFailure: ${state.error}',
            );
            AppToast.show(
              context,
              message: state.error,
              type: AppToastType.error,
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is AddVehicleLoading;
          return Stack(
            children: [
              Scaffold(
                backgroundColor: AppColors.background,
                body: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _hideKeyboard,
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                          child: Row(
                            children: [
                              TapScale(
                                onTap: _handleHeaderBack,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Đăng ký xe',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_currentStep > 0) ...[
                                const SizedBox(width: 12),
                                TapScale(
                                  onTap: _handleHeaderClose,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 420,
                                    ),
                                    child: VehicleRegistrationStepRail(
                                      currentStep: _currentStep,
                                      steps: steps,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Form(
                                    key: _formKey,
                                    child: IndexedStack(
                                      index: _currentStep,
                                      children: [
                                        _buildStepScrollView(
                                          _buildStepOne(),
                                          0,
                                        ),
                                        _buildStepScrollView(
                                          _buildStepTwo(),
                                          1,
                                        ),
                                        _buildStepScrollView(
                                          _buildStepThree(),
                                          2,
                                        ),
                                        _buildStepScrollView(
                                          _buildStepFour(),
                                          3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildActionBar(isSubmitting: isSubmitting),
                      ],
                    ),
                  ),
                ),
              ),
              if (isSubmitting) const VehicleRegistrationSubmittingOverlay(),
            ],
          );
        },
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Trường này không được để trống';
    }
    return null;
  }

  String? _dropdownValidator<T>(T? value, String label, String? emptyHint) {
    if (emptyHint != null) {
      return emptyHint;
    }
    if (value == null) {
      return '$label không được để trống';
    }
    return null;
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
