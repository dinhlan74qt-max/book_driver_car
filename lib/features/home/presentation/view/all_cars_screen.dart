import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/view/car_detail_screen.dart';
import 'package:book_drive_car/features/home/presentation/widget/car_card.dart';
import 'package:flutter/material.dart';


class AllCarsScreen extends StatelessWidget {
  final List<CarEntity> cars;
  final String title;

  const AllCarsScreen({
    super.key,
    required this.cars,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: cars.isEmpty
          ? const Center(child: Text('Không có xe nào phù hợp'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cars.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final car = cars[index];
                return CarCard(
                  car: car,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CarDetailScreen(car: car),
                    ),
                  ),
                );
              },
            ),
    );
  }
}