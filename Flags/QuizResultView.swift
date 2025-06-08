import SwiftUI
import GoogleMobileAds

struct QuizResultView: View {
    let score: Int
    let total: Int

    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToHome = false
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
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        ButtonStyle.primaryButton(title: "Replay", icon: "arrow.clockwise", color: .glowingBlue)
                    }

                    Button(action: {
                        showAdThen {
                            navigateToHome = true
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
        .fullScreenCover(isPresented: $navigateToHome) {
            NavigationView {
                MainView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    private func showAdThen(_ completion: @escaping () -> Void) {
        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first {
            adManager.showAd(from: rootVC) {
                completion()
            }
        } else {
            completion()
        }
    }
}


