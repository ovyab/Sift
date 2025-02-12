import SwiftUI

struct RecentRecipesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recentRecipes: [Recipe] = []
    
    private let cardColors: [Color] = [
        Theme.Colors.purple,
        Theme.Colors.butter,
        Theme.Colors.yellow,
        Theme.Colors.green,
        Theme.Colors.pink
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Title Section
                HStack {
                    Text("Recent Recipes")
                        .font(Theme.Typography.h1)
                        .foregroundColor(Theme.Colors.light)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // Recipe Cards
                ForEach(Array(recentRecipes.enumerated()), id: \.element.id) { index, recipe in
                    NavigationLink(destination: RecipeDetailView(
                        title: recipe.title,
                        ingredients: recipe.ingredients,
                        instructions: recipe.instructions,
                        urlString: recipe.urlString,
                        accentColor: cardColors[recipe.accentColor]
                    )) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recipe.title)
                                .font(Theme.Typography.h1)
                                .foregroundColor(Theme.Colors.dark)
                            
                            Text(formatURL(recipe.urlString))
                                .font(Theme.Typography.eyebrow)
                                .foregroundColor(Theme.Colors.dark.opacity(0.6))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(cardColors[recipe.accentColor])
                        .cornerRadius(24)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Theme.Colors.dark)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(Theme.Colors.grey)
        })
        .onAppear {
            recentRecipes = RecipeStorage.shared.loadRecipes()
        }
    }
    
    private func formatURL(_ urlString: String) -> String {
        if let url = URL(string: urlString) {
            return url.host?.replacingOccurrences(of: "www.", with: "") ?? urlString
        }
        return urlString
    }
} 