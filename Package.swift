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
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0"),
        .package(url: "https://github.com/eastriverlee/LLM.swift", from: "2.0.1")
    ],
    targets: [
        .target(
            name: "LLMPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "LLM", package: "LLM.swift")
            ],
            path: "ios/Sources/LLMPlugin"),
        .testTarget(
            name: "LLMPluginTests",
            dependencies: ["LLMPlugin"],
            path: "ios/Tests/LLMPluginTests")
    ]
)
