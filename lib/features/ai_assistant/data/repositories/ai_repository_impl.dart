import 'package:book_drive_car/features/ai_assistant/data/datasources/ai_remote_data_source.dart';
import 'package:book_drive_car/features/ai_assistant/domain/entities/ai_response_entity.dart';
import 'package:book_drive_car/features/ai_assistant/domain/repositories/ai_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AiRepository)
class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;

  AiRepositoryImpl(this.remoteDataSource);

  @override
  Future<AiResponseEntity> sendChatMessage(String message) async {
    return await remoteDataSource.sendChatMessage(message);
  }
}
