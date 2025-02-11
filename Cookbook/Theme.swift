import SwiftUI

enum Theme {
    enum Colors {
        static let pink = Color(red: 0.984, green: 0.671, blue: 0.851)    // #FBABD9
        static let light = Color(red: 1.0, green: 0.992, blue: 0.988)     // #FFFDFC
        static let butter = Color(red: 0.973, green: 0.906, blue: 0.596)  // #F8E798
        static let green = Color(red: 0.467, green: 0.698, blue: 0.333)   // #77B255
        static let dark = Color(red: 0.075, green: 0.067, blue: 0.055)    // #13110E
        static let yellow = Color(red: 1.0, green: 0.675, blue: 0.200)    // #FFAC33
        static let purple = Color(red: 0.780, green: 0.800, blue: 1.0)    // #C7CCFF
        static let grey = Color(red: 0.51, green: 0.53, blue: 0.59)       // #828697
    }
    
    enum Typography {
        // Title & Heading Styles (Instrument Serif)
        static let title = Font.custom("InstrumentSerif-Regular", size: 38)
        static let h1 = Font.custom("InstrumentSerif-Regular", size: 28)
        
        // Body Styles (Radio Canada)
        static let h2 = Font.custom("RadioCanadaBig-VariableFont_wght", size: 22)
        static let p1 = Font.custom("RadioCanadaBig-VariableFont_wght", size: 17)
        static let p2 = Font.custom("RadioCanadaBig-VariableFont_wght", size: 15)
        static let eyebrow = Font.custom("RadioCanadaBig-VariableFont_wght", size: 15)
    }
    
    enum Spacing {
        static let title: CGFloat = 38
        static let h1: CGFloat = 28
        static let h2: CGFloat = 26.40
        static let p2: CGFloat = 18
    }
}

extension Theme {
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(EdgeInsets(top: 16, leading: 10, bottom: 16, trailing: 10))
                .frame(width: 345, height: 54)
                .background(
LinearGradient(gradient: Gradient(colors: [Color(red: 1, green: 1, blue: 1).opacity(0), Color(red: 1, green: 1, blue: 1).opacity(0.08)]), startPoint: .top, endPoint: .bottom)
)
                .cornerRadius(24)
                .overlay(
                    Color.green.opacity(0.2) // 50% green overlay
                        .cornerRadius(24)
                        .blendMode(.multiply) // Ensure it blends with the background
                )
        }
    }
    
    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(EdgeInsets(top: 16, leading: 10, bottom: 16, trailing: 10))
                .frame(width: 345, height: 54)
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
                        .inset(by: 0.5)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        }
    }
    
    struct ButtonText: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(Theme.Typography.p1)
                .foregroundColor(Theme.Colors.light)
        }
    }
}

extension View {
    func buttonTextStyle() -> some View {
        modifier(Theme.ButtonText())
    }
} 