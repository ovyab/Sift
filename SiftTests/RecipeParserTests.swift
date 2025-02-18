import XCTest
@testable import Sift

final class RecipeParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testValidURLParsing() async throws {
        // Test with a known recipe URL
        let url = "https://www.foodandwine.com/recipes/double-chocolate-layer-cake"
        let (ingredients, instructions) = try await RecipeParser.parseRecipe(from: url)
        
        XCTAssertFalse(ingredients.isEmpty, "Recipe should have ingredients")
        XCTAssertFalse(instructions.isEmpty, "Recipe should have instructions")
    }
    
    func testInvalidURL() async {
        // Test with invalid URL
        let invalidURL = "not-a-url"
        do {
            _ = try await RecipeParser.parseRecipe(from: invalidURL)
            XCTFail("Parser should throw an error for invalid URL")
        } catch {
            XCTAssertNotNil(error, "Should throw an error")
        }
    }
} 