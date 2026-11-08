import '../entities/ai_response_entity.dart';

abstract class AiRepository {
  Future<AiResponseEntity> sendChatMessage(String message);
}
