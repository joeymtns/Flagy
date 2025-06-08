import SwiftUI

extension Color {
    // Initialisiert eine Farbe aus einem Hex-String
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        // Initialisiert die SwiftUI-Farbe mit den extrahierten RGBA-Werten
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    // Primärfarben des Designs
    static let primaryBlue = Color(hex: "3380E6")
    static let secondaryGreen = Color(hex: "33CC80")  
    static let backgroundGray = Color(hex: "F2F3F7")
    static let darkText = Color(hex: "1A1A33")
    
    // Leuchtende Farben für Effekte, Hervorhebungen etc.
    static let glowingBlue = Color(hex: "3399E6")
    static let glowingDarkBlue = Color(hex: "2563EB")
    static let glowingRed = Color(hex: "E6664D")
    static let glowingYellow = Color(hex: "E6B333")
    static let glowingGreen = Color(hex: "4DCC66")
    static let glowingPurple = Color(hex: "CC66E6")
    static let glowingCyan = Color(hex: "66B3E6")
}

