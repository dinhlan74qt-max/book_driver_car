import 'dart:async';

import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/home/presentation/widget/city_search_suggestions.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

enum LocationSearchMode { none, currentLocation, province, address }

class CarSearchFilter {
  final LocationSearchMode locationMode;
  final String?
  locationLabel; // tên tỉnh, địa chỉ nhập tay, hoặc "Vị trí hiện tại"
  final double? latitude;
  final double? longitude;
  final String? vehicleType;
  final String? brand;
  final String? model;
  final int? minPrice;
  final int? maxPrice;

  const CarSearchFilter({
    this.locationMode = LocationSearchMode.none,
    this.locationLabel,
    this.latitude,
    this.longitude,
    this.vehicleType,
    this.brand,
    this.model,
    this.minPrice,
    this.maxPrice,
  });

  int get activeFilterCount {
    int count = 0;
    if (locationLabel != null && locationLabel!.trim().isNotEmpty) count++;
    if (vehicleType != null && vehicleType != kAllOption) count++;
    if (brand != null && brand != kAllOption) count++;
    if (model != null && model != kAllOption) count++;
    if (minPrice != null || maxPrice != null) count++;
    return count;
  }

  CarSearchFilter copyWith({
    LocationSearchMode? locationMode,
    String? locationLabel,
    double? latitude,
    double? longitude,
    String? vehicleType,
    String? brand,
    String? model,
    int? minPrice,
    int? maxPrice,
  }) {
    return CarSearchFilter(
      locationMode: locationMode ?? this.locationMode,
      locationLabel: locationLabel ?? this.locationLabel,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      vehicleType: vehicleType ?? this.vehicleType,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

class LocationSuggestion {
  final String label;
  final String? subtitle;
  final double? latitude;
  final double? longitude;
  final bool isAddress;

  const LocationSuggestion({
    required this.label,
    this.subtitle,
    this.latitude,
    this.longitude,
    this.isAddress = false,
  });
}

const String kAllOption = 'Tất cả';

class CarSearchSheet extends StatefulWidget {
  final CarSearchFilter initialFilter;

  const CarSearchSheet({
    super.key,
    this.initialFilter = const CarSearchFilter(),
  });

  static Future<CarSearchFilter?> show(
    BuildContext context, {
    CarSearchFilter initialFilter = const CarSearchFilter(),
  }) {
    return showModalBottomSheet<CarSearchFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => CarSearchSheet(initialFilter: initialFilter),
    );
  }

  @override
  State<CarSearchSheet> createState() => _CarSearchSheetState();
}

class _CarSearchSheetState extends State<CarSearchSheet> {
  static const _debounceDuration = Duration(milliseconds: 300);

  final _locationController = TextEditingController();
  final _locationFocusNode = FocusNode();
  Timer? _debounce;
  int _searchRequestId = 0;

  // Danh sách các tỉnh / thành phố nổi bật
  static const List<String> _popularCities = [
    'Hà Nội',
    'Hồ Chí Minh',
    'Đà Nẵng',
    'Bình Dương',
    'Hải Phòng',
    'Cần Thơ',
    'Lâm Đồng',
    'Khánh Hòa',
    'Bà Rịa - Vũng Tàu',
  ];

  // Danh sách khoảng giá gợi ý nhanh (min, max, label)
  static const List<_PricePreset> _pricePresets = [
    _PricePreset(label: 'Tất cả', minPrice: null, maxPrice: null),
    _PricePreset(label: '< 800k', minPrice: null, maxPrice: 800000),
    _PricePreset(label: '800k - 1.5tr', minPrice: 800000, maxPrice: 1500000),
    _PricePreset(label: '1.5tr - 2.5tr', minPrice: 1500000, maxPrice: 2500000),
    _PricePreset(label: '> 2.5tr', minPrice: 2500000, maxPrice: null),
  ];

  final List<String> _vehicleTypes = const [
    kAllOption,
    'Xe 4 chỗ mini',
    'Xe 4 chỗ sedan',
    'Xe 5 chỗ CUV gầm cao',
    'Xe 7 chỗ SUV gầm cao',
  ];

  final List<String> _brands = const [
    kAllOption,
    'VinFast',
    'Toyota',
    'Honda',
    'Mazda',
    'Hyundai',
    'Kia',
    'Mitsubishi',
    'Ford',
    'Suzuki',
  ];

  static const Map<String, List<String>> _modelsByBrand = {
    'VinFast': ['VF 3', 'VF 5', 'VF 6', 'VF 7', 'VF 8', 'VF 9'],
    'Toyota': ['Vios', 'Camry', 'Corolla Cross', 'Fortuner', 'Innova'],
    'Honda': ['City', 'Civic', 'CR-V', 'HR-V', 'Accord'],
    'Mazda': ['Mazda 2', 'Mazda 3', 'Mazda 6', 'CX-3', 'CX-5', 'CX-8'],
    'Hyundai': ['Grand i10', 'Accent', 'Elantra', 'Tucson', 'Santa Fe'],
    'Kia': ['Morning', 'Cerato', 'Sonet', 'Seltos', 'Carnival'],
    'Mitsubishi': ['Attrage', 'Xforce', 'Xpander', 'Outlander', 'Pajero'],
    'Ford': ['Ranger', 'Everest', 'Territory', 'Transit'],
    'Suzuki': ['Swift', 'XL7', 'Ciaz', 'Ertiga'],
  };

  String? _selectedType;
  String? _selectedBrand;
  String? _selectedModel;

  LocationSearchMode _locationMode = LocationSearchMode.none;
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;
  String? _locationError;

  List<LocationSuggestion> _suggestions = [];
  bool _isSearching = false;
  String? _searchError;

  // Lọc theo giá
  int? _minPrice;
  int? _maxPrice;
  RangeValues _priceRangeValues = const RangeValues(300000, 5000000);

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialFilter.vehicleType;
    _selectedBrand = widget.initialFilter.brand;
    _selectedModel = widget.initialFilter.model;
    _locationMode = widget.initialFilter.locationMode;
    _latitude = widget.initialFilter.latitude;
    _longitude = widget.initialFilter.longitude;
    _locationController.text = widget.initialFilter.locationLabel ?? '';

    _minPrice = widget.initialFilter.minPrice;
    _maxPrice = widget.initialFilter.maxPrice;
    _initPriceRange();

    _locationFocusNode.addListener(_handleFocusChange);
  }

  void _initPriceRange() {
    final start = (_minPrice ?? 300000).toDouble().clamp(300000.0, 5000000.0);
    final end = (_maxPrice ?? 5000000).toDouble().clamp(300000.0, 5000000.0);
    _priceRangeValues = RangeValues(start, end < start ? start : end);
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _locationFocusNode.removeListener(_handleFocusChange);
    _locationController.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  bool get _shouldShowSuggestions =>
      _locationFocusNode.hasFocus &&
      _locationMode != LocationSearchMode.currentLocation &&
      _locationController.text.trim().isNotEmpty;

  int get _activeCount {
    int count = 0;
    if (_locationController.text.trim().isNotEmpty) count++;
    if (_selectedType != null && _selectedType != kAllOption) count++;
    if (_selectedBrand != null && _selectedBrand != kAllOption) count++;
    if (_selectedModel != null && _selectedModel != kAllOption) count++;
    if (_minPrice != null || _maxPrice != null) count++;
    return count;
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Vui lòng bật dịch vụ định vị (GPS) trên thiết bị.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Bạn đã từ chối quyền truy cập vị trí.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Quyền vị trí bị chặn. Hãy cấp quyền trong Cài đặt.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _locationMode = LocationSearchMode.currentLocation;
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationController.text = 'Vị trí hiện tại của bạn';
        _isLocating = false;
        _suggestions = [];
      });
      _locationFocusNode.unfocus();
    } catch (e) {
      setState(() {
        _isLocating = false;
        _locationError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _selectSuggestion(LocationSuggestion suggestion) {
    _debounce?.cancel();
    setState(() {
      _locationMode = suggestion.isAddress
          ? LocationSearchMode.address
          : LocationSearchMode.province;
      _latitude = suggestion.latitude;
      _longitude = suggestion.longitude;
      _locationController.text = suggestion.label;
      _locationError = null;
      _suggestions = [];
    });
    _locationFocusNode.unfocus();
  }

  void _selectPopularCity(String city) {
    if (_locationController.text.trim() == city) {
      // Nhấn lại thì bỏ chọn
      _clearLocation();
      return;
    }
    _debounce?.cancel();
    setState(() {
      _locationMode = LocationSearchMode.province;
      _latitude = null;
      _longitude = null;
      _locationController.text = city;
      _locationError = null;
      _suggestions = [];
    });
    _locationFocusNode.unfocus();
  }

  void _onLocationTextChanged(String value) {
    _debounce?.cancel();
    final text = value.trim();

    setState(() {
      _locationError = null;
      _searchError = null;
      _latitude = null;
      _longitude = null;

      if (text.isEmpty) {
        _locationMode = LocationSearchMode.none;
        _suggestions = [];
        _isSearching = false;
        return;
      }

      _locationMode = LocationSearchMode.address;
      _isSearching = true;
    });

    if (text.isEmpty) return;

    _debounce = Timer(_debounceDuration, () {
      final results = filterCitySuggestions(text)
          .map(
            (city) => LocationSuggestion(
              label: city,
              subtitle: 'Tỉnh / Thành phố',
              isAddress: false,
            ),
          )
          .take(8)
          .toList();

      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _isSearching = false;
      });
    });
  }

  void _confirmTypedAddress() {
    final text = _locationController.text.trim();
    if (text.isEmpty) return;
    _debounce?.cancel();
    setState(() {
      _locationMode = LocationSearchMode.address;
      _latitude = null;
      _longitude = null;
      _locationController.text = text;
      _locationError = null;
      _suggestions = [];
    });
    _locationFocusNode.unfocus();
  }

  void _clearLocation() {
    _debounce?.cancel();
    setState(() {
      _locationController.clear();
      _locationMode = LocationSearchMode.none;
      _latitude = null;
      _longitude = null;
      _locationError = null;
      _searchError = null;
      _suggestions = [];
      _isSearching = false;
    });
  }

  void _selectPricePreset(_PricePreset preset) {
    setState(() {
      _minPrice = preset.minPrice;
      _maxPrice = preset.maxPrice;
      _initPriceRange();
    });
  }

  bool _isPresetSelected(_PricePreset preset) {
    return _minPrice == preset.minPrice && _maxPrice == preset.maxPrice;
  }

  void _onPriceSliderChanged(RangeValues values) {
    setState(() {
      _priceRangeValues = values;
      _minPrice = values.start <= 300000 ? null : values.start.round();
      _maxPrice = values.end >= 5000000 ? null : values.end.round();
    });
  }

  List<String> _modelOptions() {
    if (_selectedBrand != null && _selectedBrand != kAllOption) {
      return [kAllOption, ...(_modelsByBrand[_selectedBrand!] ?? const [])];
    }
    return const [
      kAllOption,
      'Sedan',
      'SUV',
      'Hatchback',
      'MPV',
      'Pickup',
      'Coupe',
    ];
  }

  void _resetAll() {
    _debounce?.cancel();
    setState(() {
      _selectedType = null;
      _selectedBrand = null;
      _selectedModel = null;
      _locationMode = LocationSearchMode.none;
      _latitude = null;
      _longitude = null;
      _locationError = null;
      _searchError = null;
      _suggestions = [];
      _isSearching = false;
      _locationController.clear();
      _minPrice = null;
      _maxPrice = null;
      _priceRangeValues = const RangeValues(300000, 5000000);
    });
  }

  void _applyFilter() {
    final text = _locationController.text.trim();
    Navigator.of(context).pop(
      CarSearchFilter(
        locationMode: _locationMode,
        locationLabel: text.isEmpty ? null : text,
        latitude: _latitude,
        longitude: _longitude,
        vehicleType: _selectedType,
        brand: _selectedBrand,
        model: _selectedModel,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      ),
    );
  }

  String _formatPriceTag(int amount) {
    if (amount >= 1000000) {
      final millions = amount / 1000000;
      if (millions == millions.roundToDouble()) {
        return '${millions.toInt()}tr';
      }
      return '${millions.toStringAsFixed(1)}tr';
    }
    return '${amount ~/ 1000}k';
  }

  String get _priceSummaryText {
    if (_minPrice == null && _maxPrice == null) {
      return 'Tất cả mức giá';
    }
    if (_minPrice == null && _maxPrice != null) {
      return '< ${_formatPriceTag(_maxPrice!)}/ngày';
    }
    if (_minPrice != null && _maxPrice == null) {
      return '≥ ${_formatPriceTag(_minPrice!)}/ngày';
    }
    return '${_formatPriceTag(_minPrice!)} - ${_formatPriceTag(_maxPrice!)}/ngày';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.90,
        minChildSize: 0.50,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                _buildSheetHeader(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      // 1. VỊ TRÍ & TỈNH THÀNH
                      _buildSectionHeader(
                        icon: Icons.location_on_rounded,
                        title: 'Vị trí & Tỉnh thành',
                        subtitle:
                            'Chọn nhanh thành phố hoặc nhập địa chỉ muốn nhận xe',
                      ),
                      const SizedBox(height: 12),
                      _buildLocationInput(),
                      if (_locationError != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 16,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _locationError!,
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_shouldShowSuggestions) _buildSuggestionsList(),
                      const SizedBox(height: 14),
                      _buildPopularCitiesSection(),

                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 20),

                      // 2. MỨC GIÁ THUÊ
                      _buildPriceSection(),

                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 20),

                      // 3. GỢI Ý TÌM KIẾM NHANH
                      _buildQuickPresetsSection(),

                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 20),

