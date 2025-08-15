/**
 * LLM Plugin interface for interacting with on-device language models
 */
export interface LLMPlugin {
  /**
   * Creates a new chat session
   * @returns Promise with chat id and optional instructions
   */
  createChat(): Promise<{ id: string; instructions?: string }>;
  
  /**
   * Sends a message to the AI in a specific chat session
   * @param options - The chat id and message to send
   * @returns Promise that resolves when message is sent
   */
  sendMessage(options: { chatId: string; message: string }): Promise<void>;
  
  /**
   * Gets the readiness status of the LLM
   * @returns Promise with readiness status string
   */
  getReadiness(): Promise<{ readiness: string }>;
  
  /**
   * Adds a listener for text received from AI
   * @param eventName - Event name 'textFromAi'
   * @param listenerFunc - Callback function for text events
   * @returns Promise with remove function to unsubscribe
   */
  addListener(
    eventName: 'textFromAi',
    listenerFunc: (event: TextFromAiEvent) => void,
  ): Promise<{ remove: () => Promise<void> }>;
  
  /**
   * Adds a listener for AI completion events
   * @param eventName - Event name 'aiFinished'
   * @param listenerFunc - Callback function for finish events
   * @returns Promise with remove function to unsubscribe
   */
  addListener(
    eventName: 'aiFinished',
    listenerFunc: (event: AiFinishedEvent) => void,
  ): Promise<{ remove: () => Promise<void> }>;
  
  /**
   * Sets the model path for custom models
   * - iOS: Path to a GGUF model file (in bundle or absolute path)
   * - Android: Path to a MediaPipe model file (in assets or files directory)
   * @param options - The model path configuration
   * @returns Promise that resolves when model is loaded
   */
  setModelPath(options: { path: string }): Promise<void>;
}

/**
 * Event data for text received from AI
 */
export interface TextFromAiEvent {
  /** The text content from AI */
  text: string;
  /** The chat session ID */
  chatId: string;
}

/**
 * Event data for AI completion
 */
export interface AiFinishedEvent {
  /** The chat session ID that finished */
  chatId: string;
}
