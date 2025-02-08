import SwiftUI
import SwiftSoup

struct RecipeView: View {
    @State private var urlString: String = ""
    @State private var recipeTitle: String = ""
    @State private var recipeInstructions: [String] = []
    @State private var recipeIngredients: [String] = []
    @State private var isLoading = false
    @State private var showRecipe = false
    @State private var errorMessage: String? = nil
    @State private var showError = false

    var body: some View {
        VStack {
            TextField("Enter recipe URL", text: $urlString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Get Recipe") {
                Task {
                    await fetchRecipe()
                }
            }
            .padding()
            
            if isLoading {
                ProgressView()
            }
        }
        .navigationTitle("Recipe Parser")
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .sheet(isPresented: $showRecipe) {
            if !recipeIngredients.isEmpty && !recipeInstructions.isEmpty {
                RecipeDetailView(
                    title: recipeTitle,
                    ingredients: recipeIngredients,
                    instructions: recipeInstructions,
                    urlString: urlString
                )
            }
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
            
            DispatchQueue.main.async {
                self.recipeIngredients = ingredients
                self.recipeInstructions = instructions
                self.isLoading = false
                
                if ingredients.isEmpty || instructions.isEmpty {
                    self.errorMessage = "Could not find recipe content"
                    self.showError = true
                } else {
                    self.showRecipe = true
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.showError = true
                self.isLoading = false
            }
        }
    }
}

#Preview {
    RecipeView()
}

struct ContentView: View {
    var body: some View {
        TabView {
            RecipeView()
                .tabItem {
                    VStack {
                        Image(systemName: "fork.knife")
                        Text("Recipe")
                    }
                }
                .tag(0)
            
            RecipeTestView()
                .tabItem {
                    VStack {
                        Image(systemName: "checklist")
                        Text("Test")
                    }
                }
                .tag(1)
            
            OpenAIKeyTester()
                .tabItem {
                    VStack {
                        Image(systemName: "key")
                        Text("API Key")
                    }
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
