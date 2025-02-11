import SwiftUI

enum Theme {
    enum Colors {
        static let pink = Color(red: 0.984, green: 0.671, blue: 0.851)
        static let light = Color(red: 1.0, green: 0.992, blue: 0.988)
        static let butter = Color(red: 0.973, green: 0.906, blue: 0.596)
        static let green = Color(red: 0.467, green: 0.698, blue: 0.333)
        static let dark = Color(red: 0.118, green: 0.122, blue: 0.157)
        static let yellow = Color(red: 1.0, green: 0.675, blue: 0.200)
    }
    
    enum Fonts {
        static let title = Font.custom("AdventPro-Regular_Bold", size: 45)
        static let h1 = Font.custom("PublicSansRoman-Bold", size: 36)
        static let h2 = Font.custom("PublicSansRoman-SemiBold", size: 28)
        static let h3 = Font.custom("PublicSansRoman-Medium", size: 22)
        static let p1 = Font.custom("PublicSansRoman-Medium", size: 20)
        static let p2 = Font.custom("PublicSansRoman-Medium", size: 16)
        static let eyebrow = Font.custom("PublicSansRoman-Bold", size: 12)
    }
} 