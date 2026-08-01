import 'package:book_drive_car/features/profile/presentation/widget/vehicle_registration_widgets.dart';
import 'package:book_drive_car/shared/services/province_open_api/province_open_api_service.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProvinceOpenApiLocationPicker extends StatefulWidget {
  final String? provinceName;
  final String? districtName;
  final String? wardName;
  final ValueChanged<String?> onProvinceChanged;
  final ValueChanged<String?> onDistrictChanged;
  final ValueChanged<String?> onWardChanged;

  const ProvinceOpenApiLocationPicker({
    super.key,
    required this.provinceName,
    required this.districtName,
    required this.wardName,
    required this.onProvinceChanged,
    required this.onDistrictChanged,
    required this.onWardChanged,
  });

  @override
  State<ProvinceOpenApiLocationPicker> createState() =>
      _ProvinceOpenApiLocationPickerState();
}

class _ProvinceOpenApiLocationPickerState
    extends State<ProvinceOpenApiLocationPicker> {
  final _service = ProvinceOpenApiService();

  List<ProvinceDivision> _provinces = [];
  bool _isLoadingProvinces = false;
  bool _isLoadingDistricts = false;
  bool _isLoadingWards = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  void _hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _loadProvinces() async {
    setState(() {
      _isLoadingProvinces = true;
      _errorMessage = null;
    });

    try {
      final provinces = await _service.getProvinces();
      if (!mounted) return;
      setState(() {
        _provinces = provinces;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không tải được danh sách tỉnh/thành phố.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingProvinces = false);
      }
    }
  }

  ProvinceDivision? get _selectedProvince {
    final name = widget.provinceName?.trim();
    if (name == null || name.isEmpty) return null;
    for (final province in _provinces) {
      if (province.name == name) return province;
    }
    return null;
  }

  DistrictDivision? get _selectedDistrict {
    final province = _selectedProvince;
    final name = widget.districtName?.trim();
    if (province == null || name == null || name.isEmpty) return null;
    for (final district in province.districts) {
      if (district.name == name) return district;
    }
    return null;
  }

  WardDivision? get _selectedWard {
    final district = _selectedDistrict;
    final name = widget.wardName?.trim();
    if (district == null || name == null || name.isEmpty) return null;
    for (final ward in district.wards) {
      if (ward.name == name) return ward;
    }
    return null;
  }

  List<DistrictDivision> get _districtOptions =>
      _selectedProvince?.districts ?? const [];

  List<WardDivision> get _wardOptions {
    final province = _selectedProvince;
    final district = _selectedDistrict;
    if (province == null || district == null) return const [];
    return district.wards;
  }

  Future<T?> _showSelectionBottomSheet<T>({
    required String title,
    required String subtitle,
    required List<SelectionItem<T>> items,
    required T? selectedValue,
  }) {
    _hideKeyboard();
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
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

  Future<void> _pickProvince() async {
    if (_isLoadingProvinces || _provinces.isEmpty) return;
    final province = await _showSelectionBottomSheet<ProvinceDivision>(
      title: 'Chọn tỉnh/thành phố',
      subtitle: 'Chọn tỉnh/thành phố nơi bạn cho thuê xe.',
      selectedValue: _selectedProvince,
      items: _provinces
          .map(
            (province) => SelectionItem<ProvinceDivision>(
              value: province,
              label: province.name,
            ),
          )
          .toList(),
    );
    if (!mounted || province == null) return;
    widget.onProvinceChanged(province.name);
    widget.onDistrictChanged(null);
    widget.onWardChanged(null);
  }

  Future<void> _pickDistrict() async {
    final province = _selectedProvince;
    if (province == null) return;

    setState(() => _isLoadingDistricts = true);
    try {
      final districts = province.districts.isNotEmpty
          ? province.districts
          : await _service.getDistricts(province.code);
      if (!mounted) return;
      setState(() {
        _provinces = _provinces
            .map(
              (item) => item.code == province.code
                  ? ProvinceDivision(
                      code: item.code,
                      name: item.name,
                      districts: districts,
                    )
                  : item,
            )
            .toList(growable: false);
      });
      final selectedDistrict =
          await _showSelectionBottomSheet<DistrictDivision>(
            title: 'Chọn quận/huyện',
            subtitle: province.name,
            selectedValue: _selectedDistrict,
            items: districts
                .map(
                  (district) => SelectionItem<DistrictDivision>(
                    value: district,
                    label: district.name,
                  ),
                )
                .toList(),
          );
      if (!mounted || selectedDistrict == null) return;
      widget.onDistrictChanged(selectedDistrict.name);
      widget.onWardChanged(null);
    } finally {
      if (mounted) {
        setState(() => _isLoadingDistricts = false);
      }
    }
  }

  Future<void> _pickWard() async {
    final province = _selectedProvince;
    final district = _selectedDistrict;
    if (province == null || district == null) return;

    setState(() => _isLoadingWards = true);
    try {
      final wards = district.wards.isNotEmpty
          ? district.wards
          : await _service.getWards(district.code);
      if (!mounted) return;
      final updatedDistricts = province.districts
          .map((item) {
            if (item.code != district.code) return item;
            return DistrictDivision(
              code: item.code,
              name: item.name,
              provinceCode: item.provinceCode,
              wards: wards,
            );
          })
          .toList(growable: false);
      setState(() {
        _provinces = _provinces
            .map(
              (item) => item.code == province.code
                  ? ProvinceDivision(
                      code: item.code,
                      name: item.name,
                      districts: updatedDistricts,
                    )
                  : item,
            )
            .toList(growable: false);
      });
      final selectedWard = await _showSelectionBottomSheet<WardDivision>(
        title: 'Chọn phường/xã',
        subtitle: '${district.name}, ${province.name}',
        selectedValue: _selectedWard,
        items: wards
            .map(
              (ward) =>
                  SelectionItem<WardDivision>(value: ward, label: ward.name),
            )
            .toList(),
      );
      if (!mounted || selectedWard == null) return;
      widget.onWardChanged(selectedWard.name);
    } finally {
      if (mounted) {
        setState(() => _isLoadingWards = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provinceHint = _isLoadingProvinces
        ? 'Đang tải tỉnh/thành phố...'
        : widget.provinceName == null
        ? 'Chọn tỉnh/thành phố'
        : widget.provinceName!;
    final districtHint = _selectedProvince == null
        ? 'Chọn tỉnh/thành phố trước'
        : _isLoadingDistricts
        ? 'Đang tải quận/huyện...'
        : widget.districtName == null
        ? 'Chọn quận/huyện'
        : widget.districtName!;
    final wardHint = _selectedDistrict == null
        ? 'Chọn quận/huyện trước'
        : _isLoadingWards
        ? 'Đang tải phường/xã...'
        : widget.wardName == null
        ? 'Chọn phường/xã'
        : widget.wardName!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage != null) ...[
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final fieldWidth = isWide
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

            final provinceField = SizedBox(
              width: fieldWidth,
              child:
                  VehicleRegistrationBottomSheetSelectorField<ProvinceDivision>(
                    value: _selectedProvince,
                    hintText: provinceHint,
                    enabled: !_isLoadingProvinces && _provinces.isNotEmpty,
                    onTap: _pickProvince,
                    displayBuilder: (value) => value?.name ?? '',
                    validator: (value) {
                      if (_isLoadingProvinces)
                        return 'Đang tải tỉnh/thành phố...';
                      if (_provinces.isEmpty)
                        return 'Chưa tải được danh sách tỉnh/thành phố';
                      if (value == null)
                        return 'Tỉnh/thành phố không được để trống';
                      return null;
                    },
                  ),
            );

            final districtField = SizedBox(
              width: fieldWidth,
              child:
                  VehicleRegistrationBottomSheetSelectorField<DistrictDivision>(
                    value: _selectedDistrict,
                    hintText: districtHint,
                    enabled: _selectedProvince != null && !_isLoadingDistricts,
                    onTap: _pickDistrict,
                    displayBuilder: (value) => value?.name ?? '',
                    validator: (value) {
                      if (_selectedProvince == null) {
                        return 'Hãy chọn tỉnh/thành phố trước';
                      }
                      if (_isLoadingDistricts) return 'Đang tải quận/huyện...';
                      if (value == null)
                        return 'Quận/huyện không được để trống';
                      return null;
                    },
                  ),
            );

            final wardField = SizedBox(
              width: fieldWidth,
              child: VehicleRegistrationBottomSheetSelectorField<WardDivision>(
                value: _selectedWard,
                hintText: wardHint,
                enabled: _selectedDistrict != null && !_isLoadingWards,
                onTap: _pickWard,
                displayBuilder: (value) => value?.name ?? '',
                validator: (value) {
                  if (_selectedDistrict == null)
                    return 'Hãy chọn quận/huyện trước';
                  if (_isLoadingWards) return 'Đang tải phường/xã...';
                  if (value == null) return 'Phường/xã không được để trống';
                  return null;
                },
              ),
            );

            if (isWide) {
              return Wrap(
                spacing: 12,
                runSpacing: 14,
                children: [provinceField, districtField, wardField],
              );
            }

            return Column(
              children: [
                provinceField,
                const SizedBox(height: 14),
                districtField,
                const SizedBox(height: 14),
                wardField,
              ],
            );
          },
        ),
      ],
    );
  }
}
