abstract class AiAssistantEvent {
  const AiAssistantEvent();
}

class AiSendMessageEvent extends AiAssistantEvent {
  final String message;

  const AiSendMessageEvent(this.message);
}

class AiResetChatEvent extends AiAssistantEvent {
  const AiResetChatEvent();
}

class AiRetryLastMessageEvent extends AiAssistantEvent {
  const AiRetryLastMessageEvent();
}
