export default {
  input: 'dist/esm/index.js',
  output: [
    {
      file: 'dist/plugin.js',
      format: 'iife',
      name: 'capacitorLLM',
      globals: {
        '@capacitor/core': 'capacitorExports',
        '@mediapipe/tasks-genai': 'MediaPipeTasksGenAI',
      },
      sourcemap: true,
      inlineDynamicImports: true,
    },
    {
      file: 'dist/plugin.cjs.js',
      format: 'cjs',
      sourcemap: true,
      inlineDynamicImports: true,
    },
  ],
  external: ['@capacitor/core', '@mediapipe/tasks-genai'],
  context: 'globalThis',
};
