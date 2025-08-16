package ee.forgr.capgo_llm;

import android.content.Context;
import com.google.mediapipe.tasks.genai.llminference.LlmInference;
import com.google.mediapipe.tasks.genai.llminference.LlmInference.LlmInferenceOptions;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class LLM {

    private static LLM instance;
    private LlmInference llmInference;
    private Map<String, ChatSession> chatSessions;
    private boolean isReady = false;
    private Context context;
    private Executor executor;
    private String modelPath = null;

    private LLM(Context context) {
        this.context = context;
        this.chatSessions = new HashMap<>();
        this.executor = Executors.newSingleThreadExecutor();
    }

    public static LLM getInstance(Context context) {
        if (instance == null) {
            instance = new LLM(context);
        }
        return instance;
    }

    // Model parameters
    private Integer maxTokens = 2048;
    private Integer topk = 40;
    private Float temperature = 0.1f;

    public void setModel(String path, Integer maxTokens, Integer topk, Float temperature, ModelLoadCallback callback) {
        this.modelPath = path;
        this.maxTokens = maxTokens;
        this.topk = topk;
        this.temperature = temperature;
        isReady = false;

        // If LLM was already initialized, clean it up
        if (llmInference != null) {
            llmInference = null;
        }

        android.util.Log.d(
            "LLM",
            "setModel called with path: " + path + ", maxTokens: " + maxTokens + ", topk: " + topk + ", temperature: " + temperature
        );
        initializeModel(callback);
    }

    private void initializeModel(ModelLoadCallback callback) {
        if (modelPath == null) {
            if (callback != null) {
                callback.onError("Model path not set");
            }
            return;
        }

        executor.execute(() -> {
            try {
                String actualPath = modelPath;

                // Debug logging
                android.util.Log.d("LLM", "Original model path: " + modelPath);

                // For /android_asset/ paths, we need to handle them specially
                if (modelPath.startsWith("/android_asset/")) {
                    // Extract the relative path from assets
                    String assetPath = modelPath.substring("/android_asset/".length());
                    android.util.Log.d("LLM", "Asset path: " + assetPath);

                    // Check if the asset exists
                    try {
                        java.io.InputStream is = context.getAssets().open(assetPath);
                        is.close();
                        android.util.Log.d("LLM", "Asset exists: " + assetPath);

                        // For MediaPipe, we need to copy the asset to a file
                        java.io.File cacheDir = context.getCacheDir();
                        java.io.File modelFile = new java.io.File(cacheDir, assetPath);

                        // Create parent directories if needed
                        modelFile.getParentFile().mkdirs();

                        // Copy asset to cache
                        copyAssetToFile(assetPath, modelFile);
                        actualPath = modelFile.getAbsolutePath();
                        android.util.Log.d("LLM", "Copied asset to: " + actualPath);

                        // Also check for companion .litertlm file
                        String litertlmPath = assetPath.replace(".task", ".litertlm");
                        try {
                            java.io.InputStream litertlmIs = context.getAssets().open(litertlmPath);
                            litertlmIs.close();
                            java.io.File litertlmFile = new java.io.File(cacheDir, litertlmPath);
                            copyAssetToFile(litertlmPath, litertlmFile);
                            android.util.Log.d("LLM", "Also copied companion file: " + litertlmFile.getAbsolutePath());
                        } catch (Exception e) {
                            android.util.Log.d("LLM", "No companion .litertlm file found");
                        }
                    } catch (Exception e) {
                        android.util.Log.e("LLM", "Asset not found: " + assetPath, e);
                        throw new RuntimeException("Asset not found: " + assetPath);
                    }
                }

                android.util.Log.d("LLM", "Final model path: " + actualPath);

                // Create options for LLM inference
                LlmInferenceOptions.Builder optionsBuilder = LlmInferenceOptions.builder()
                    .setModelPath(actualPath)
                    .setMaxTokens(maxTokens)
                    .setMaxTopK(topk);

                LlmInferenceOptions options = optionsBuilder.build();

                // Initialize the LLM inference
                llmInference = LlmInference.createFromOptions(context, options);
                isReady = true;

                if (callback != null) {
                    callback.onSuccess();
                }
            } catch (Exception e) {
                isReady = false;
                e.printStackTrace();
                if (callback != null) {
                    callback.onError(e.getMessage());
                }
            }
        });
    }

    private void copyAssetToFile(String assetPath, java.io.File destFile) throws Exception {
        java.io.InputStream is = context.getAssets().open(assetPath);
        java.io.FileOutputStream fos = new java.io.FileOutputStream(destFile);
        byte[] buffer = new byte[1024];
        int length;
        while ((length = is.read(buffer)) > 0) {
            fos.write(buffer, 0, length);
        }
        fos.close();
        is.close();
    }

    public String createChat() {
        String chatId = UUID.randomUUID().toString();
        ChatSession session = new ChatSession();
        chatSessions.put(chatId, session);
        return chatId;
    }

    public void sendMessage(String chatId, String message, MessageCallback callback) {
        ChatSession session = chatSessions.get(chatId);
        if (session == null) {
            callback.onError("Chat session not found");
            return;
        }

        if (!isReady || llmInference == null) {
            callback.onError("Model not ready");
            return;
        }

        executor.execute(() -> {
            try {
                // Add user message to history
                session.addMessage("user", message);

                // Build the full prompt with chat history
                String fullPrompt = session.buildPrompt(message);
                android.util.Log.d("LLM", "Full prompt: " + fullPrompt);

                // Create a session with proper options
                com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession.LlmInferenceSessionOptions sessionOptions =
                    com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession.LlmInferenceSessionOptions.builder()
                        .setTopK(topk)
                        .setTemperature(temperature)
                        .build();

                com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession inferenceSession =
                    com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession.createFromOptions(llmInference, sessionOptions);

                // Add the query
                inferenceSession.addQueryChunk(fullPrompt);

                // Use streaming API
                final StringBuilder fullResponse = new StringBuilder();

                com.google.mediapipe.tasks.genai.llminference.ProgressListener<String> resultListener =
                    new com.google.mediapipe.tasks.genai.llminference.ProgressListener<String>() {
                        private StringBuilder buffer = new StringBuilder();
                        private boolean hasStarted = false;

                        @Override
                        public void run(String partialResult, boolean done) {
                            android.util.Log.d("LLM", "Partial result: " + partialResult + ", done: " + done);

                            // Accumulate in buffer
                            buffer.append(partialResult);

                            // Process buffer when we have enough content or when done
                            String content = buffer.toString();

                            // Check if we can process some content
                            StringBuilder toSend = new StringBuilder();
                            int i = 0;
                            while (i < content.length()) {
                                // Check for escape sequence
                                if (i < content.length() - 1 && content.charAt(i) == '\\' && content.charAt(i + 1) == 'n') {
                                    toSend.append('\n');
                                    i += 2;
                                } else if (i == content.length() - 1 && content.charAt(i) == '\\' && !done) {
                                    // We have a backslash at the end and more chunks coming - wait for next chunk
                                    break;
                                } else {
                                    toSend.append(content.charAt(i));
                                    i++;
                                }
                            }

                            // Update buffer to contain only unprocessed content
                            buffer = new StringBuilder(content.substring(i));

                            // Send processed content if any
                            String chunk = toSend.toString();

                            // Remove leading newline from the very first content
                            if (!hasStarted && chunk.length() > 0) {
                                chunk = chunk.replaceFirst("^\\n", "");
                                hasStarted = true;
                            }

                            if (!chunk.isEmpty()) {
                                callback.onTextReceived(chatId, chunk, true);
                                fullResponse.append(chunk);
                            }

                            // Process any remaining content when done
                            if (done && buffer.length() > 0) {
                                String remaining = buffer.toString();
                                if (!remaining.isEmpty()) {
                                    callback.onTextReceived(chatId, remaining, true);
                                    fullResponse.append(remaining);
                                }

                                // Add complete response to history
                                session.addMessage("assistant", fullResponse.toString());
                                callback.onComplete(chatId);

                                // Close the session
                                try {
                                    inferenceSession.close();
                                } catch (Exception e) {
                                    android.util.Log.e("LLM", "Failed to close session: " + e.getMessage());
                                }
                            }
                        }
                    };

                inferenceSession.generateResponseAsync(resultListener);
            } catch (Exception e) {
                callback.onError(e.getMessage());
            }
        });
    }

    public String getReadiness() {
        return isReady ? "ready" : "not_ready";
    }

    public interface MessageCallback {
        void onTextReceived(String chatId, String text, boolean isChunk);
        void onComplete(String chatId);
        void onError(String error);
    }

    public interface ModelLoadCallback {
        void onSuccess();
        void onError(String error);
    }

    // Inner class to manage chat sessions
    private static class ChatSession {

        private StringBuilder history;

        ChatSession() {
            this.history = new StringBuilder();
        }

        void addMessage(String role, String content) {
            // Store messages in a cleaner format for history
            if (history.length() > 0) {
                history.append("\n");
            }
            if (role.equals("user")) {
                history.append("User: ").append(content);
            } else {
                history.append("Assistant: ").append(content);
            }
        }

        String buildPrompt(String newMessage) {
            // For Gemma with MediaPipe, just return the message as-is
            return newMessage;
        }
    }
}
