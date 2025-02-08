import SwiftUI

struct RecipeDetailView: View {
    let title: String
    let ingredients: [String]
    let instructions: [String]
    let urlString: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                if ingredients.isEmpty || instructions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Unable to Parse Recipe")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("We found a recipe on this page but were unable to extract the ingredients and instructions. This might happen if the recipe is in an unusual format.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Link("View original recipe", destination: URL(string: urlString) ?? URL(string: "https://apple.com")!)
                            .foregroundColor(.blue)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                } else {
                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(ingredients, id: \.self) { ingredient in
                            HStack(alignment: .top) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .padding(.top, 6)
                                Text(ingredient)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    // Instructions Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(instructions.indices, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Step \(index + 1)")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Text(instructions[index])
                                    .font(.body)
                            }
                            .padding(.bottom, 5)
                        }
                    }
                }
            }
            .padding()
        }
    }
} 