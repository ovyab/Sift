import XCTest
@testable import Sift

final class ConfigTests: XCTestCase {
    func testAPIKeyExists() {
        XCTAssertFalse(Config.openAIKey.isEmpty, "API key should not be empty")
        XCTAssertFalse(Config.openAIKey.contains("YOUR_API_KEY_HERE"), "API key should be set to a real value")
    }
    
    func testOpenAIConnection() async {
        let result = await OpenAIService.shared.testAPIKey()
        XCTAssertTrue(result.contains("✅"), "API key should be valid")
    }
} 