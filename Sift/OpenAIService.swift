import Foundation
import SwiftSoup

// Basic OpenAI response models
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

enum OpenAIError: Error {
    case invalidResponse
    case jsonParsingFailed(String)
    case missingContent
    case apiError(String)
    
    var description: String {
        switch self {
        case .invalidResponse:
            return "Invalid response from OpenAI"
        case .jsonParsingFailed(let error):
            return "Failed to parse JSON: \(error)"
        case .missingContent:
            return "No content in OpenAI response"
        case .apiError(let message):
            return "API Error: \(message)"
        }
    }
}

// Model for structured ingredients with both possible property names
struct Ingredient: Codable {
    let quantity: String?
    let unit: String?
    private let name: String?
    private let ingredient: String?
    
    // Custom coding keys to handle both "name" and "ingredient" properties
    enum CodingKeys: String, CodingKey {
        case quantity
        case unit
        case name
        case ingredient
    }
    
    // Custom initializer to handle both structured and string formats
    init(from decoder: Decoder) throws {
        // First, try to decode as a string
        if let stringValue = try? decoder.singleValueContainer().decode(String.self) {
            // If it's a string, set it as the ingredient name
            self.quantity = nil
            self.unit = nil
            self.name = stringValue
            self.ingredient = nil
            return
        }
        
        // If it's not a string, decode as structured ingredient
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.quantity = try container.decodeIfPresent(String.self, forKey: .quantity)
        self.unit = try container.decodeIfPresent(String.self, forKey: .unit)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.ingredient = try container.decodeIfPresent(String.self, forKey: .ingredient)
    }
    
    // Computed property to get the ingredient name from either property
    var ingredientName: String {
        return name ?? ingredient ?? ""
    }
    
    func toString() -> String {
        // If it's a simple string ingredient (no quantity/unit)
        if let name = name, quantity == nil && unit == nil {
            return name
        }
        
        let qty = quantity ?? ""
        let unt = unit ?? ""
        
        // Build the string based on which components are present
        if qty.isEmpty && unt.isEmpty {
            return ingredientName
        } else if unt.isEmpty {
            return "\(qty) \(ingredientName)".trimmingCharacters(in: .whitespaces)
        } else {
            return "\(qty) \(unt) \(ingredientName)".trimmingCharacters(in: .whitespaces)
        }
    }
}

// Updated recipe response model to match the actual JSON structure
struct RecipeJSON: Codable {
    let ingredients: [Ingredient]
    let instructions: [String]
}

class OpenAIService {
    static let shared = OpenAIService()
    
    private let apiKey: String = "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" // Replace with your actual API key
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    private init() {} // Make constructor private for singleton
    
    private func cleanHTML(_ html: String) throws -> String {
        do {
            let doc = try SwiftSoup.parse(html)
            
            // Remove non-content elements but keep recipe-related sections
            try doc.select("script, style, meta, link, noscript, header, footer, nav, .advertisement").remove()
            
            var recipeText = ""
            
            // First try to find recipe content by schema markup
            let recipeSchema = try doc.select("[itemtype*=Recipe]")
            if !recipeSchema.isEmpty() {
                recipeText = try recipeSchema.text()
            }
            
            // If no schema, look for recipe card sections
            if recipeText.isEmpty {
                let recipeCard = try doc.select(".recipe-card, .recipe-content, [class*=recipe], [id*=recipe], .ingredients, .instructions")
                if !recipeCard.isEmpty() {
                    recipeText = try recipeCard.text()
                }
            }
            
            // If still empty, look for structured content
            if recipeText.isEmpty {
                // Find ingredient list
                for element in try doc.select("ul, ol") {
                    let elementText = try element.text().lowercased()
                    if elementText.contains("ingredient") || elementText.contains("you'll need") {
                        recipeText += "INGREDIENTS:\n"
                        recipeText += try element.text() + "\n\n"
                        break
                    }
                }
                
                // Find instructions list
                for element in try doc.select("ol, div") {
                    let elementText = try element.text().lowercased()
                    if elementText.contains("instruction") || elementText.contains("direction") || elementText.contains("steps") {
                        recipeText += "INSTRUCTIONS:\n"
                        recipeText += try element.text() + "\n\n"
                        break
                    }
                }
            }
            
            // If still empty, try to find any recipe-like content
            if recipeText.isEmpty {
                for element in try doc.select("article, main, .content") {
                    let elementText = try element.text().lowercased()
                    if elementText.contains("ingredient") || elementText.contains("instruction") || elementText.contains("recipe") {
                        recipeText = try element.text()
                        break
                    }
                }
            }
            
            print("📝 Found content length: \(recipeText.count) characters")
            
            // If we got too much content, try to trim it intelligently
            if recipeText.count > 8000 {
                // Find the first occurrence of ingredients/instructions
                let startKeywords = ["ingredient", "instruction", "direction", "step"]
                var startIndex = recipeText.count
                
                for keyword in startKeywords {
                    if let index = recipeText.lowercased().range(of: keyword)?.lowerBound {
                        let distance = recipeText.distance(from: recipeText.startIndex, to: index)
                        startIndex = min(startIndex, distance)
                    }
                }
                
                // Take content from just before the first keyword
                let safeStartIndex = max(0, startIndex - 50)
                recipeText = String(recipeText.dropFirst(safeStartIndex).prefix(8000))
            }
            
            return recipeText
            
        } catch {
            print("⚠️ HTML cleaning failed: \(error)")
            return String(html.prefix(8000))
        }
    }
    
