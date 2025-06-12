import Foundation
import Capacitor
#if canImport(FoundationModels)
import FoundationModels
#endif
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */

@objc(AppleIntelligencePlugin)
public class AppleIntelligencePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "AppleIntelligencePlugin"
    public let jsName = "AppleIntelligence"
    public var pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "createChat", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "sendMessage", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getReadiness", returnType: CAPPluginReturnPromise),
    ]
    
    #if canImport(FoundationModels)
    private var model: Any? = {
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default
        } else {
            return nil
        }
    }()
    
    private var chats: [String: Any] = [:]
    #endif

    @objc func createChat(_ call: CAPPluginCall) {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let instructions = call.getString("instructions")
            let session = LanguageModelSession(instructions: instructions)
            let id = UUID()
            chats[id.uuidString] = session
            call.resolve([
                "id": id.uuidString
            ])
        } else {
            call.reject("Apple Intelligence requires iOS 26.0 or later")
        }
        #else
        call.reject("Apple Intelligence is not available on this device")
        #endif
    }
    
    @objc func getReadiness(_ call: CAPPluginCall) {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), let model = model as? SystemLanguageModel {
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
    }
    
    @objc func sendMessage(_ call: CAPPluginCall) {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), let model = model as? SystemLanguageModel {
            switch model.availability {
                case .available:
                    break;
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
            let chatId = call.getString("chatId", "")
            guard let chat = chats[chatId] as? LanguageModelSession else {
                call.reject("chat not found")
                return
            }
            guard let message = call.getString("message") else {
                call.reject("message not found")
                return
            }
            if (chat.isResponding) {
                call.reject("chat is respnding, please wait before asking new questions")
                return
            }
            Task {
                do {
                    let stream = chat.streamResponse(to: message)
                    for try await chunk in stream {
                        self.notifyListeners("textFromAi", data: ["chatId": chatId, "text": chunk])
                    }
                    self.notifyListeners("aiFinished", data: ["chatId": chatId])
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
    }
}

