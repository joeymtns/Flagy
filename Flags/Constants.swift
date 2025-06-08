import SwiftUI

// Enum zur Darstellung verschiedener Weltregionen
enum Region: String, CaseIterable {
    case wholeWorld = "Whole World"
    case europe = "Europe"
    case asia = "Asia"
    case africa = "Africa"
    case northAmerica = "North America"
    case southAmerica = "South America"
    case oceania = "Oceania"
    
    // Gibt ein passendes System-Icon (SF Symbol) für jede Region zurück
    var icon: String {
        switch self {
        case .wholeWorld: return "globe"
        case .europe: return "globe.europe.africa"
        case .asia: return "globe.asia.australia"
        case .africa: return "globe.europe.africa"
        case .northAmerica: return "globe.americas"
        case .southAmerica: return "globe.americas"
        case .oceania: return "globe.asia.australia"
        }
    }
    
    // Gibt eine spezifische Farbe für jede Region zurück
    var color: Color {
        switch self {
        case .wholeWorld: return .glowingDarkBlue
        case .europe: return .glowingBlue
        case .asia: return .glowingRed
        case .africa: return .glowingYellow
        case .northAmerica: return .glowingGreen
        case .southAmerica: return .glowingPurple
        case .oceania: return .glowingCyan
        }
    }
}

// Struktur zur Definition eines einheitlichen Button-Stils
struct ButtonStyle {
    // Erstellt einen Button mit Symbol, Text, Farbe und Schatten
    static func primaryButton(title: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title)
                .font(.title3.bold())
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .cornerRadius(25)
        .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
    }
} 
