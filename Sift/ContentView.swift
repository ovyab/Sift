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
        ZStack {
            ScrollView {
                VStack(spacing: 48) {
                    VStack {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40)
                            .padding(.top, 80)
                    }
                    
                    Spacer()
                        .frame(height: 100)
                    
                    VStack(spacing: 12) {
                        Text("Make long recipes easy to read") 
                            .font(Theme.Typography.title)
                            .lineSpacing(-64)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Theme.Colors.dark)
                        Text("Enter a recipe URL and Sift spits out a\nclean, user friendly version.")
                            .font(Theme.Typography.p1)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Theme.Colors.dark)

                         Spacer()
                        .frame(height: 16)
                        
                        // Input and Buttons Section
                        VStack(spacing: 16) {
                            // URL Input
                            HStack {
                                TextField("Paste a recipe URL →", text: $urlString)
                                    .font(Theme.Typography.p1)
                                    .foregroundColor(Theme.Colors.dark)
                                    .padding(.leading, 24)
                                   
                                Button(action: {
                                    if let clipboardString = UIPasteboard.general.string {
                                        urlString = clipboardString
                                    }
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(Theme.Colors.light)
                                        .frame(width: 44, height: 44)
                                        .background(Theme.Colors.darkGreen)
                                        .clipShape(Circle())
                                }
                                .padding(.trailing, 8)
                            }
                            .frame(height: 56)
                            .background(.white)
                            .cornerRadius(28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Theme.Colors.dark.opacity(0.5), lineWidth: 1)
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
                            NavigationLink("View recent recipes →") {
                                RecentRecipesView()
                            }
                            .buttonStyle(Theme.SecondaryButtonStyle())
                        }
                        .padding(.horizontal, 16)
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, Theme.Colors.light]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    Spacer()
                }
                .frame(maxWidth: 600)
            }
            .background(
                ZStack {
                    Image("LandingImage")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea()
                        .alignmentGuide(.top) { _ in 0 }
                }
                , alignment: .top)
        }
        .background(Theme.Colors.light)
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
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
