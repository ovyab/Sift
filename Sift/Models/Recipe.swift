import Foundation
import SwiftUI

struct Recipe: Identifiable, Codable {
    let id: UUID
    let title: String
    let ingredients: [String]
    let instructions: [String]
    let urlString: String
    let accentColor: Int // Store index of the color
    
    init(title: String, ingredients: [String], instructions: [String], urlString: String, accentColor: Int) {
        self.id = UUID()
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions
        self.urlString = urlString
        self.accentColor = accentColor
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
