import 'package:injectable/injectable.dart';
import '../entities/ai_response_entity.dart';
import '../repositories/ai_repository.dart';

@injectable
class SendAiChatMessage {
  final AiRepository repository;

  SendAiChatMessage(this.repository);

  Future<AiResponseEntity> call(String message) async {
    return await repository.sendChatMessage(message);
  }
}
