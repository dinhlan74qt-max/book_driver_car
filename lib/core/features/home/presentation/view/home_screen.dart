import 'package:book_drive_car/core/features/home/presentation/view/all_cars_screen.dart';
import 'package:book_drive_car/core/features/home/presentation/widget/car_card.dart';
import 'package:book_drive_car/core/features/home/presentation/widget/car_search_sheet.dart';
import 'package:book_drive_car/core/shared/data/mock_data/mock_data.dart';
import 'package:book_drive_car/core/shared/data/models/car_model.dart';
import 'package:book_drive_car/core/shared/widget/staggered_fade_in.dart';
import 'package:book_drive_car/core/shared/widget/tap_scale.dart';
import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final bool nearbyIsHorizontal;
  final bool suggestedIsHorizontal;

  const HomeScreen({
    super.key,
    this.nearbyIsHorizontal = true,
    this.suggestedIsHorizontal = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _defaultProvince = 'Đà Nẵng';

  CarSearchFilter _filter = const CarSearchFilter(
    locationMode: LocationSearchMode.province,
    locationLabel: _defaultProvince,
  );

  List<Car> get _cars {
    final label = _filter.locationLabel?.toLowerCase().trim();

    final result = MockData.cars.where((car) {
      final typeMatch =
          _filter.vehicleType == null || car.vehicleType == _filter.vehicleType;
      final brandMatch = _filter.brand == null || car.brand == _filter.brand;

      bool locationMatch;
      switch (_filter.locationMode) {
        case LocationSearchMode.province:
          // Lọc chính xác theo tỉnh/thành đã chọn
          locationMatch = label == null || car.province.toLowerCase() == label;
          break;
        case LocationSearchMode.currentLocation:
        case LocationSearchMode.address:
          // Chưa có toạ độ chính xác của từng xe để lọc cứng theo bán kính,
          // nên tạm không lọc theo tỉnh — sẽ sắp xếp theo khoảng cách bên dưới.
          locationMatch = true;
          break;
        case LocationSearchMode.none:
          locationMatch = true;
          break;
      }

      return locationMatch && typeMatch && brandMatch;
    }).toList();

    return result;
  }

  List<Car> get _nearbyCars {
    final result = List<Car>.from(_cars);
    result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return result;
  }

  List<Car> get _suggestedCars {
    final result = List<Car>.from(_cars);
    result.sort((a, b) => b.rating.compareTo(a.rating));
    return result;
  }

  Future<void> _openSearch() async {
    final result = await CarSearchSheet.show(context, initialFilter: _filter);
    if (result != null) {
      setState(() => _filter = result);
    }
  }

  void _openAllCars(List<Car> cars, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AllCarsScreen(cars: cars, title: title),
      ),
    );
  }

  void _resetFilter() {
    setState(() {
      _filter = const CarSearchFilter(
        locationMode: LocationSearchMode.province,
        locationLabel: _defaultProvince,
      );
    });
  }

  String get _locationLabel => _filter.locationLabel ?? _defaultProvince;

  String get _heroSubtitle {
    switch (_filter.locationMode) {
      case LocationSearchMode.currentLocation:
        return 'Đang xem xe gần vị trí hiện tại của bạn';
      case LocationSearchMode.address:
        return 'Đang xem xe gần "$_locationLabel"';
      case LocationSearchMode.province:
      case LocationSearchMode.none:
        return 'Đang xem xe tại $_locationLabel';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cars = _cars;
    final nearbyCars = _nearbyCars.take(5).toList();
    final suggestedCars = _suggestedCars.take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        StaggeredFadeIn(
          index: 0,
          child: _HeroCard(
            subtitle: _heroSubtitle,
            searchPlaceholder: _filter.locationMode == LocationSearchMode.none
                ? 'Nhập tên tỉnh hoặc địa chỉ cụ thể'
                : _locationLabel,
            onSearchTap: _openSearch,
          ),
        ),
        const SizedBox(height: 16),
        StaggeredFadeIn(
          index: 1,
          child: Row(
            children: [
              _InfoPill(label: '${cars.length}', caption: 'xe phù hợp'),
              const SizedBox(width: 10),
              const _InfoPill(label: '4.8+', caption: 'đánh giá'),
              const SizedBox(width: 10),
              const _InfoPill(label: '24h', caption: 'hỗ trợ'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _CarSection(
          index: 2,
          title: 'Xe gần đây',
          cars: nearbyCars,
          isHorizontal: widget.nearbyIsHorizontal,
          emptyTitle: 'Chưa có xe phù hợp',
          emptyDescription:
              'Bạn hãy đổi vị trí hoặc xoá bộ lọc để xem thêm xe.',
          onReset: _resetFilter,
          onSeeAll: () => _openAllCars(_nearbyCars, 'Xe gần đây'),
        ),
        const SizedBox(height: 20),
        _CarSection(
          index: 3,
          title: 'Gợi ý cho bạn',
          cars: suggestedCars,
          isHorizontal: widget.suggestedIsHorizontal,
          emptyTitle: 'Chưa có gợi ý phù hợp',
          emptyDescription:
              'Bạn hãy đổi vị trí hoặc xoá bộ lọc để xem gợi ý khác.',
          onReset: _resetFilter,
          onSeeAll: () => _openAllCars(_suggestedCars, 'Gợi ý cho bạn'),
        ),
      ],
    );
  }
}

class _CarSection extends StatelessWidget {
  final int index;
  final String title;
  final List<Car> cars;
  final bool isHorizontal;
  final String emptyTitle;
  final String emptyDescription;
  final VoidCallback onReset;
  final VoidCallback onSeeAll;

  const _CarSection({
    required this.index,
    required this.title,
    required this.cars,
    required this.isHorizontal,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.onReset,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StaggeredFadeIn(
          index: index,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TapScale(
                onTap: cars.isEmpty ? null : onSeeAll,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (cars.isEmpty)
          StaggeredFadeIn(
            index: index + 1,
            child: _EmptyState(
              title: emptyTitle,
              description: emptyDescription,
              onReset: onReset,
            ),
          )
        else
          StaggeredFadeIn(
            index: index + 1,
            child: isHorizontal
                ? _HorizontalCars(cars: cars)
                : _VerticalCars(cars: cars),
          ),
      ],
    );
  }
}

class _HorizontalCars extends StatelessWidget {
  final List<Car> cars;

  const _HorizontalCars({required this.cars});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cars.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final car = cars[index];
          return CarCard(
            car: car,
            width: 260,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mở chi tiết ${car.name}')),
              );
            },
          );
        },
      ),
    );
  }
}

class _VerticalCars extends StatelessWidget {
  final List<Car> cars;

  const _VerticalCars({required this.cars});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < cars.length; i++) ...[
          CarCard(
            car: cars[i],
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mở chi tiết ${cars[i].name}')),
              );
            },
          ),
          if (i != cars.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String subtitle;
  final String searchPlaceholder;
  final VoidCallback onSearchTap;

  const _HeroCard({
    required this.subtitle,
    required this.searchPlaceholder,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withBlue(100),
            AppColors.accent.withOpacity(0.94),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xin chào, Nguyễn Văn Sang',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          TapScale(
            onTap: onSearchTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      searchPlaceholder,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
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

class _InfoPill extends StatelessWidget {
  final String label;
  final String caption;

  const _InfoPill({required this.label, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withOpacity(0.75)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onReset;

  const _EmptyState({
    required this.title,
    required this.description,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: AppColors.textMuted,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onReset, child: const Text('Xoá bộ lọc')),
        ],
      ),
    );
  }
}