    func extractRecipeContent(from html: String) async throws -> (ingredients: [String], instructions: [String]) {
        print("🔄 Starting OpenAI request...")
        
        // Clean and trim the HTML
        let cleanedContent = try cleanHTML(html)
        print("📝 Cleaned content length: \(cleanedContent.count) characters")
        
        let prompt = """
        You are a recipe parser. Extract the ingredients and instructions from this recipe content.
        
        Rules:
        1. Always return a JSON object with "ingredients" and "instructions" arrays
        2. For ingredients, include quantities and units
        3. For instructions, keep each step separate
        4. If you can't find any recipe content, return empty arrays
        5. Format as: {"ingredients": [...], "instructions": [...]}
        
        Recipe Content:
        \(cleanedContent)
        """
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": "You are a specialized recipe parsing assistant. You extract recipe ingredients and instructions from any text content."],
            ["role": "user", "content": prompt]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": 0.3,
            "max_tokens": 1000,
            "response_format": ["type": "json_object"]  // Force JSON response
        ]
        
        do {
            var request = URLRequest(url: URL(string: endpoint)!)
            request.httpMethod = "POST"
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            print("📤 Sending request to OpenAI...")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 Response status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    throw OpenAIError.apiError("Status code: \(httpResponse.statusCode)")
                }
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            guard let content = openAIResponse.choices.first?.message.content else {
                throw OpenAIError.missingContent
            }
            
            print("📝 Received response: \(content)")
            
            guard let jsonData = content.data(using: .utf8) else {
                throw OpenAIError.jsonParsingFailed("Could not convert content to data")
            }
            
            // Parse the structured JSON response
            let recipeJSON = try JSONDecoder().decode(RecipeJSON.self, from: jsonData)
            
            // Convert structured ingredients to strings
            let ingredients = recipeJSON.ingredients.map { $0.toString() }
            
            // Validate the results
            if ingredients.isEmpty && recipeJSON.instructions.isEmpty {
                print("⚠️ Warning: OpenAI returned empty arrays")
            } else {
                print("✅ Successfully parsed recipe with \(ingredients.count) ingredients and \(recipeJSON.instructions.count) instructions")
            }
            
            return (ingredients, recipeJSON.instructions)
            
        } catch let decodingError as DecodingError {
            print("❌ Decoding error: \(decodingError)")
            throw OpenAIError.jsonParsingFailed(decodingError.localizedDescription)
        } catch {
            print("❌ Error in OpenAI request: \(error)")
            throw error
        }
    }
    
    func testAPIKey() async -> String {
        let messages: [[String: Any]] = [
            ["role": "system", "content": "You are a helpful assistant."],
            ["role": "user", "content": "Please respond with 'API key is working!' if you receive this message."]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": 0.3,
            "max_tokens": 50
        ]
        
        do {
            var request = URLRequest(url: URL(string: endpoint)!)
            request.httpMethod = "POST"
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 401:
                    return "❌ Error: Invalid API key"
                case 429:
                    return "❌ Error: Rate limit exceeded"
                case 500:
                    return "❌ Error: OpenAI server error"
                case 200:
                    let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    if let content = response.choices.first?.message.content {
                        return "✅ \(content)"
                    }
                default:
                    return "❌ Error: Unexpected status code \(httpResponse.statusCode)"
                }
            }
            
            return "❌ Error: No response from server"
        } catch {
            return "❌ Error: \(error.localizedDescription)"
        }
    }
}