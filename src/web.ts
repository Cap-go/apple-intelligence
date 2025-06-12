import { WebPlugin } from '@capacitor/core';

import type { AppleIntelligencePlugin } from './definitions';

export class AppleIntelligenceWeb extends WebPlugin implements AppleIntelligencePlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
