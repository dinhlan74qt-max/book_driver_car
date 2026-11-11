import 'package:book_drive_car/shared/widget/app_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helper.dart';

void main() {
  group('AppStatusBadge Widget Test', () {
    testWidgets('hiển thị badge "Khả dụng" khi trạng thái là AVAILABLE', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          AppStatusBadge.fromStatus('AVAILABLE'),
        ),
      );

      expect(find.text('Khả dụng'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('hiển thị badge "Chờ duyệt" khi trạng thái là PENDING', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          AppStatusBadge.fromStatus('PENDING'),
        ),
      );

      expect(find.text('Chờ duyệt'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
    });

    testWidgets('hiển thị badge fallback "Đang chờ duyệt" khi trạng thái là null hoặc chuỗi rỗng', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          AppStatusBadge.fromStatus(null),
        ),
      );

      expect(find.text('Đang chờ duyệt'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
    });
  });
}
