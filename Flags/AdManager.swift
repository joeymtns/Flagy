import Foundation
import GoogleMobileAds
import UIKit

class AdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    private var interstitial: InterstitialAd?
    private let adUnitID = "ca-app-pub-4660117225433404/6084709349" // Deine AdMob Ad Unit ID

    @Published var isAdLoaded = false
    var onAdDidDismiss: (() -> Void)?

    override init() {
        super.init()
        loadAd()
    }

    /// Lädt eine neue Interstitial-Werbung
    func loadAd() {
        isAdLoaded = false
        let request = Request()

        // Optional: Testgerät-ID für AdMob Entwicklung
        // GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["DEIN_TESTGERÄT_ID"]

        InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("⚠️ Interstitial ad failed to load: \(error.localizedDescription)")
                    self?.isAdLoaded = false
                    self?.retryLoadAdAfterDelay()
                    return
                }

                self?.interstitial = ad
                self?.interstitial?.fullScreenContentDelegate = self
                self?.isAdLoaded = true
                print("✅ Interstitial ad successfully loaded")
            }
        }
    }

    /// Versucht nach einem Ladefehler erneut, eine Ad zu laden
    private func retryLoadAdAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            print("🔁 Retrying to load ad...")
            self.loadAd()
        }
    }

    /// Zeigt eine Anzeige, falls möglich – oder fährt direkt fort
    func showAd(from rootVC: UIViewController?, completion: @escaping () -> Void) {
        guard isAdLoaded, let ad = interstitial else {
            print("ℹ️ No ad available – continuing without showing ad")
            completion()
            return
        }

        guard let rootVC = rootVC else {
            print("⚠️ No root view controller – cannot show ad")
            completion()
            return
        }

        // ⚠️ WICHTIG: Keine Ad zeigen, wenn bereits etwas präsentiert wird
        guard rootVC.presentedViewController == nil else {
            print("❌ Cannot present ad – rootVC is already presenting something")
            completion()
            return
        }

        isAdLoaded = false
        onAdDidDismiss = completion
        ad.present(from: rootVC)
    }

    // MARK: - GADFullScreenContentDelegate

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("ℹ️ Ad was dismissed – loading next ad")
        loadAd()
        onAdDidDismiss?()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Ad failed to present: \(error.localizedDescription)")
        onAdDidDismiss?()
        loadAd()
    }
}






