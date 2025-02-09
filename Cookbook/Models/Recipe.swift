import Foundation

struct Recipe: Identifiable, Codable {
    let id: UUID
    let title: String
    let ingredients: [String]
    let instructions: [String]
    let urlString: String
    let dateAccessed: Date
    
    init(title: String, ingredients: [String], instructions: [String], urlString: String) {
        self.id = UUID()
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions
        self.urlString = urlString
        self.dateAccessed = Date()
    }
} 