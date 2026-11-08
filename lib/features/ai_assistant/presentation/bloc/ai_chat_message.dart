import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';

enum AiMessageType {
  text,
  carRecommendation,
}

class AiChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;
  final AiMessageType type;
  final List<CarEntity> recommendedCars;
  final String? aiProvider;
  final bool isError;

  AiChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    DateTime? timestamp,
    this.type = AiMessageType.text,
    this.recommendedCars = const [],
    this.aiProvider,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();

  AiChatMessage copyWith({
    String? id,
    bool? isUser,
    String? text,
    DateTime? timestamp,
    AiMessageType? type,
    List<CarEntity>? recommendedCars,
    String? aiProvider,
    bool? isError,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      isUser: isUser ?? this.isUser,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      recommendedCars: recommendedCars ?? this.recommendedCars,
      aiProvider: aiProvider ?? this.aiProvider,
      isError: isError ?? this.isError,
    );
  }
}
