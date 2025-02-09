import Foundation

class RecipeStorage {
    static let shared = RecipeStorage()
    private let key = "savedRecipes"
    
    private init() {}
    
    func saveRecipe(_ recipe: Recipe) {
        var recipes = loadRecipes()
        // Remove duplicate URLs
        recipes.removeAll { $0.urlString == recipe.urlString }
        recipes.insert(recipe, at: 0) // Add new recipe at the beginning
        
        // Keep only the 10 most recent recipes
        if recipes.count > 10 {
            recipes = Array(recipes.prefix(10))
        }
        
        if let encoded = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func loadRecipes() -> [Recipe] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let recipes = try? JSONDecoder().decode([Recipe].self, from: data) else {
            return []
        }
        return recipes
    }
} 