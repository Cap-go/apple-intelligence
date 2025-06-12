import { WebPlugin } from '@capacitor/core';

import type { AppleIntelligencePlugin } from './definitions';

export class AppleIntelligenceWeb extends WebPlugin implements AppleIntelligencePlugin {
  getReadiness(): Promise<{ readiness: string; }> {
    throw new Error('Method not implemented.');
  }
  createChat(): Promise<{ id: string; }> {
    throw new Error('Method not implemented.');
  }
  sendMessage(_options: { chatId: string; message: string; }): Promise<void> {
    throw new Error('Method not implemented.');
  }
  async echo(_options: { value: string }): Promise<{ value: string }> {
    throw new Error('Method not implemented.');
  }
}
