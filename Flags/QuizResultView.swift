import SwiftUI
import GoogleMobileAds

struct QuizResultView: View {
    let score: Int
    let total: Int
    let region: String  // ← übergeben aus dem QuizView

    @State private var goToMain = false
    @State private var goToSettings = false
    @StateObject private var adManager = AdManager()

    var body: some View {
        ZStack {
            Color.backgroundGray.ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.glowingYellow)
                        .frame(width: 120, height: 120)

                    Image(systemName: "star.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }

                Text("Congratulations!")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.darkText)

                Text("Your Result:")
                    .font(.title)
                    .foregroundColor(.darkText)

                Text("\(score) of \(total)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.glowingBlue)

                Text("Score: \(Int((Double(score) / Double(total)) * 100))%")
                    .font(.title2)
                    .foregroundColor(.gray)

                Spacer()

                VStack(spacing: 15) {
                    Button(action: {
                        showAdThen {
                            goToSettings = true
                        }
                    }) {
                        ButtonStyle.primaryButton(title: "Replay", icon: "arrow.clockwise", color: .glowingBlue)
                    }

                    Button(action: {
                        showAdThen {
                            goToMain = true
                        }
                    }) {
                        ButtonStyle.primaryButton(title: "Home", icon: "house", color: .secondaryGreen)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)

        // Navigation zur MainView
        .navigationDestination(isPresented: $goToMain) {
            MainView()
        }

        // Navigation zur SettingsView mit Region
        .navigationDestination(isPresented: $goToSettings) {
            QuizSettingsView(region: region)
        }
    }

    private func showAdThen(_ completion: @escaping () -> Void) {
        let rootVC = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first

        // Ad nur zeigen, wenn keine View gerade präsentiert wird
        if rootVC?.presentedViewController == nil {
            adManager.showAd(from: rootVC) {
                completion()
            }
        } else {
            print("⚠️ Already presenting a view – skipping ad")
            completion()
        }
    }
}



