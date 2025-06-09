import Foundation
import GoogleMobileAds
import UIKit

class AdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    private var rewardedAd: RewardedInterstitialAd?
    private let adUnitID = "ca-app-pub-4660117225433404/6084709349"

    @Published var isAdLoaded = false
    var onAdDidDismiss: (() -> Void)?

    override init() {
        super.init()
        loadAd()
    }

    func loadAd() {
        isAdLoaded = false
        let request = Request()
        RewardedInterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ad konnte nicht geladen werden: \(error.localizedDescription)")
                    self?.isAdLoaded = false
                    return
                }

                self?.rewardedAd = ad
                self?.rewardedAd?.fullScreenContentDelegate = self
                self?.isAdLoaded = true
                print("Rewarded Interstitial Ad erfolgreich geladen")
            }
        }
    }

    func showAd(from rootVC: UIViewController, completion: @escaping () -> Void) {
        guard let ad = rewardedAd else {
            print("Ad noch nicht verfügbar – fahre fort")
            completion()
            return
        }

        isAdLoaded = false
        self.onAdDidDismiss = completion
        ad.present(from: rootVC) {
            print("Benutzer hat Werbung gesehen")
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Anzeige geschlossen – lade neue Anzeige")
        loadAd()
        onAdDidDismiss?()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Anzeige konnte nicht gezeigt werden: \(error.localizedDescription)")
        onAdDidDismiss?()
    }
}



