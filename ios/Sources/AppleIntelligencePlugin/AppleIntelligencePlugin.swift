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
@available(iOS 26.0, *)
public class AppleIntelligencePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "AppleIntelligencePlugin"
    public let jsName = "AppleIntelligence"
    public var pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "createChat", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "sendMessage", returnType: CAPPluginReturnPromise)
    ]
    private var model = SystemLanguageModel.default
    
    private var chats: [String: LanguageModelSession] = [:]

    @objc func createChat(_ call: CAPPluginCall) {
        let session = LanguageModelSession()
        let id = UUID()
        chats[id.uuidString] = session
        call.resolve([
            "id": id.uuidString
        ])
    }
    
    @objc func sendMessage(_ call: CAPPluginCall) {
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
        guard let chat = chats[chatId] else {
            call.reject("chat not found")
            return
        }
        guard let message = call.getString("message") else {
            call.reject("message not found")
            return
        }
        Task {
            do {
                var finalResponse = ""
                let stream = chat.streamResponse(to: message)
                for try await chunk in stream {
                    print(chunk)
                    finalResponse += chunk
                }
                self.notifyListeners("textFromAi", data: ["chatId": chatId, "text": finalResponse])
            } catch {
                call.reject("Failed to get response: \(error.localizedDescription)")
            }
        }
    }
}

