import Foundation
import SwiftSoup

enum RecipeParserError: Error {
    case emptyHTML
    case titleParsingFailed(String)
    case openAIParsingFailed(String)
    case noContentFound
    
    var description: String {
        switch self {
        case .emptyHTML:
            return "The HTML content is empty"
        case .titleParsingFailed(let error):
            return "Failed to parse title: \(error)"
        case .openAIParsingFailed(let error):
            return "OpenAI parsing failed: \(error)"
        case .noContentFound:
            return "No recipe content was found"
        }
    }
}

class RecipeParser {
    static func parseRecipe(from html: String) async throws -> (ingredients: [String], instructions: [String]) {
        // Validate input
        guard !html.isEmpty else {
            print("❌ Error: Empty HTML content")
            throw RecipeParserError.emptyHTML
        }
        
        // Get the title first (still useful for display)
        var title = ""
        do {
            let doc = try SwiftSoup.parse(html)
            if let titleElement = try doc.select("h1").first() {
                title = try titleElement.text()
                print("✅ Successfully parsed title: \(title)")
            } else {
                print("⚠️ Warning: No title found in HTML")
            }
        } catch {
            print("❌ Error parsing title: \(error)")
            throw RecipeParserError.titleParsingFailed(error.localizedDescription)
        }
        
        // Use OpenAI as primary parser
        do {
            print("🤖 Sending request to OpenAI...")
            let result = try await OpenAIService.shared.extractRecipeContent(from: html)
            
            // Validate the results
            if result.ingredients.isEmpty && result.instructions.isEmpty {
                print("❌ Error: OpenAI returned empty content")
                throw RecipeParserError.noContentFound
            }
            
            print("✅ Successfully parsed recipe:")
            print("📝 Found \(result.ingredients.count) ingredients")
            print("📝 Found \(result.instructions.count) instructions")
            
            // Log the first few items of each (for debugging)
            if !result.ingredients.isEmpty {
                print("📌 First ingredient: \(result.ingredients[0])")
            }
            if !result.instructions.isEmpty {
                print("📌 First instruction: \(result.instructions[0])")
            }
            
            return result
            
        } catch {
            print("❌ Error during OpenAI parsing: \(error)")
            throw RecipeParserError.openAIParsingFailed(error.localizedDescription)
        }
    }
} 