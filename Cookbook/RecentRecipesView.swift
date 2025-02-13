import SwiftUI

struct RecentRecipesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recentRecipes: [Recipe] = []
    
    private let cardColors: [Color] = [
        Theme.Colors.purple,
        Theme.Colors.yellow,
        Theme.Colors.darkGreen,
        Theme.Colors.green
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Title Section
                HStack {
                    Text("Recent Recipes")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.Colors.dark)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Recipe Cards
                ForEach(Array(recentRecipes.enumerated()), id: \.element.id) { index, recipe in
                    NavigationLink(destination: RecipeDetailView(
                        title: recipe.title,
                        ingredients: recipe.ingredients,
                        instructions: recipe.instructions,
                        urlString: recipe.urlString,
                        accentColor: cardColors[recipe.accentColor]
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.title)
                                .font(Theme.Typography.h1)
                                .foregroundColor(cardColors[recipe.accentColor])
                                .multilineTextAlignment(.leading)
                            Text("from " + formatURL(recipe.urlString))
                                .font(Theme.Typography.eyebrow)
                                .foregroundColor(Theme.Colors.dark.opacity(0.6))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(.white)    
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(cardColors[recipe.accentColor].opacity(0.5), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Theme.Colors.light)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            dismiss()
        }) {
            Text("← Back")
                .font(Theme.Typography.p1)
            .foregroundColor(Theme.Colors.dark)    
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
