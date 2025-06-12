export interface AppleIntelligencePlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
