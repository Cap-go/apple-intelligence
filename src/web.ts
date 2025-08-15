import { WebPlugin } from '@capacitor/core';

import type { LLMPlugin } from './definitions';

export class CapgoLLMWeb extends WebPlugin implements LLMPlugin {
  getReadiness(): Promise<{ readiness: string }> {
    throw new Error('Method not implemented.');
  }
  createChat(): Promise<{ id: string }> {
    throw new Error('Method not implemented.');
  }
  sendMessage(_options: { chatId: string; message: string }): Promise<void> {
    throw new Error('Method not implemented.');
  }
  setModelPath(_options: { path: string }): Promise<void> {
    throw new Error('Method not implemented.');
  }
}
