package ee.forgr.capgo_llm;

import android.content.Context;
import com.google.mediapipe.tasks.genai.llminference.LlmInference;
import com.google.mediapipe.tasks.genai.llminference.LlmInference.LlmInferenceOptions;
import java.io.File;
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
    
    public void setModelPath(String path, ModelLoadCallback callback) {
        this.modelPath = path;
        isReady = false;
        
        // If LLM was already initialized, clean it up
        if (llmInference != null) {
            llmInference = null;
        }
        
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
                // Create options for LLM inference
                LlmInferenceOptions options = LlmInferenceOptions.builder()
                    .setModelPath(modelPath)
                    .setMaxTokens(2048)
                    .setTopK(40)
                    .setTemperature(0.8f)
                    .setRandomSeed(42)
                    .build();
                
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
                
                // Generate response
                String response = llmInference.generateResponse(fullPrompt);
                
                // Add AI response to history
                session.addMessage("assistant", response);
                
                // Notify callbacks
                callback.onTextReceived(chatId, response);
                callback.onComplete(chatId);
                
            } catch (Exception e) {
                callback.onError(e.getMessage());
            }
        });
    }
    
    public String getReadiness() {
        return isReady ? "ready" : "not_ready";
    }
    
    public interface MessageCallback {
        void onTextReceived(String chatId, String text);
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
            history.append(role).append(": ").append(content).append("\n");
        }
        
        String buildPrompt(String newMessage) {
            return history.toString() + "user: " + newMessage + "\nassistant: ";
        }
    }
}
