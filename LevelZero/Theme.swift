import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct Theme {
    static let background = Color(hex: "0B0C10")
    static let card = Color(hex: "1F2833")
    static let neonCyan = Color(hex: "66FCF1")
    static let purple = Color(hex: "8A2BE2")
    static let gold = Color(hex: "FFD700")
    static let text = Color.white
    static let subtext = Color(hex: "C5C6C7")
    
    // Cyberpunk/RPG fonts
    static func titleFont(size: CGFloat) -> Font {
        return Font.system(size: size, weight: .bold, design: .monospaced)
    }
    
    static func bodyFont(size: CGFloat) -> Font {
        return Font.system(size: size, weight: .regular, design: .default)
    }
    
    static func statsFont(size: CGFloat) -> Font {
        return Font.system(size: size, weight: .semibold, design: .monospaced)
    }
}
