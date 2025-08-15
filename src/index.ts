import { registerPlugin } from '@capacitor/core';

import type { LLMPlugin } from './definitions';

const CapgoLLM = registerPlugin<LLMPlugin>('CapgoLLM', {
  web: () => import('./web').then((m) => new m.CapgoLLMWeb()),
});

export * from './definitions';
export { CapgoLLM };
