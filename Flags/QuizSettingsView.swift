import SwiftUI

struct QuizSettingsView: View {
    // Übergebene Region, für die das Quiz gilt
    let region: String
    
    // Vom Nutzer ausgewählte Anzahl an Fragen (Standard: 10)
    @State private var selectedQuestionCount = 10
    
    // Vom Nutzer ausgewählte Zeit pro Frage in Sekunden (Standard: 5)
    @State private var selectedTimePerQuestion = 5
    
    // Ermöglicht das Schließen der aktuellen View (z. B. über Zurück-Button)
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Hintergrundfarbe der View
            Color.backgroundGray.ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Einstellungs-Karte für die Anzahl der Fragen
                SettingsCard(
                    icon: "number.circle.fill",
                    title: "Flags",
                    value: selectedQuestionCount,
                    color: .primaryBlue
                ) {
                    CustomSlider(value: $selectedQuestionCount, in: QuizSettings.questionOptions)
                }
                
                // Einstellungs-Karte für die Zeit pro Frage
                SettingsCard(
                    icon: "timer.circle.fill",
                    title: "Seconds",
                    value: selectedTimePerQuestion,
                    color: .secondaryGreen
                ) {
                    CustomSlider(value: $selectedTimePerQuestion, in: QuizSettings.timeOptions)
                }
                
                Spacer()
                
                // Navigation zum QuizView mit den gewählten Einstellungen
                NavigationLink(
                    destination: QuizView(
                        region: region,
                        questionCount: selectedQuestionCount,
                        timePerQuestion: selectedTimePerQuestion,
                        countries: CountryManager.loadCountries(for: region)
                    )
                ) {
                    // Start-Button für das Quiz
                    ButtonStyle.primaryButton(title: "Start Quiz", icon: "play.circle.fill", color: .primaryBlue)
                }
            }
            .padding()
        }
        // Titel der Navigationsleiste
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .foregroundColor(.black)

        // Benutzerdefinierter Zurück-Button (Chevron)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundColor(.blue)
        })
    }
}

