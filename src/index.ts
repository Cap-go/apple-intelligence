import { registerPlugin } from '@capacitor/core';

import type { AppleIntelligencePlugin } from './definitions';

const AppleIntelligence = registerPlugin<AppleIntelligencePlugin>('AppleIntelligence', {
  web: () => import('./web').then((m) => new m.AppleIntelligenceWeb()),
});

export * from './definitions';
export { AppleIntelligence };
