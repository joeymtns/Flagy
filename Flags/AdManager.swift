import Foundation
import GoogleMobileAds
import UIKit

class AdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    private var rewardedAd: RewardedInterstitialAd?
    private let adUnitID = "ca-app-pub-4660117225433404/6084709349"


    var onAdDidDismiss: (() -> Void)?

    override init() {
        super.init()
        loadAd()
    }

    func loadAd() {
        let request = Request()
        RewardedInterstitialAd.load(with: adUnitID, request: request) { ad, error in
            if let error = error {
                print("Ad konnte nicht geladen werden: \(error.localizedDescription)")
                return
            }
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            print("Rewarded Interstitial Ad erfolgreich geladen")
        }
    }

    func showAd(from rootVC: UIViewController, completion: @escaping () -> Void) {
        guard let ad = rewardedAd else {
            print("Ad noch nicht verfügbar – fahre fort")
            completion()
            return
        }

        self.onAdDidDismiss = completion
        ad.present(from: rootVC) {
            // Optional: Reward verarbeiten
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


