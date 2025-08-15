import Foundation
import Capacitor
import LLM
#if canImport(FoundationModels)
import FoundationModels
#endif

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */

@objc(LLMPlugin)
public class LLMPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "LLMPlugin"
    public let jsName = "CapgoLLM"
    public var pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "createChat", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "sendMessage", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getReadiness", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setModelPath", returnType: CAPPluginReturnPromise),
    ]
    
    private enum ModelType {
        case appleIntelligence
        case customLLM
    }
    
    private var currentModelType: ModelType = .appleIntelligence
    private var customLLM: LLM?
    private var isReady = false
    private var modelPath: String?
    
    #if canImport(FoundationModels)
    private var appleModel: Any? = {
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default
        } else {
            return nil
        }
    }()
    
    private var appleChats: [String: Any] = [:]
    #endif
    
    // Custom LLM chat sessions
    private var customChats: [String: ChatSession] = [:]
    
    // Chat session for custom LLM
    private class ChatSession {
        var history: String = ""
        var isResponding: Bool = false
        
        func addMessage(role: String, content: String) {
            history += "\(role): \(content)\n"
        }
        
        func buildPrompt(_ message: String) -> String {
            return history + "user: \(message)\nassistant: "
        }
    }

    @objc func setModelPath(_ call: CAPPluginCall) {
        guard let path = call.getString("path") else {
            call.reject("Path is required")
            return
        }
        
        modelPath = path
        isReady = false
        
        // Load the custom model
        Task {
            do {
                let modelURL: URL
                
                // Check if it's a path within the app bundle
                if path.hasPrefix("/") {
                    modelURL = URL(fileURLWithPath: path)
                } else {
                    // Try to find it in the app bundle
                    let fileName = (path as NSString).deletingPathExtension
                    let fileExtension = (path as NSString).pathExtension
                    
                    guard let bundleURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension.isEmpty ? "gguf" : fileExtension) else {
                        call.reject("Model file not found in bundle: \(path)")
                        return
                    }
                    modelURL = bundleURL
                }
                
                // Initialize the custom LLM
                customLLM = try await LLM(from: modelURL)
                currentModelType = .customLLM
                isReady = true
                
                call.resolve()
            } catch {
                call.reject("Failed to load model: \(error.localizedDescription)")
            }
        }
    }

    @objc func createChat(_ call: CAPPluginCall) {
        switch currentModelType {
        case .appleIntelligence:
            #if canImport(FoundationModels)
            if #available(iOS 26.0, *) {
                let instructions = call.getString("instructions")
                let session = LanguageModelSession(instructions: instructions)
                let id = UUID()
                appleChats[id.uuidString] = session
                call.resolve([
                    "id": id.uuidString
                ])
            } else {
                call.reject("Apple Intelligence requires iOS 26.0 or later")
            }
            #else
            call.reject("Apple Intelligence is not available on this device")
            #endif
            
        case .customLLM:
            let id = UUID().uuidString
            let session = ChatSession()
            customChats[id] = session
            call.resolve([
                "id": id
            ])
        }
    }
    
    @objc func getReadiness(_ call: CAPPluginCall) {
        switch currentModelType {
        case .appleIntelligence:
            #if canImport(FoundationModels)
            if #available(iOS 26.0, *), let model = appleModel as? SystemLanguageModel {
                switch model.availability {
                    case .available:
                        call.resolve(["readiness": "ready"])
                        return
                    case .unavailable(.deviceNotEligible):
                        call.resolve(["readiness": "Device is not eligible for Apple Intelligence"])
                        return
                    case .unavailable(.appleIntelligenceNotEnabled):
                        call.resolve(["readiness": "Apple Intelligence is not enabled"])
                        return
                    case .unavailable(.modelNotReady):
                        call.resolve(["readiness": "Model is not ready"])
                        return
                    case .unavailable(let other):
                        call.reject("error \(other) error")
                        return
                }
            } else {
                call.resolve(["readiness": "Apple Intelligence requires iOS 26.0 or later"])
            }
            #else
            call.resolve(["readiness": "Apple Intelligence is not available on this device"])
            #endif
            
        case .customLLM:
            call.resolve(["readiness": isReady ? "ready" : "not_ready"])
        }
    }
    
    @objc func sendMessage(_ call: CAPPluginCall) {
        let chatId = call.getString("chatId", "")
        guard let message = call.getString("message") else {
            call.reject("message not found")
            return
        }
        
        switch currentModelType {
        case .appleIntelligence:
            #if canImport(FoundationModels)
            if #available(iOS 26.0, *), let model = appleModel as? SystemLanguageModel {
                switch model.availability {
                    case .available:
                        break
                    case .unavailable(.deviceNotEligible):
                        call.reject("error deviceNotEligible error")
                        return
                    case .unavailable(.appleIntelligenceNotEnabled):
                        call.reject("error appleIntelligenceNotEnabled error")
                        return
                    case .unavailable(.modelNotReady):
                        call.reject("error modelNotReady error")
                        return
                    case .unavailable(let other):
                        call.reject("error \(other) error")
                        return
                }
                
                guard let chat = appleChats[chatId] as? LanguageModelSession else {
                    call.reject("chat not found")
                    return
                }
                
                if (chat.isResponding) {
                    call.reject("chat is responding, please wait before asking new questions")
                    return
                }
                
                Task {
                    do {
                        let stream = chat.streamResponse(to: message)
                        for try await chunk in stream {
                            self.notifyListeners("textFromAi", data: ["chatId": chatId, "text": chunk])
                        }
                        self.notifyListeners("aiFinished", data: ["chatId": chatId])
                        call.resolve()
                    } catch {
                        call.reject("Failed to get response: \(error.localizedDescription)")
                    }
                }
            } else {
                call.reject("Apple Intelligence requires iOS 26.0 or later")
            }
            #else
            call.reject("Apple Intelligence is not available on this device")
            #endif
            
        case .customLLM:
            guard let llm = customLLM else {
                call.reject("Model not loaded")
                return
            }
            
            guard let session = customChats[chatId] else {
                call.reject("Chat session not found")
                return
            }
            
            if session.isResponding {
                call.reject("Chat is responding, please wait before asking new questions")
                return
            }
            
            session.isResponding = true
            
            Task {
                do {
                    // Add user message to history
                    session.addMessage(role: "user", content: message)
                    
                    // Build the full prompt
                    let fullPrompt = session.buildPrompt(message)
                    
                    // Get response from LLM
                    let response = await llm.generate(fullPrompt)
                    
                    // Add AI response to history
                    session.addMessage(role: "assistant", content: response)
                    
                    // Send the response
                    self.notifyListeners("textFromAi", data: ["chatId": chatId, "text": response])
                    self.notifyListeners("aiFinished", data: ["chatId": chatId])
                    
                    session.isResponding = false
                    call.resolve()
                } catch {
                    session.isResponding = false
                    call.reject("Failed to get response: \(error.localizedDescription)")
                }
            }
        }
    }
}
