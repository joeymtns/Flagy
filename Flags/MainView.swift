import SwiftUI

// Hauptansicht des Flaggen-Quiz
struct MainView: View {
    var body: some View {
        ZStack {
            // Hintergrundfarbe festlegen und über gesamten Bildschirm anzeigen
            Color.backgroundGray.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Symbol oben in der Ansicht
                Image(systemName: "globe")
                    .font(.system(size: 80))
                    .foregroundColor(.primaryBlue)
                    .padding(.top, 50)
                
                // Untertitel / Beschreibung
                Text("Test your knowledge about flags!")
                    .font(.title3)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Button für Quiz mit allen Regionen
                NavigationLink(destination: QuizSettingsView(region: Region.wholeWorld.rawValue)) {
                    RegionButton(
                        region: Region.wholeWorld.rawValue,
                        icon: Region.wholeWorld.icon,
                        color: Region.wholeWorld.color
                    )
                }
                .padding(.horizontal)
                
                // Raster mit Buttons für spezifische Regionen (außer "wholeWorld")
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(Region.allCases.filter { $0 != .wholeWorld }, id: \.self) { region in
                        NavigationLink(destination: QuizSettingsView(region: region.rawValue)) {
                            RegionButton(
                                region: region.rawValue,
                                icon: region.icon,
                                color: region.color
                            )
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer() // Schiebt Inhalt nach oben
            }
            .padding()
        }
        .navigationBarHidden(true) // Versteckt die Navigationsleiste
    }
}


