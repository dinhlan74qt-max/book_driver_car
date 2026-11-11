import 'package:book_drive_car/shared/widget/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helper.dart';

void main() {
  group('AppButton Widget Test', () {
    testWidgets('nên hiển thị đúng text và trigger callback khi được nhấn', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        makeTestableWidget(
          AppButton(
            text: 'Tiếp tục',
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      );

      expect(find.text('Tiếp tục'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle();

      expect(wasPressed, isTrue);
    });

    testWidgets('không nên trigger callback khi nút ở trạng thái disabled (onPressed null)', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const AppButton(
            text: 'Vô hiệu hóa',
            onPressed: null,
          ),
        ),
      );

      expect(find.text('Vô hiệu hóa'), findsOneWidget);
      // Tap vào button disabled không xảy ra lỗi và không tương tác
      await tester.tap(find.text('Vô hiệu hóa'));
      await tester.pumpAndSettle();
    });

    testWidgets('nên hiển thị CircularProgressIndicator và không thể nhấn khi isLoading = true', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        makeTestableWidget(
          AppButton(
            text: 'Đang tải',
            isLoading: true,
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      );

      // Khi loading, text bị ẩn và hiện CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Đang tải'), findsNothing);

      await tester.tap(find.byType(CircularProgressIndicator));
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    testWidgets('nên hiển thị đúng icon khi truyền vào', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          AppButton(
            text: 'Xe yêu thích',
            icon: Icons.favorite,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Xe yêu thích'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}
