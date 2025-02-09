import SwiftUI
import SwiftSoup

struct RecipeView: View {
    @State private var urlString: String = ""
    @State private var recipeTitle: String = ""
    @State private var recipeInstructions: [String] = []
    @State private var recipeIngredients: [String] = []
    @State private var isLoading = false
    @State private var navigateToRecipe = false
    @State private var errorMessage: String? = nil
    @State private var showError = false
    @State private var recentRecipes: [Recipe] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // URL Input Section
                VStack {
                    TextField("Enter recipe URL", text: $urlString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Get Recipe") {
                        Task {
                            await fetchRecipe()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    
                    if isLoading {
                        ProgressView()
                    }
                }
                
                // Recent Recipes Section
                if !recentRecipes.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recently Prettified Recipes")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(recentRecipes) { recipe in
                            NavigationLink(
                                destination: RecipeDetailView(
                                    title: recipe.title,
                                    ingredients: recipe.ingredients,
                                    instructions: recipe.instructions,
                                    urlString: recipe.urlString
                                )
                            ) {
                                VStack(alignment: .leading) {
                                    Text(recipe.title)
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                    Text(recipe.urlString)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .navigationTitle("Recipe Parser")
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .background(
            NavigationLink(
                destination: RecipeDetailView(
                    title: recipeTitle,
                    ingredients: recipeIngredients,
                    instructions: recipeInstructions,
                    urlString: urlString
                ),
                isActive: $navigateToRecipe
            ) { EmptyView() }
        )
        .onAppear {
            recentRecipes = RecipeStorage.shared.loadRecipes()
        }
    }
    
    func fetchRecipe() async {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            showError = true
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let htmlContent = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not decode HTML"])
            }
            
            let doc = try SwiftSoup.parse(htmlContent)
            if let titleElement = try doc.select("h1").first() {
                recipeTitle = try titleElement.text()
            }
            
            let (ingredients, instructions) = try await RecipeParser.parseRecipe(from: htmlContent)
            
            await MainActor.run {
                self.recipeIngredients = ingredients
                self.recipeInstructions = instructions
                self.isLoading = false
                
                if ingredients.isEmpty || instructions.isEmpty {
                    self.errorMessage = "Could not find recipe content"
                    self.showError = true
                } else {
                    // Save recipe before navigating
                    let recipe = Recipe(
                        title: recipeTitle,
                        ingredients: ingredients,
                        instructions: instructions,
                        urlString: urlString
                    )
                    RecipeStorage.shared.saveRecipe(recipe)
                    recentRecipes = RecipeStorage.shared.loadRecipes()
                    self.navigateToRecipe = true
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showError = true
                self.isLoading = false
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            RecipeView()
        }
    }
}

#Preview {
    ContentView()
}
