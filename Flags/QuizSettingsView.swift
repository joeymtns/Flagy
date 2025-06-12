import SwiftUI
import GoogleMobileAds

struct QuizSettingsView: View {
    let region: String

    @State private var selectedQuestionCount = 10
    @State private var selectedTimePerQuestion = 5

    @State private var showQuiz = false
    @StateObject private var adManager = AdManager()

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.backgroundGray.ignoresSafeArea()

            VStack(spacing: 25) {
                SettingsCard(
                    icon: "number.circle.fill",
                    title: "Flags",
                    value: selectedQuestionCount,
                    color: .primaryBlue
                ) {
                    CustomSlider(value: $selectedQuestionCount, in: QuizSettings.questionOptions)
                }

                SettingsCard(
                    icon: "timer.circle.fill",
                    title: "Seconds",
                    value: selectedTimePerQuestion,
                    color: .secondaryGreen
                ) {
                    CustomSlider(value: $selectedTimePerQuestion, in: QuizSettings.timeOptions)
                }

                Spacer()

                Button(action: {
                    showAdThen {
                        showQuiz = true
                    }
                }) {
                    ButtonStyle.primaryButton(title: "Start Quiz", icon: "play.circle.fill", color: .primaryBlue)
                }
            }
            .padding()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundColor(.blue)
        })
        .navigationDestination(isPresented: $showQuiz) {
            QuizView(
                region: region,
                questionCount: selectedQuestionCount,
                timePerQuestion: selectedTimePerQuestion,
                countries: CountryManager.loadCountries(for: region)
            )
        }
    }

    /// Zeigt Werbung (wenn möglich) und navigiert dann weiter
    private func showAdThen(_ completion: @escaping () -> Void) {
        let rootVC = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first

        adManager.showAd(from: rootVC) {
            completion()
        }
    }
}




