import 'ai_chat_message.dart';

class AiAssistantState {
  final List<AiChatMessage> messages;
  final bool isThinking;
  final String? errorMessage;
  final String? lastUserQuery;

  const AiAssistantState({
    this.messages = const [],
    this.isThinking = false,
    this.errorMessage,
    this.lastUserQuery,
  });

  AiAssistantState copyWith({
    List<AiChatMessage>? messages,
    bool? isThinking,
    String? errorMessage,
    bool clearError = false,
    String? lastUserQuery,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUserQuery: lastUserQuery ?? this.lastUserQuery,
    );
  }
}
