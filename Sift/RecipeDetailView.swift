import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showIngredients = true
    @State private var showInstructions = true
    let title: String
    let ingredients: [String]
    let instructions: [String]
    let urlString: String
    let accentColor: Color
    @State private var checkedIngredients: Set<String> = []
    @State private var checkedInstructions: Set<String> = []
    
    // Helper function to format URL
    private func formatURL(_ urlString: String) -> String {
        if let url = URL(string: urlString) {
            return url.host?.replacingOccurrences(of: "www.", with: "") ?? urlString
        }
        return urlString
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 48) {
                // Title Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(Theme.Typography.title)
                        .lineSpacing(-16)
                        .foregroundColor(accentColor)
                    
                    HStack(spacing: 4) {
                        Text("from")
                            .font(Theme.Typography.p1)
                            .foregroundColor(Theme.Colors.dark)
                        Text(formatURL(urlString))
                            .font(Theme.Typography.p1)
                            .foregroundColor(Theme.Colors.dark)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Link(destination: URL(string: urlString) ?? URL(string: "https://google.com")!) {
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(Theme.Colors.dark)
                        }
                    }
                    
                    Text("Sifted recipe may not be accurate.\nBe sure to double-check with the real recipe.")
                        .font(Theme.Typography.p2)
                        .foregroundColor(Theme.Colors.grey)
                }
                
                // Ingredients Section
                VStack(alignment: .leading, spacing: 16) {
                    Button(action: { 
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { 
                            showIngredients.toggle() 
                        }
                    }) {
                        HStack {
                            Text("Ingredients")
                                .font(Theme.Typography.h1)
                                .foregroundColor(accentColor)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(accentColor)
                                .rotationEffect(.degrees(showIngredients ? 0 : -90))
                        }
                    }
                    
                    if showIngredients {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(ingredients, id: \.self) { ingredient in
                                HStack(alignment: .top, spacing: 12) {
                                    Button(action: {
                                        if checkedIngredients.contains(ingredient) {
                                            checkedIngredients.remove(ingredient)
                                        } else {
                                            checkedIngredients.insert(ingredient)
                                        }
                                    }) {
                                        if checkedIngredients.contains(ingredient) {
                                            // Checked checkbox
                                            ZStack {
                                                Rectangle()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(Theme.Colors.grey)
                                                    .cornerRadius(4)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 4)
                                                            .inset(by: 0.5)
                                                            .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                                                    )
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(Theme.Colors.light)
                                                    .font(.system(size: 12, weight: .bold))
                                            }
                                        } else {
                                            // Unchecked checkbox
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .frame(width: 20, height: 20)
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
                                                .cornerRadius(4)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .inset(by: 0.5)
                                                        .stroke(Theme.Colors.dark, lineWidth: 0.5)
                                                )
                                        }
                                    }
                                    
                                    Text(ingredient)
                                        .font(Theme.Typography.h2)
                                        .foregroundColor(checkedIngredients.contains(ingredient) ? Theme.Colors.grey : Theme.Colors.dark)
                                }
                            }
                        }
                        .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
                    }
                }
                
                // Instructions Section
                VStack(alignment: .leading, spacing: 16) {
                    Button(action: { 
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { 
                            showInstructions.toggle() 
                        }
                    }) {
                        HStack {
                            Text("Instructions")
                                .font(Theme.Typography.h1)
                                .foregroundColor(accentColor)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(accentColor)
                                .rotationEffect(.degrees(showInstructions ? 0 : -90))
                        }
                    }
                    
                    if showInstructions {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(instructions.enumerated()), id: \.element) { index, instruction in
                                HStack(alignment: .top, spacing: 12) {
                                    Button(action: {
                                        if checkedInstructions.contains(instruction) {
                                            checkedInstructions.remove(instruction)
                                        } else {
                                            checkedInstructions.insert(instruction)
                                        }
                                    }) {
                                        if checkedInstructions.contains(instruction) {
                                            // Checked checkbox
                                            ZStack {
                                                Rectangle()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(Theme.Colors.grey)
                                                    .cornerRadius(4)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 4)
                                                            .inset(by: 0.5)
                                                            .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                                                    )
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(Theme.Colors.light)
                                                    .font(.system(size: 12, weight: .bold))
                                            }
                                        } else {
                                            // Unchecked checkbox
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .frame(width: 20, height: 20)
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
                                                .cornerRadius(4)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .inset(by: 0.5)
                                                        .stroke(Theme.Colors.dark, lineWidth: 0.5)
                                                )
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("STEP \(index + 1)")
                                            .font(Theme.Typography.eyebrow)
                                            .foregroundColor(Theme.Colors.grey)
                                        Text(instruction)
                                            .font(Theme.Typography.h2)
                                            .foregroundColor(checkedInstructions.contains(instruction) ? Theme.Colors.grey : Theme.Colors.dark)
                                    }
                                }
                            }
                        }
                        .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
                    }
                }
            }
            .padding(16)
        }
        .background(.white)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            dismiss()
        }) {
            Text("← Back")
                .font(Theme.Typography.p1)
            .foregroundColor(Theme.Colors.dark)
        })
    }
} 