                      // 4. LOẠI XE
                      _buildSectionHeader(
                        icon: Icons.directions_car_rounded,
                        title: 'Loại xe',
                        subtitle: 'Chọn số chỗ ngồi và kiểu dáng phù hợp',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _vehicleTypes.map((type) {
                          final isSelected = type == kAllOption
                              ? _selectedType == null
                              : _selectedType == type;
                          return _ModernChip(
                            label: type,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedType = type == kAllOption
                                    ? null
                                    : type;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 20),

                      // 5. HÃNG XE
                      _buildSectionHeader(
                        icon: Icons.apartment_rounded,
                        title: 'Hãng xe',
                        subtitle: 'Lọc theo thương hiệu ưa thích',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _brands.map((brand) {
                          final isSelected = brand == kAllOption
                              ? _selectedBrand == null
                              : _selectedBrand == brand;
                          return _ModernChip(
                            label: brand,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedBrand = brand == kAllOption
                                    ? null
                                    : brand;
                                _selectedModel = null;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 20),

                      // 6. DÒNG XE
                      _buildSectionHeader(
                        icon: Icons.route_rounded,
                        title: 'Dòng xe',
                        subtitle:
                            _selectedBrand != null &&
                                _selectedBrand != kAllOption
                            ? 'Các mẫu xe nổi bật của ${_selectedBrand!}'
                            : 'Các dòng xe phổ biến',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _modelOptions().map((model) {
                          final isSelected =
                              _selectedModel == model ||
                              (_selectedModel == null && model == kAllOption);
                          return _ModernChip(
                            label: model,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedModel = model == kAllOption
                                    ? null
                                    : model;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                _buildBottomDock(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSheetHeader() {
    final activeCount = _activeCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 14, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      'Tìm kiếm & Bộ lọc',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (activeCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$activeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (activeCount > 0)
                TextButton.icon(
                  onPressed: _resetAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    foregroundColor: const Color(0xFFE86000),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text(
                    'Đặt lại',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: Color(0xFF64748B),
                ),
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationInput() {
    final isFocused = _locationFocusNode.hasFocus;
    final isCurrentLocation =
        _locationMode == LocationSearchMode.currentLocation;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? AppColors.primary : const Color(0xFFE2E8F0),
          width: isFocused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: isFocused ? AppColors.primary : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _locationController,
              focusNode: _locationFocusNode,
              onChanged: _onLocationTextChanged,
              onSubmitted: (_) => _confirmTypedAddress(),
              textInputAction: TextInputAction.search,
              readOnly: isCurrentLocation,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Nhập tỉnh/thành hoặc địa chỉ...',
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
              ),
            ),
          ),
          TapScale(
            onTap: _isLocating ? null : _useCurrentLocation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isCurrentLocation
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLocating)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isCurrentLocation
                            ? Colors.white
                            : AppColors.primary,
                      ),
                    )
                  else
                    Icon(
                      Icons.my_location_rounded,
                      size: 15,
                      color: isCurrentLocation
                          ? Colors.white
                          : AppColors.primary,
                    ),
                  const SizedBox(width: 4),
                  Text(
                    'Gần tôi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isCurrentLocation
                          ? Colors.white
                          : AppColors.primary,
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

  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: _isSearching
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : _suggestions.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Không tìm thấy tỉnh/thành phù hợp',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final item = _suggestions[index];
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: const Icon(
                      Icons.location_city_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: item.subtitle != null
                        ? Text(
                            item.subtitle!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          )
                        : null,
                    onTap: () => _selectSuggestion(item),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildPopularCitiesSection() {
    final currentText = _locationController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tỉnh / Thành phố nổi bật:',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularCities.map((city) {
            final isSelected = currentText.toLowerCase() == city.toLowerCase();
            return _ModernChip(
              label: city,
              icon: Icons.place_rounded,
              isSelected: isSelected,
              onTap: () => _selectPopularCity(city),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _buildSectionHeader(
                icon: Icons.payments_rounded,
                title: 'Mức giá / ngày',
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                ),
                child: Text(
                  _priceSummaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE86000),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _pricePresets.map((preset) {
            final isSelected = _isPresetSelected(preset);
            return _ModernChip(
              label: preset.label,
              isSelected: isSelected,
              onTap: () => _selectPricePreset(preset),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: const Color(0xFFE2E8F0),
            trackHeight: 4,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.12),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 9,
            ),
          ),
          child: RangeSlider(
            values: _priceRangeValues,
            min: 300000,
            max: 5000000,
            divisions: 47,
            onChanged: _onPriceSliderChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '300k',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              ),
              Text(
                '1.5 triệu',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              ),
              Text(
                '3 triệu',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              ),
              Text(
                '5 triệu+',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPresetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.auto_awesome_rounded,
          title: 'Gợi ý tìm kiếm phổ biến',
          subtitle: 'Lựa chọn nhanh các gói tìm xe được nhiều người sử dụng',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickPresetButton(
              icon: Icons.bolt_rounded,
              iconColor: const Color(0xFF0284C7),
              label: 'Xe điện VinFast',
              isSelected: _selectedBrand == 'VinFast',
              onTap: () {
                setState(() {
                  _selectedBrand = _selectedBrand == 'VinFast'
                      ? null
                      : 'VinFast';
                  _selectedModel = null;
                });
              },
            ),
            _QuickPresetButton(
              icon: Icons.family_restroom_rounded,
              iconColor: const Color(0xFF16A34A),
              label: 'Xe 7 chỗ gia đình',
              isSelected: _selectedType == 'Xe 7 chỗ SUV gầm cao',
              onTap: () {
                setState(() {
                  _selectedType = _selectedType == 'Xe 7 chỗ SUV gầm cao'
                      ? null
                      : 'Xe 7 chỗ SUV gầm cao';
                });
              },
            ),
            _QuickPresetButton(
              icon: Icons.savings_rounded,
              iconColor: const Color(0xFFE86000),
              label: 'Xe tiết kiệm (< 800k)',
              isSelected: _maxPrice == 800000 && _minPrice == null,
              onTap: () {
                setState(() {
                  if (_maxPrice == 800000 && _minPrice == null) {
                    _maxPrice = null;
                  } else {
                    _minPrice = null;
                    _maxPrice = 800000;
                  }
                  _initPriceRange();
                });
              },
            ),
            _QuickPresetButton(
              icon: Icons.terrain_rounded,
              iconColor: const Color(0xFF7C3AED),
              label: 'Gầm cao 5 chỗ CUV',
              isSelected: _selectedType == 'Xe 5 chỗ CUV gầm cao',
              onTap: () {
                setState(() {
                  _selectedType = _selectedType == 'Xe 5 chỗ CUV gầm cao'
                      ? null
                      : 'Xe 5 chỗ CUV gầm cao';
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomDock() {
    final activeCount = _activeCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 14,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _applyFilter,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_rounded, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    activeCount > 0
                        ? 'Áp dụng bộ lọc ($activeCount tiêu chí)'
                        : 'Tìm kiếm tất cả xe',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PricePreset {
  final String label;
  final int? minPrice;
  final int? maxPrice;

  const _PricePreset({
    required this.label,
    required this.minPrice,
    required this.maxPrice,
  });
}

class _ModernChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModernChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPresetButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickPresetButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
