import SwiftUI
import SwiftSoup

struct RecipeTestResult: Identifiable {
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

struct RecipeTestView: View {
    @State private var testResults: [RecipeTestResult] = []
    @State private var isLoading = false
    
    // Add your URLs here
    let testUrls = [
        "https://www.allrecipes.com/recipe/16354/easy-meatloaf/",
        "https://www.thekitchn.com/how-to-make-braised-short-ribs-105868",
        "https://pinchofyum.com/the-best-soft-chocolate-chip-cookies",
        "https://tastesbetterfromscratch.com/chicken-noodle-soup/",
        "https://www.simplyrecipes.com/recipes/banana_bread/"
        // Add more URLs here
    ]
    
    func testRecipes() async {
        isLoading = true
        testResults = []
        
        for url in testUrls {
            await testSingleRecipe(urlString: url)
            // Add a delay between requests to avoid rate limits
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        isLoading = false
    }
    
    func testSingleRecipe(urlString: String) async {
        guard let url = URL(string: urlString) else {
            testResults.append(RecipeTestResult(
                url: urlString,
                title: "Invalid URL",
                ingredientsCount: 0,
                instructionsCount: 0,
                isSuccess: false,
                error: "Invalid URL format",
                ingredients: [],
                instructions: []
            ))
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let htmlContent = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not decode HTML"])
            }
            
            let doc = try SwiftSoup.parse(htmlContent)
            var title = try doc.select("h1").first()?.text() ?? "Unknown Title"
            
            print("Testing URL: \(urlString)")
            let (ingredients, instructions) = try await RecipeParser.parseRecipe(from: htmlContent)
            
            DispatchQueue.main.async {
                let result = RecipeTestResult(
                    url: urlString,
                    title: title,
                    ingredientsCount: ingredients.count,
                    instructionsCount: instructions.count,
                    isSuccess: !ingredients.isEmpty && !instructions.isEmpty,
                    error: nil,
                    ingredients: ingredients,
                    instructions: instructions
                )
                testResults.append(result)
            }
            
        } catch let error as RecipeParserError {
            DispatchQueue.main.async {
                testResults.append(RecipeTestResult(
                    url: urlString,
                    title: "Error",
                    ingredientsCount: 0,
                    instructionsCount: 0,
                    isSuccess: false,
                    error: error.description,
                    ingredients: [],
                    instructions: []
                ))
            }
        } catch {
            DispatchQueue.main.async {
                testResults.append(RecipeTestResult(
                    url: urlString,
                    title: "Error",
                    ingredientsCount: 0,
                    instructionsCount: 0,
                    isSuccess: false,
                    error: "Error: \(error.localizedDescription)",
                    ingredients: [],
                    instructions: []
                ))
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                if isLoading {
                    ProgressView("Testing recipes...")
                } else {
                    ForEach(testResults.sorted { $0.url < $1.url }) { result in
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
            .navigationTitle("Recipe Parser Test")
            .toolbar {
                Button("Run Tests") {
                    Task {
                        await testRecipes()
                    }
                }
            }
        }
    }
}

#Preview {
    RecipeTestView()
} 