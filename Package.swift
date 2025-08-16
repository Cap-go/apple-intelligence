// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapgoLLM",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapgoLLM",
            targets: ["LLMPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
        // Note: SwiftTasksVision is for MediaPipe Vision, not GenAI
        // We would need a similar package for MediaPipeTasksGenAI
        // Keeping this as a placeholder for when GenAI SPM support is available
        // .package(url: "https://github.com/paescebu/SwiftTasksVision.git", from: "0.10.21")
    ],
    targets: [
        .target(
            name: "LLMPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/LLMPlugin"),
        .testTarget(
            name: "LLMPluginTests",
            dependencies: ["LLMPlugin"],
            path: "ios/Tests/LLMPluginTests")
    ]
)
