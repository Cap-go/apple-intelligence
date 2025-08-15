package ee.forgr.capgo_llm;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "LLMPlugin")
public class LLMPlugin extends Plugin {
    
    private LLM llm;
    
    @Override
    public void load() {
        super.load();
        llm = LLM.getInstance(getContext());
    }
    
    @PluginMethod
    public void createChat(PluginCall call) {
        try {
            String chatId = llm.createChat();
            JSObject ret = new JSObject();
            ret.put("id", chatId);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("Failed to create chat", e);
        }
    }
    
    @PluginMethod
    public void sendMessage(PluginCall call) {
        String chatId = call.getString("chatId");
        String message = call.getString("message");
        
        if (chatId == null || message == null) {
            call.reject("chatId and message are required");
            return;
        }
        
        llm.sendMessage(chatId, message, new LLM.MessageCallback() {
            @Override
            public void onTextReceived(String chatId, String text) {
                JSObject event = new JSObject();
                event.put("text", text);
                event.put("chatId", chatId);
                notifyListeners("textFromAi", event);
            }
            
            @Override
            public void onComplete(String chatId) {
                JSObject event = new JSObject();
                event.put("chatId", chatId);
                notifyListeners("aiFinished", event);
            }
            
            @Override
            public void onError(String error) {
                call.reject("Failed to send message", error);
            }
        });
        
        call.resolve();
    }
    
    @PluginMethod
    public void getReadiness(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("readiness", llm.getReadiness());
        call.resolve(ret);
    }
    
    @PluginMethod
    public void setModelPath(PluginCall call) {
        String path = call.getString("path");
        
        if (path == null) {
            call.reject("path is required");
            return;
        }
        
        llm.setModelPath(path, new LLM.ModelLoadCallback() {
            @Override
            public void onSuccess() {
                call.resolve();
            }
            
            @Override
            public void onError(String error) {
                call.reject("Failed to load model", error);
            }
        });
    }
}
