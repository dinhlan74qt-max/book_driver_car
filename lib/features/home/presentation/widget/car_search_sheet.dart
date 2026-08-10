import 'dart:async';

import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/home/presentation/widget/city_search_suggestions.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

enum LocationSearchMode { none, currentLocation, province, address }

class CarSearchFilter {
  final LocationSearchMode locationMode;
  final String? locationLabel; // tên tỉnh, địa chỉ nhập tay, hoặc "Vị trí hiện tại"
  final double? latitude;
  final double? longitude;
  final String? vehicleType;
  final String? brand;
  final String? model;

  const CarSearchFilter({
    this.locationMode = LocationSearchMode.none,
    this.locationLabel,
    this.latitude,
    this.longitude,
    this.vehicleType,
    this.brand,
    this.model,
  });
}

/// Một gợi ý vị trí trả về từ API tìm kiếm (tỉnh/thành hoặc địa chỉ cụ thể).
class LocationSuggestion {
  final String label;
  final String? subtitle;
  final double? latitude;
  final double? longitude;
  final bool isAddress; // true = địa chỉ cụ thể, false = tỉnh/thành

  const LocationSuggestion({
    required this.label,
    this.subtitle,
    this.latitude,
    this.longitude,
    this.isAddress = false,
  });
}

/// Giá trị đại diện cho lựa chọn "Tất cả" trong danh sách loại xe / hãng xe.
/// Khi loại xe hoặc hãng xe đang được chọn là "Tất cả", _selectedType /
/// _selectedBrand sẽ là null (nghĩa là không lọc theo tiêu chí đó).
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
      builder: (_) => CarSearchSheet(initialFilter: initialFilter),
    );
  }

  @override
  State<CarSearchSheet> createState() => _CarSearchSheetState();
}

class _CarSearchSheetState extends State<CarSearchSheet> {
  static const _debounceDuration = Duration(seconds: 1);

  final _locationController = TextEditingController();
  final _locationFocusNode = FocusNode();
  Timer? _debounce;

  // Tăng dần mỗi lần gọi API để bỏ qua kết quả trả về trễ (out-of-order).
  int _searchRequestId = 0;

  // "Tất cả" luôn nằm đầu danh sách và mặc định được chọn (khi
  // _selectedType / _selectedBrand đang là null).
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

  String? _selectedType;
  String? _selectedBrand;
  String? _selectedModel;

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

  LocationSearchMode _locationMode = LocationSearchMode.none;
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;
  String? _locationError;

  List<LocationSuggestion> _suggestions = [];
  bool _isSearching = false;
  String? _searchError;

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

