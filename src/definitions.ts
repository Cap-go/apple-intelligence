export interface AppleIntelligencePlugin {
  createChat(): Promise<{ id: string }>;
  sendMessage(options: { chatId: string, message: string }): Promise<void>;
  addListener(
    eventName: 'textFromAi',
    listenerFunc: (event: TextFromAiEvent) => void,
  ): Promise<{ remove: () => Promise<void> }>;
}

export interface TextFromAiEvent {
  text: string;
  chatId: string;
}