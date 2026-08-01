import 'package:flutter/material.dart';

class OnboardingPageData {
  final String eyebrow; // nhãn nhỏ kiểu dashboard, VD "01 · CHỌN XE"
  final String title;
  final String description;
  final IconData icon;
  final String statValue;
  final String statLabel;

  const OnboardingPageData({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.statValue,
    required this.statLabel,
  });
}

const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    eyebrow: '01 · KHO XE',
    title: 'Hàng ngàn xe,\nmột điểm chạm',
    description:
        'Chọn từ hàng trăm mẫu xe đời mới, đã kiểm định kỹ lưỡng, có mặt tại hơn 20 tỉnh thành.',
    icon: Icons.directions_car_filled_rounded,
    statValue: '500+',
    statLabel: 'xe sẵn sàng',
  ),
  OnboardingPageData(
    eyebrow: '02 · TỰ DO',
    title: 'Tự lái,\ntự do',
    description:
        'Không tài xế, không ràng buộc lịch trình. Đi đâu, khi nào là do bạn quyết định.',
    icon: Icons.route_rounded,
    statValue: '63',
    statLabel: 'tỉnh thành',
  ),
  OnboardingPageData(
    eyebrow: '03 · ĐẶT XE',
    title: 'Sẵn sàng lăn bánh\ntrong 60 giây',
    description:
        'Chọn xe, xác nhận, nhận chìa khoá tận nơi. Toàn bộ giấy tờ xử lý ngay trên ứng dụng.',
    icon: Icons.bolt_rounded,
    statValue: '60s',
    statLabel: 'để đặt xong',
  ),
  OnboardingPageData(
    eyebrow: '04 · AN TÂM',
    title: 'An tâm trên\nmọi hành trình',
    description:
        'Bảo hiểm toàn diện, hỗ trợ 24/7 và cứu hộ khẩn cấp trên toàn quốc, luôn sẵn sàng khi cần.',
    icon: Icons.shield_moon_rounded,
    statValue: '24/7',
    statLabel: 'hỗ trợ cứu hộ',
  ),
];
