import 'package:book_drive_car/features/home/presentation/widget/car_detail_spec_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helper.dart';

void main() {
  group('CarDetailSpecGrid Widget Test', () {
    testWidgets('nên render đầy đủ danh sách thông số kỹ thuật xe', (tester) async {
      const specs = [
        SpecItem(
          icon: Icons.airline_seat_recline_normal_rounded,
          label: 'Số chỗ',
          value: '5 chỗ',
        ),
        SpecItem(
          icon: Icons.local_gas_station_rounded,
          label: 'Nhiên liệu',
          value: 'Xăng',
        ),
        SpecItem(
          icon: Icons.settings_rounded,
          label: 'Hộp số',
          value: 'Tự động',
        ),
      ];

      await tester.pumpWidget(
        makeTestableWidget(
          const CarDetailSpecGrid(specs: specs),
        ),
      );

      // Kiểm tra các nhãn thông số
      expect(find.text('Số chỗ'), findsOneWidget);
      expect(find.text('5 chỗ'), findsOneWidget);

      expect(find.text('Nhiên liệu'), findsOneWidget);
      expect(find.text('Xăng'), findsOneWidget);

      expect(find.text('Hộp số'), findsOneWidget);
      expect(find.text('Tự động'), findsOneWidget);

      // Kiểm tra icon
      expect(find.byIcon(Icons.airline_seat_recline_normal_rounded), findsOneWidget);
      expect(find.byIcon(Icons.local_gas_station_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    });
  });
}
