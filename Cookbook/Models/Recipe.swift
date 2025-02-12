import Foundation
import SwiftUI

struct Recipe: Identifiable, Codable {
    let id: UUID
    let title: String
    let ingredients: [String]
    let instructions: [String]
    let urlString: String
    let accentColor: Int // Store index of the color
    
    init(title: String, ingredients: [String], instructions: [String], urlString: String) {
        self.id = UUID()
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions
        self.urlString = urlString
        self.accentColor = Int.random(in: 0...4) // Random index for 5 colors
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case ingredients
        case instructions
        case urlString
        case accentColor
    }
}
