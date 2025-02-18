import XCTest
@testable import Sift

final class RecipeStorageTests: XCTestCase {
    var storage: RecipeStorage!
    
    override func setUp() {
        super.setUp()
        storage = RecipeStorage.shared
        // Clear any existing stored recipes
        UserDefaults.standard.removeObject(forKey: "recipes")
    }
    
    func testSaveAndLoadRecipe() {
        // Create a test recipe
        let recipe = Recipe(
            title: "Test Recipe",
            ingredients: ["1 cup sugar", "2 eggs"],
            instructions: ["Mix", "Bake"],
            urlString: "https://example.com/recipe",
            accentColor: 0
        )
        
        // Save recipe
        storage.saveRecipe(recipe)
        
        // Load recipes
        let loadedRecipes = storage.loadRecipes()
        
        XCTAssertFalse(loadedRecipes.isEmpty, "Should have loaded at least one recipe")
        XCTAssertEqual(loadedRecipes.first?.title, recipe.title)
        XCTAssertEqual(loadedRecipes.first?.ingredients, recipe.ingredients)
        XCTAssertEqual(loadedRecipes.first?.instructions, recipe.instructions)
    }
    
    func testDuplicateRecipes() {
        let recipe = Recipe(
            title: "Test Recipe",
            ingredients: ["1 cup sugar"],
            instructions: ["Mix"],
            urlString: "https://example.com/recipe",
            accentColor: 0
        )
        
        // Save same recipe twice
        storage.saveRecipe(recipe)
        storage.saveRecipe(recipe)
        
        let loadedRecipes = storage.loadRecipes()
        
        // Should only have one copy
        XCTAssertEqual(loadedRecipes.count, 1, "Should not save duplicate recipes")
    }
} 