import SwiftUI

// Ansicht für eine Schaltfläche, die eine Region darstellt
struct RegionButton: View {
    let region: String       // Name der Region
    let icon: String         // Symbol-Name (SF Symbol)
    let color: Color         // Hintergrundfarbe
    
    var body: some View {
        VStack {
            Image(systemName: icon)                 // Symbolbild anzeigen
                .font(.system(size: 30))
                .padding(.bottom, 5)
            Text(region)                            // Regionsname anzeigen
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .foregroundColor(.white)
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)      // Abgerundetes Rechteck als Hintergrund
                .fill(color)
                .shadow(color: color.opacity(0.3), radius: 8, y: 4)
        )
    }
}

// Ansicht für eine individuell konfigurierbare Einstellungen-Karte
struct SettingsCard<Content: View>: View {
    let icon: String          // Symbol-Name (SF Symbol)
    let title: String         // Titel der Einstellung
    let value: Int            // Aktueller Wert
    let color: Color          // Akzentfarbe
    let content: Content      // Beliebiger SwiftUI-Inhalt im unteren Bereich
    
    // Initialisierer mit ViewBuilder für dynamischen Inhalt
    init(icon: String, title: String, value: Int, color: Color, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)              // Symbol anzeigen
                    .font(.title2)
                Text(title)                          // Titel anzeigen
                    .font(.title3.bold())
            }
            .foregroundColor(color)
            
            Text("\(value)")                         // Aktuellen Wert anzeigen
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(color)
            
            content                                  // Dynamischer Inhalt (z. B. Slider)
                .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)       // Hintergrund mit Schatten
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
        )
    }
}

// Benutzerdefinierter Slider mit festen Stufen
struct CustomSlider: View {
    @Binding var value: Int          // Aktueller Wert (gebunden an externe Variable)
    let range: [Int]                 // Mögliche Werte im Slider
    
    // Initialisierer mit Binding-Wert und Wertebereich
    init(value: Binding<Int>, in range: [Int]) {
        self._value = value
        self.range = range
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()                              // Hintergrundlinie
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                HStack(spacing: 0) {                      // Markierungen für die Schritte
                    ForEach(0..<range.count, id: \.self) { index in
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                        if index < range.count - 1 {
                            Spacer()
                        }
                    }
                }
                
                Rectangle()                               // Gefüllter Teil des Sliders
                    .fill(Color.primaryBlue)
                    .frame(width: self.getSliderPosition(width: geometry.size.width), height: 8)
                    .cornerRadius(4)
                
                Circle()                                  // Schieberegler-Knopf
                    .fill(Color.white)
                    .shadow(radius: 8)
                    .frame(width: 28, height: 28)
                    .offset(x: self.getSliderPosition(width: geometry.size.width) - 14)
                    .gesture(
                        DragGesture(minimumDistance: 0)   // Drag-Geste zur Wertänderung
                            .onChanged { value in
                                self.updateValue(dragLocation: value.location, width: geometry.size.width)
                            }
                    )
            }
        }
        .frame(height: 40)
    }
    
    // Berechnet die Position des Reglers basierend auf dem aktuellen Wert
    private func getSliderPosition(width: CGFloat) -> CGFloat {
        guard let index = range.firstIndex(of: value) else { return 0 }
        let steps = range.count - 1
        return width * CGFloat(index) / CGFloat(steps)
    }
    
    // Aktualisiert den Wert basierend auf der Drag-Position
    private func updateValue(dragLocation: CGPoint, width: CGFloat) {
        let steps = range.count - 1
        let stepWidth = width / CGFloat(steps)
        let index = Int(round(dragLocation.x / stepWidth))
        let clampedIndex = max(0, min(steps, index))
        value = range[clampedIndex]
    }
}

// Struktur für globale Quiz-Einstellungen
struct QuizSettings {
    static let questionOptions = [10, 15, 20, 25, 30]  // Auswahlmöglichkeiten für Anzahl der Fragen
    static let timeOptions = [5, 10, 15, 20]           // Auswahlmöglichkeiten für Zeitlimit (z. B. Minuten)
}

