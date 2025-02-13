import SwiftUI

struct RecipeCarousel: View {
    private let images = ["Salad", "Cake", "Taco", "Spaghetti", "Curry", "Ramen"]
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // Duplicate the images for seamless infinite scroll
                ForEach(0..<3) { _ in
                    ForEach(images, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .cornerRadius(60)
                    }
                }
            }
            .offset(x: offset)
            .onAppear {
                withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                    // Move by the width of one complete set of images
                    offset = -CGFloat(images.count) * (100 + 16)
                }
            }
        }
        .mask(
            HStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black, .black, .clear]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        )
    }
} 