    // Khi focus vào ô tìm kiếm hoặc rời khỏi, cần rebuild để ẩn/hiện
    // danh sách gợi ý bên dưới thanh tìm kiếm.
    _locationFocusNode.addListener(_handleFocusChange);
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
      _locationFocusNode.hasFocus && _locationMode != LocationSearchMode.currentLocation;

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
        throw Exception('Quyền vị trí bị chặn vĩnh viễn. Hãy bật lại trong Cài đặt.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
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
      _locationMode = suggestion.isAddress ? LocationSearchMode.address : LocationSearchMode.province;
      _latitude = suggestion.latitude;
      _longitude = suggestion.longitude;
      _locationController.text = suggestion.label;
      _locationError = null;
    });
    _locationFocusNode.unfocus();
  }

  // Xác nhận tìm theo đúng từ khoá người dùng đã gõ (khi không chọn gợi ý nào
  // từ danh sách trả về từ API, ví dụ nhấn nút search trên bàn phím).
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

      // Tạm coi là địa chỉ tự do cho tới khi người dùng chọn một gợi ý cụ thể
      // hoặc kết quả API xác định đây là tỉnh/thành.
      _locationMode = LocationSearchMode.address;
      _isSearching = true;
    });

    if (text.isEmpty) return;

    // Chờ người dùng ngừng gõ 1 giây rồi mới gọi API tìm gợi ý.
    _debounce = Timer(_debounceDuration, () => _fetchSuggestions(text));
  }

  Future<void> _fetchSuggestions(String keyword) async {
    final requestId = ++_searchRequestId;

    try {
      final results = await _searchLocations(keyword);
      if (!mounted || requestId != _searchRequestId) return; // có yêu cầu mới hơn, bỏ qua kết quả này
      setState(() {
        _suggestions = results;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _suggestions = [];
        _isSearching = false;
        _searchError = 'Không thể tải gợi ý. Vui lòng thử lại.';
      });
    }
  }

  /// TODO: thay thế bằng lời gọi API gợi ý vị trí thực tế, ví dụ:
  ///
  /// final response = await locationRepository.search(keyword);
  /// return response
  ///     .map((e) => LocationSuggestion(
  ///           label: e.name,
  ///           subtitle: e.address,
  ///           latitude: e.lat,
  ///           longitude: e.lng,
  ///           isAddress: e.type == 'address',
  ///         ))
  ///     .toList();
  Future<List<LocationSuggestion>> _searchLocations(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return filterCitySuggestions(keyword)
        .map(
          (city) => LocationSuggestion(
            label: city,
            subtitle: 'Thành phố',
            isAddress: false,
          ),
        )
        .toList();
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
    _locationFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.55,
        maxChildSize: 0.97,
        builder: (context, controller) {
          return Container(
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
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tìm xe theo vị trí',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                            ),
                            TextButton(
                              onPressed: _resetAll,
                              child: const Text('Đặt lại'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Nhập tên tỉnh/thành hoặc địa chỉ để xem gợi ý, hoặc dùng vị trí hiện tại để tìm xe gần bạn.',
                          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 18),
                        _buildLocationBar(),
                        if (_locationError != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _locationError!,
                                  style: const TextStyle(color: AppColors.danger, fontSize: 12.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_shouldShowSuggestions) _buildSuggestionsList(),
                        const SizedBox(height: 22),
                        _SectionTitle(
                          icon: Icons.directions_car_rounded,
                          title: 'Loại xe',
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _vehicleTypes
                              .map(
                                (type) => FilterChip(
                                  label: Text(type),
                                  selected: type == kAllOption
                                      ? _selectedType == null
                                      : _selectedType == type,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedType = type == kAllOption ? null : type;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        _SectionTitle(
                          icon: Icons.apartment_rounded,
                          title: 'Hãng xe',
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _brands
                              .map(
                                (brand) => FilterChip(
                                  label: Text(brand),
                                selected: brand == kAllOption
                                      ? _selectedBrand == null
                                      : _selectedBrand == brand,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedBrand = brand == kAllOption ? null : brand;
                                      _selectedModel = null;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        _SectionTitle(
                          icon: Icons.route_rounded,
                          title: 'Dòng xe',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedBrand == null || _selectedBrand == kAllOption
                              ? 'Chọn hãng xe trước, hoặc tạm dùng nhóm dòng xe chung.'
                              : 'Đang lọc theo ${_selectedBrand!}. Bạn có thể chọn dòng xe phù hợp bên dưới.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _modelOptions().map((model) {
                            final isSelected = _selectedModel == model ||
                                (_selectedModel == null && model == kAllOption);
                            return FilterChip(
                              label: Text(model),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedModel = model == kAllOption ? null : model;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(
                                CarSearchFilter(
                                  locationMode: _locationMode,
                                  locationLabel: _locationController.text.trim().isEmpty
                                      ? null
                                      : _locationController.text.trim(),
                                  latitude: _latitude,
                                  longitude: _longitude,
                                  vehicleType: _selectedType,
                                  brand: _selectedBrand,
                                  model: _selectedModel,
                                ),
                              );
                            },
                            child: const Text('Áp dụng'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationBar() {
    final isFocused = _locationFocusNode.hasFocus;
    final isCurrentLocation = _locationMode == LocationSearchMode.currentLocation;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFocused ? AppColors.primary : AppColors.border,
          width: isFocused ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? AppColors.primary.withOpacity(0.14)
                : const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: isFocused ? 18 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: isFocused ? AppColors.primary.withOpacity(0.1) : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 19,
              color: isFocused ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _locationController,
              focusNode: _locationFocusNode,
              onChanged: _onLocationTextChanged,
              onSubmitted: (_) => _confirmTypedAddress(),
              textInputAction: TextInputAction.search,
              readOnly: isCurrentLocation,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Nhập tỉnh/thành hoặc địa chỉ cụ thể...',
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
            ),
          ),
          if (_locationController.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _clearLocation,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          TapScale(
            onTap: _isLocating ? null : _useCurrentLocation,
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 2),
              decoration: BoxDecoration(
                color: isCurrentLocation ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _isLocating
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isCurrentLocation ? Colors.white : AppColors.primary,
                        ),
                      )
                    : Icon(
                        Icons.my_location_rounded,
                        size: 19,
                        color: isCurrentLocation ? Colors.white : AppColors.primary,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Danh sách gợi ý hiển thị ngay dưới thanh tìm kiếm:
  // - "Vị trí hiện tại" luôn nằm đầu danh sách để chọn nhanh.
  // - Sau 1 giây kể từ lần gõ cuối, gọi API và hiện kết quả gợi ý bên dưới.
  Widget _buildSuggestionsList() {
    final text = _locationController.text.trim();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 6),
          children: [
            ListTile(
              dense: true,
              leading: Icon(Icons.my_location_rounded, size: 20, color: AppColors.primary),
              title: const Text(
                'Vị trí hiện tại',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
              trailing: _isLocating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: _isLocating ? null : _useCurrentLocation,
            ),
            if (text.isNotEmpty) ...[
              const Divider(height: 1),
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Đang tìm kiếm...',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else if (_searchError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Text(
                    _searchError!,
                    style: const TextStyle(color: AppColors.danger, fontSize: 13),
                  ),
                )
              else if (_suggestions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Text(
                    'Không tìm thấy kết quả cho "$text". Nhấn tìm kiếm để dùng địa chỉ này.',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                )
              else
                for (final suggestion in _suggestions)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      suggestion.isAddress ? Icons.place_rounded : Icons.location_city_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    title: Text(suggestion.label, style: const TextStyle(fontSize: 13.5)),
                    subtitle: suggestion.subtitle != null
                        ? Text(
                            suggestion.subtitle!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () => _selectSuggestion(suggestion),
                  ),
            ],
          ],
        ),
      ),
    );
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
    });
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

