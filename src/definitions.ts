export interface AppleIntelligencePlugin {
  createChat(): Promise<{ id: string; instructions?: string }>;
  sendMessage(options: { chatId: string; message: string }): Promise<void>;
  getReadiness(): Promise<{ readiness: string }>;
  addListener(
    eventName: 'textFromAi',
    listenerFunc: (event: TextFromAiEvent) => void,
  ): Promise<{ remove: () => Promise<void> }>;
  addListener(
    eventName: 'aiFinished',
    listenerFunc: (event: AiFinishedEvent) => void,
  ): Promise<{ remove: () => Promise<void> }>;
}

export interface TextFromAiEvent {
  text: string;
  chatId: string;
}

export interface AiFinishedEvent {
  chatId: string;
}
