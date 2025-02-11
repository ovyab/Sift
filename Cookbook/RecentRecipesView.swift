import SwiftUI

struct RecentRecipesView: View {
    @State private var recentRecipes: [Recipe] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
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
                                .font(Theme.Typography.h2)
                                .foregroundColor(Theme.Colors.light)
                                .lineLimit(2)
                            Text(recipe.urlString)
                                .font(Theme.Typography.p2)
                                .foregroundColor(Theme.Colors.grey)
                                .lineLimit(1)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .navigationTitle("Recent Recipes")
        .onAppear {
            recentRecipes = RecipeStorage.shared.loadRecipes()
        }
    }
} 