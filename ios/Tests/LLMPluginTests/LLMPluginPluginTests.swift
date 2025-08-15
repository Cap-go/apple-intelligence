import XCTest
@testable import LLMPlugin

class LLMPluginTests: XCTestCase {
    func testEcho() {
        // This is an example of a functional test case for a plugin.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let plugin = LLMPlugin()

        let result = plugin.echo(value: "Hello, World!")

        XCTAssertEqual(result.value, "Hello, World!")
    }
}
