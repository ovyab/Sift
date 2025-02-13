import SwiftUI

enum Theme {
    enum Colors {
        static let pink = Color(red: 0.984, green: 0.671, blue: 0.851)    // #FBABD9
        static let light = Color(red: 0.961, green: 0.945, blue: 0.914)    // #F5F1E9
        static let cream = Color(red: 0.967, green: 0.926, blue: 0.755)    // #F6EC9F
        static let butter = Color(red: 0.973, green: 0.906, blue: 0.596)  // #F8E798
        static let green = Color(red: 0.490, green: 0.722, blue: 0.420)    // Sage green
        static let darkGreen = Color(red: 0.267, green: 0.447, blue: 0.365) // Dark sage green
        static let dark = Color(red: 0.078, green: 0.141, blue: 0.110)     // Almost black
        static let yellow = Color(red: 1.0, green: 0.675, blue: 0.200)    // #FFAC33
        static let purple = Color(red: 0.231, green: 0.176, blue: 0.608)   // Deep purple
        static let lightPurple = Color(red: 0.51, green: 0.48, blue: 0.80)   // Light purple
        static let grey = Color(red: 0.51, green: 0.53, blue: 0.59)       //rgb(151, 138, 130)
        
        // Add card colors array
        static let cardColors: [Color] = [
            purple,
            yellow,
            darkGreen
        ]
    }
    
    enum Typography {        
        // For backwards compatibility
        static let title = Font.custom("InstrumentSerif-Regular", size: 38).italic().leading(.tight)
        static let h1 = Font.custom("RadioCanadaBig-Regular_Medium", size: 28).leading(.tight)
        
        // Body Styles (Radio Canada)
        static let h2 = Font.custom("RadioCanadaBig-Regular_Regular", size: 22)
        static let p1 = Font.custom("RadioCanadaBig-Regular", size: 17)
        static let p2 = Font.custom("RadioCanadaBig-Regular", size: 15)
        static let eyebrow = Font.custom("RadioCanadaBig-Regular", size: 15)
    }
    
    enum Spacing {
        static let title: CGFloat = 32
        static let h1: CGFloat = 24
        static let h2: CGFloat = 26.40
        static let p2: CGFloat = 18
    }
}

extension Theme {
    struct PrimaryButtonStyle: ButtonStyle {
        let isEnabled: Bool
        
        init(isEnabled: Bool = true) {
            self.isEnabled = isEnabled
        }
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(Theme.Typography.p1)
                .foregroundColor(Theme.Colors.light.opacity(isEnabled ? 1.0 : 0.5))
                .padding(EdgeInsets(top: 16, leading: 10, bottom: 16, trailing: 10))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Theme.Colors.darkGreen.opacity(isEnabled ? 1.0 : 0.5))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .inset(by: 0.50)
                        .stroke(.white.opacity(isEnabled ? 0.1 : 0), lineWidth: 0.50)
                )
        }
    }
    
    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(Theme.Typography.p1)
                .foregroundColor(Theme.Colors.dark)
                .padding(EdgeInsets(top: 16, leading: 10, bottom: 16, trailing: 10))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .inset(by: 0.50)
                        .stroke(Theme.Colors.dark.opacity(0.5), lineWidth: 0.50)
                )
        }
    }
    
    struct ButtonText: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(Theme.Typography.p1)
                .foregroundColor(Theme.Colors.dark)
        }
    }
}

extension View {
    func buttonTextStyle() -> some View {
        modifier(Theme.ButtonText())
    }
}