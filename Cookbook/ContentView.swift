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
                    .frame(height: 50)

                // Carousel
                RecipeCarousel()
                    .frame(height: 200)
                // Title Section
                VStack(spacing: 12) {
                    Text("Make online\nrecipes easier\nto read")
                        .font(Theme.Typography.title)
                        .lineSpacing(-48) // Adjusted line spacing for tighter text
                        .multilineTextAlignment(.center)
                        .foregroundColor(Theme.Colors.light)
                    Text("Sift uses AI to convert online recipes\ninto clean, user-friendly ones in seconds.")
                        .font(Theme.Typography.p1)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Theme.Colors.light)
                }
                
                // Input and Buttons Section
                VStack(spacing: 16) {
                    // URL Input
                    HStack {
                        TextField("Paste a recipe URL →", text: $urlString)
                            .font(Theme.Typography.p1)
                            .foregroundColor(Theme.Colors.light)
                            .padding(.leading, 24)
                        Button(action: {
                            if let clipboardString = UIPasteboard.general.string {
                                urlString = clipboardString
                            }
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(Theme.Colors.green)
                                .frame(width: 44, height: 44)
                                .background(Theme.Colors.light)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 8)
                    }
                    .frame(height: 56)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(red: 1, green: 1, blue: 1).opacity(0.06), Color(red: 1, green: 1, blue: 1).opacity(0.02)]), startPoint: .topTrailing, endPoint: .bottomLeading)
)   
                    .cornerRadius(28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    
                    // Buttons
                    Button {
                        Task {
                            await fetchRecipe()
                        }
                    } label: {
                        if isLoading {
                            HStack {
                                Text("Sifting through recipe...")
                                ProgressView()
                                    .tint(.white)
                            }
                        } else {
                            Text("Sift recipe")
                        }
                    }
                    .buttonStyle(Theme.PrimaryButtonStyle(isEnabled: !urlString.isEmpty))
                    .disabled(urlString.isEmpty || isLoading)
                    NavigationLink("View recent recipes") {
                        RecentRecipesView()
                    }
                    .buttonStyle(Theme.SecondaryButtonStyle())
                }
                .padding(.horizontal, 24)
                
                Spacer()
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
                    urlString: urlString,
                    accentColor: Theme.Colors.purple
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

