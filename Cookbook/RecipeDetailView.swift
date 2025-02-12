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
                        .lineSpacing(8)
                        .foregroundColor(accentColor)
                    
                    HStack(spacing: 4) {
                        Text("from")
                            .font(Theme.Typography.p1)
                            .foregroundColor(Theme.Colors.light)
                        Text(formatURL(urlString))
                            .font(Theme.Typography.p1)
                            .foregroundColor(Theme.Colors.light)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Link(destination: URL(string: urlString) ?? URL(string: "https://google.com")!) {
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(Theme.Colors.light)
                        }
                    }
                    
                    Text("Sifted recipe may not be accurate.\nBe sure to double-check with the real recipe.")
                        .font(Theme.Typography.p2)
                        .foregroundColor(Theme.Colors.grey)
                }
                
                // Ingredients Section
                VStack(alignment: .leading, spacing: 16) {
                    Button(action: { 
                        withAnimation(.easeInOut(duration: 0.3)) { 
                            showIngredients.toggle() 
                        }
                    }) {
                        HStack {
                            Text("Ingredients")
                                .font(Theme.Typography.h2)
                                .foregroundColor(accentColor)
                            Spacer()
                            Image(systemName: showIngredients ? "chevron.down" : "chevron.right")
                                .foregroundColor(accentColor)
                        }
                    }
                    
                    if showIngredients {
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
                                                        .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                                                )
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
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
                                                    .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                                            )
                                    }
                                }
                                
                                Text(ingredient)
                                    .font(Theme.Typography.h2)
                                    .foregroundColor(checkedIngredients.contains(ingredient) ? Theme.Colors.grey : Theme.Colors.light)
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                
                // Instructions Section
                VStack(alignment: .leading, spacing: 16) {
                    Button(action: { 
                        withAnimation(.easeInOut(duration: 0.3)) { 
                            showInstructions.toggle() 
                        }
                    }) {
                        HStack {
                            Text("Instructions")
                                .font(Theme.Typography.h2)
                                .foregroundColor(accentColor)
                            Spacer()
                            Image(systemName: showInstructions ? "chevron.down" : "chevron.right")
                                .foregroundColor(accentColor)
                        }
                    }
                    
                    if showInstructions {
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
                                                        .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                                                )
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
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
                                                    .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                                            )
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("STEP \(index + 1)")
                                        .font(Theme.Typography.eyebrow)
                                        .foregroundColor(Theme.Colors.grey)
                                    Text(instruction)
                                        .font(Theme.Typography.h2)
                                        .foregroundColor(checkedInstructions.contains(instruction) ? Theme.Colors.grey : Theme.Colors.light)
                                }
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            .padding(24)
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
    }
} 
