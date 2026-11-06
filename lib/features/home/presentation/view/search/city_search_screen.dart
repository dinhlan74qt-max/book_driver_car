import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/core/theme/app_typography.dart';
import 'package:book_drive_car/features/home/presentation/view/search/city_cars_result_screen.dart';
import 'package:book_drive_car/features/home/presentation/widget/city_search_suggestions.dart';
import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:book_drive_car/shared/widget/tap_scale.dart';
import 'package:flutter/material.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<String> _popularCities = const [
    'Hà Nội',
    'Hồ Chí Minh',
    'Đà Nẵng',
    'Nha Trang',
    'Đà Lạt',
    'Hải Phòng',
    'Cần Thơ',
    'Vũng Tàu',
  ];

  List<String> get _suggestions => filterCitySuggestions(_controller.text);

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectCity(String city) {
    setState(() {
      _controller.text = city;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: city.length),
      );
    });
    _focusNode.unfocus();
  }

  Future<void> _search() async {
    final rawInput = _controller.text.trim();
    final matchingSuggestions = filterCitySuggestions(rawInput);
    final normalizedInput = normalizeVietnameseText(rawInput);
    final city = matchingSuggestions.isNotEmpty &&
            matchingSuggestions.any(
              (item) => normalizeVietnameseText(item) == normalizedInput,
            )
        ? matchingSuggestions.firstWhere(
            (item) => normalizeVietnameseText(item) == normalizedInput,
          )
        : rawInput;

    if (city.isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập hoặc chọn tên thành phố để tìm xe',
        type: AppToastType.warning,
      );
      return;
    }

    if (city != rawInput) {
      _selectCity(city);
    }

    _focusNode.unfocus();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CityCarsResultScreen(cityName: city),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final suggestions = _suggestions;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final surfaceSecondary = isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Tìm xe theo thành phố',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header Card
            Container(
              color: surfaceColor,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _focusNode.hasFocus ? primaryColor : borderColor,
                        width: 1.2,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      style: AppTypography.bodyLarge.copyWith(color: textPrimary),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Nhập tỉnh/thành phố (Hà Nội, Đà Nẵng...)',
                        hintStyle: AppTypography.body.copyWith(color: textMuted),
                        prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, size: 18, color: textMuted),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Tìm kiếm xe',
                    icon: const Icon(Icons.search_rounded),
                    width: double.infinity,
                    onPressed: _search,
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  // Popular Cities Chips
                  if (query.isEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded, color: isDark ? AppColors.darkAccent : AppColors.accent, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Thành phố phổ biến',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _popularCities.map((city) {
                        final isSelected = query.toLowerCase() == city.toLowerCase();
                        return TapScale(
                          onTap: () {
                            _selectCity(city);
                            _search();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? primaryColor : borderColor,
                              ),
                              boxShadow: isDark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: isSelected
                                      ? (isDark ? AppColors.darkBackground : Colors.white)
                                      : primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  city,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? (isDark ? AppColors.darkBackground : Colors.white)
                                        : textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Suggestions list
                  Row(
                    children: [
                      Text(
                        query.isEmpty ? 'Tất cả các tỉnh / thành phố' : 'Kết quả gợi ý',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${suggestions.length} địa điểm',
                        style: AppTypography.caption.copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (suggestions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.location_off_rounded, size: 40, color: textMuted),
                          const SizedBox(height: 8),
                          Text(
                            'Không tìm thấy thành phố phù hợp',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bạn vẫn có thể bấm "Tìm kiếm xe" để tìm theo từ khóa vừa nhập.',
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(color: textSecondary),
                          ),
                        ],
                      ),
                    )
                  else
                    ...suggestions.map((city) {
                      final isSelected = query.toLowerCase() == city.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TapScale(
                          onTap: () {
                            _selectCity(city);
                            _search();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.12)
                                  : surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? primaryColor : borderColor,
                                width: isSelected ? 1.4 : 1.0,
                              ),
                              boxShadow: isDark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor
                                        : primaryColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.location_city_rounded,
                                    size: 20,
                                    color: isSelected
                                        ? (isDark ? AppColors.darkBackground : Colors.white)
                                        : primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    city,
                                    style: AppTypography.bodyLarge.copyWith(
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? primaryColor : textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isSelected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                                  size: 20,
                                  color: isSelected ? primaryColor : textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
