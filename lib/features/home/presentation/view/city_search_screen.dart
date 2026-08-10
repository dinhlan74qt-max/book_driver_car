import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/home/presentation/view/city_cars_result_screen.dart';
import 'package:book_drive_car/features/home/presentation/widget/city_search_suggestions.dart';
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
        message: 'Vui lòng nhập tên thành phố để tìm xe',
        type: AppToastType.error,
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

    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      body: Stack(
        children: [
          const Positioned.fill(child: _CitySearchBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _GlassActionButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Tìm xe theo thành phố',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F6F1),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.10),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nhập tên thành phố',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Gõ thành phố bạn muốn tìm, chọn gợi ý bên dưới hoặc nhập trực tiếp rồi bấm tìm kiếm.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            onChanged: (_) => setState(() {}),
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _search(),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Ví dụ: Đà Nẵng, Hà Nội, Hồ Chí Minh...',
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _search,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.headlightAmber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(Icons.search_rounded),
                            label: const Text(
                              'Tìm kiếm',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Text(
                              'Gợi ý thành phố',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            if (query.isNotEmpty)
                              Text(
                                '${suggestions.length} kết quả',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: suggestions.isEmpty
                              ? Center(
                                  child: Text(
                                    query.isEmpty
                                        ? 'Chọn một thành phố để bắt đầu.'
                                        : 'Không có gợi ý phù hợp, bạn vẫn có thể tìm trực tiếp.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: suggestions.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final city = suggestions[index];
                                    return TapScale(
                                      onTap: () => _selectCity(city),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: _controller.text.trim().toLowerCase() == city.toLowerCase()
                                              ? AppColors.headlightAmber.withValues(alpha: 0.18)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: _controller.text.trim().toLowerCase() == city.toLowerCase()
                                                ? AppColors.headlightAmber.withValues(alpha: 0.55)
                                                : AppColors.border,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.location_city_rounded,
                                                color: AppColors.primary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                city,
                                                style: const TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.north_east_rounded,
                                              color: AppColors.textMuted,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CitySearchBackground extends StatelessWidget {
  const _CitySearchBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1017), Color(0xFF151A24), Color(0xFFF7F8FA)],
          stops: [0.0, 0.38, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -60,
            child: _GlowOrb(
              size: 220,
              colors: [
                AppColors.headlightAmber.withValues(alpha: 0.20),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            top: 170,
            left: -80,
            child: _GlowOrb(
              size: 180,
              colors: [
                AppColors.pageAccents[2].withValues(alpha: 0.16),
                Colors.transparent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GlowOrb({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
