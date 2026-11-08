import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';

class AiResponseEntity {
  final String aiProvider;
  final String aiStatus;
  final String reply;
  final List<CarEntity> recommendations;

  const AiResponseEntity({
    required this.aiProvider,
    required this.aiStatus,
    required this.reply,
    required this.recommendations,
  });

  bool get isSuccess =>
      aiStatus.toUpperCase() == 'SUCCESS' || aiStatus.toUpperCase() == 'OK';
}
