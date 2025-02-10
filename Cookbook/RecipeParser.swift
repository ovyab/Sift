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
            }
            
            // Try to parse recipe content directly first
            var ingredients: [String] = []
            var instructions: [String] = []
            
            // Look for structured recipe content
            let recipeInstructionsSection = try doc.select(".recipe-instructions, .instructions, ol[itemprop='recipeInstructions']")
            let recipeIngredientsSection = try doc.select(".recipe-ingredients, .ingredients, [itemprop='recipeIngredient']")
            
            if !recipeInstructionsSection.isEmpty() && !recipeIngredientsSection.isEmpty() {
                // Parse ingredients
                for ingredient in try recipeIngredientsSection.select("li") {
                    let text = try ingredient.text().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !text.isEmpty {
                        ingredients.append(text)
                    }
                }
                
                // Parse instructions
                for instruction in try recipeInstructionsSection.select("li, p") {
                    let text = try instruction.text().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !text.isEmpty && !text.lowercased().contains("note:") {
                        instructions.append(text)
                    }
                }
                
                if !ingredients.isEmpty && !instructions.isEmpty {
                    print("✅ Successfully parsed recipe directly")
                    return (ingredients, instructions)
                }
            }
            
            // If direct parsing fails, fall back to OpenAI
            print("🤖 Falling back to OpenAI parsing...")
            return try await OpenAIService.shared.extractRecipeContent(from: html)
            
        } catch {
            print("❌ Error during parsing: \(error)")
            throw RecipeParserError.openAIParsingFailed(error.localizedDescription)
        }
    }
} 