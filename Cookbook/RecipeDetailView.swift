import SwiftUI

struct RecipeDetailView: View {
    let title: String
    let ingredients: [String]
    let instructions: [String]
    let urlString: String
    @State private var checkedIngredients: Set<String> = []
    @State private var isIngredientsExpanded = true
    @State private var isInstructionsExpanded = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.title)
                    .bold()
                    .padding(.horizontal)
                
                // Ingredients section
                DisclosureGroup(
                    isExpanded: $isIngredientsExpanded,
                    content: {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(ingredients, id: \.self) { ingredient in
                                HStack {
                                    Button(action: {
                                        if checkedIngredients.contains(ingredient) {
                                            checkedIngredients.remove(ingredient)
                                        } else {
                                            checkedIngredients.insert(ingredient)
                                        }
                                    }) {
                                        Image(systemName: checkedIngredients.contains(ingredient) ? "checkmark.square.fill" : "square")
                                            .foregroundColor(checkedIngredients.contains(ingredient) ? .gray : .primary)
                                    }
                                    Text(ingredient)
                                        .foregroundColor(checkedIngredients.contains(ingredient) ? .gray : .primary)
                                        .strikethrough(checkedIngredients.contains(ingredient))
                                }
                            }
                        }
                        .padding(.leading)
                    },
                    label: {
                        Text("Ingredients")
                            .font(.title2)
                            .bold()
                    }
                )
                .padding(.horizontal)
                
                // Instructions section
                DisclosureGroup(
                    isExpanded: $isInstructionsExpanded,
                    content: {
                        VStack(alignment: .leading, spacing: 15) {
                            ForEach(Array(instructions.enumerated()), id: \.element) { index, instruction in
                                HStack(alignment: .top) {
                                    Text("\(index + 1).")
                                        .bold()
                                        .frame(width: 25, alignment: .leading)
                                    Text(instruction)
                                }
                            }
                        }
                        .padding(.leading)
                    },
                    label: {
                        Text("Instructions")
                            .font(.title2)
                            .bold()
                    }
                )
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
} 