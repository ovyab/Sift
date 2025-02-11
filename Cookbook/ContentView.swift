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
            VStack(spacing: 48) {
                // Spacer to push content down
                Spacer()
                    .frame(height: 160)  // Fixed height of 300pt from top
                
                // Title Section
                VStack(spacing: 16) {
                    Text("Make online recipes\neasier to read")
                        .font(Font.custom("InstrumentSerif-Regular", size: 48))
                        .tracking(-0.02)
                        .lineSpacing(-24)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(Theme.Colors.light)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                    
                    Text("Paste a recipe URL, and Sift returns a clean,\nuser-friendly version in seconds.")
                        .font(Theme.Typography.p1)
                        .foregroundColor(Theme.Colors.grey)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                }
                
                // Input and Buttons Section
                VStack(spacing: 16) {  // Consistent spacing between elements
                    // URL Input
                    HStack(spacing: 6) {
                        TextField("Paste a recipe URL", text: $urlString)
                            .font(Theme.Typography.p1)
                            .foregroundColor(Theme.Colors.light)
                            .padding(.leading, 24)
                        
                        // Copy button
                        Button(action: {
                            if let clipboardString = UIPasteboard.general.string {
                                urlString = clipboardString
                            }
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(Theme.Colors.light)
                                .frame(width: 24, height: 24)
                                .padding(10)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(
                                            colors: [
                                                Color.white.opacity(0),
                                                Color.white.opacity(0.08)
                                            ]
                                        ),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                )
                                .padding(4)
                        }
                    }
                    .frame(height: 53)
                    .background(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    Color.white.opacity(0),
                                    Color.white.opacity(0.08)
                                ]
                            ),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10)
                    .frame(maxWidth: 345)
                    
                    // Sift Recipe Button (Primary)
                    Button(action: {
                        Task {
                            await fetchRecipe()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text("Sift recipe")
                                .font(Theme.Typography.p1)
                                .foregroundColor(Theme.Colors.light)
                        }
                    }
                    .buttonStyle(Theme.PrimaryButtonStyle())
                    
                    // Recent Recipes Button (Secondary)
                    NavigationLink {
                        RecentRecipesView()
                    } label: {
                        HStack(spacing: 6) {
                            Text("View recent recipes")
                                .font(Theme.Typography.p1)
                                .foregroundColor(Theme.Colors.light)
                        }
                    }
                    .buttonStyle(Theme.SecondaryButtonStyle())
                }
                
                if isLoading {
                    ProgressView()
                }
            }
            .frame(maxWidth: 600)
        }
        .background(Theme.Colors.dark)  // Add dark background color
        .edgesIgnoringSafeArea(.all)   // Extend color to edges
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
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
