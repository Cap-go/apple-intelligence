import Foundation

@objc public class AppleIntelligence: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
