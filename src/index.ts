import { registerPlugin } from '@capacitor/core';

import type { LLMPlugin } from './definitions';

const AppleIntelligence = registerPlugin<LLMPlugin>('AppleIntelligence', {
  web: () => import('./web').then((m) => new m.AppleIntelligenceWeb()),
});

export * from './definitions';
export { AppleIntelligence };
