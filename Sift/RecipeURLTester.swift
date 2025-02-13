import SwiftUI
import SwiftSoup

struct RecipeURLTester {
    struct TestResult: Identifiable {
        let id = UUID()
        let url: String
        var title: String
        var ingredientsCount: Int
        var instructionsCount: Int
        var isSuccess: Bool
        var error: String?
        var ingredients: [String]
        var instructions: [String]
    }
    
    static let testUrls = [
    "https://www.allrecipes.com/recipe/16354/easy-meatloaf/",
    "https://cookpad.com/us/recipes/154537-easy-homemade-pancakes",
    "https://www.russianfood.com/recipes/recipe.php?rid=149523",
    "https://www.giallozafferano.it/ricetta/Tiramisu.html",
    "https://www.kurashiru.com/recipes/311f5c5d-2b8b-4b8b-8f5c-5d2b8b4b8b8f",
    "https://www.tudogostoso.com.br/receita/1103-brigadeiro.html",
    "https://www.marmiton.org/recettes/recette_quiche-lorraine_13867.aspx",
    "https://www.bbcgoodfood.com/recipes/ultimate-spaghetti-carbonara-recipe",
    "https://www.chefkoch.de/rezepte/589911160925437/Kaesespaetzle.html",
    "https://www.foodnetwork.com/recipes/food-network-kitchen/the-best-chicken-parmesan-7463310",
    "https://delishkitchen.tv/recipes/267",
    "https://www.recipetineats.com/chicken-alfredo-pasta/",
    "https://lettuceclub.net/recipes/caesar-salad",
    "https://www.thekitchn.com/how-to-make-lasagna-228009",
    "https://1000.menu/cooking/1830-olivie-salat-klassicheskii-recept-s-kolbasoi",
    "https://parade.com/979084/parade/banana-bread/",
    "https://www.simplyrecipes.com/recipes/classic_french_toast/",
    "https://sallysbakingaddiction.com/chewy-chocolate-chip-cookies/",
    "https://www.tasteofhome.com/recipes/classic-meatloaf/",
    "https://aniagotuje.pl/przepis/pierogi-ruskie",
    "https://www.cuisineaz.com/recettes/ratatouille-4670.aspx",
    "https://www.delish.com/cooking/recipe-ideas/a2254/chicken-parmesan-recipe/",
    "https://macaro-ni.jp/recipe/2345",
    "https://www.thepioneerwoman.com/food-cooking/recipes/a11786/beef-stroganoff/",
    "https://www.seriouseats.com/perfect-scrambled-eggs-recipe",
    "https://www.food.com/recipe/best-ever-banana-bread-2886",
    "https://oceans-nadia.com/user/1/recipe/12345",
    "https://www.eatingwell.com/recipe/252504/healthy-chicken-stir-fry/",
    "https://www.nefisyemektarifleri.com/lahmacun/",
    "https://www.loveandlemons.com/vegan-mac-and-cheese/"
    ]
    
    static func testSingleRecipe(urlString: String) async -> TestResult {
        guard let url = URL(string: urlString) else {
            return TestResult(
                url: urlString,
                title: "Invalid URL",
                ingredientsCount: 0,
                instructionsCount: 0,
                isSuccess: false,
                error: "Invalid URL format",
                ingredients: [],
                instructions: []
            )
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let htmlContent = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not decode HTML"])
            }
            
            let doc = try SwiftSoup.parse(htmlContent)
            let title = try doc.select("h1").first()?.text() ?? "Unknown Title"
            
            let (ingredients, instructions) = try await RecipeParser.parseRecipe(from: htmlContent)
            
            return TestResult(
                url: urlString,
                title: title,
                ingredientsCount: ingredients.count,
                instructionsCount: instructions.count,
                isSuccess: !ingredients.isEmpty && !instructions.isEmpty,
                error: ingredients.isEmpty || instructions.isEmpty ? "No recipe content found" : nil,
                ingredients: ingredients,
                instructions: instructions
            )
        } catch {
            return TestResult(
                url: urlString,
                title: "Error",
                ingredientsCount: 0,
                instructionsCount: 0,
                isSuccess: false,
                error: error.localizedDescription,
                ingredients: [],
                instructions: []
            )
        }
    }
}

// Preview-only test view
struct RecipeURLTesterView: View {
    @State private var results: [RecipeURLTester.TestResult] = []
    @State private var isLoading = false
    
    var body: some View {
        List {
            if isLoading {
                ProgressView("Testing URLs...")
            } else {
                ForEach(results) { result in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(result.title)
                            .font(.headline)
                        Text(result.url)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Image(systemName: result.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(result.isSuccess ? .green : .red)
                            Text("Ingredients: \(result.ingredientsCount)")
                            Text("Instructions: \(result.instructionsCount)")
                        }
                        
                        if let error = result.error {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        if result.isSuccess {
                            DisclosureGroup("Show Content") {
                                VStack(alignment: .leading) {
                                    Text("Ingredients:")
                                        .font(.headline)
                                    ForEach(result.ingredients, id: \.self) { ingredient in
                                        Text("• \(ingredient)")
                                    }
                                    
                                    Text("Instructions:")
                                        .font(.headline)
                                        .padding(.top)
                                    ForEach(Array(result.instructions.enumerated()), id: \.element) { index, instruction in
                                        Text("\(index + 1). \(instruction)")
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .task {
            await runTests()
        }
    }
    
    func runTests() async {
        isLoading = true
        results = []
        
        for url in RecipeURLTester.testUrls {
            let result = await RecipeURLTester.testSingleRecipe(urlString: url)
            results.append(result)
            // Add a 1-second delay between requests
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        isLoading = false
    }
}

#Preview {
    RecipeURLTesterView()
} 