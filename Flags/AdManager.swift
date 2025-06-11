import Foundation
import GoogleMobileAds
import UIKit

class AdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    private var interstitial: InterstitialAd?
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
        InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Interstitial ad failed to load: \(error.localizedDescription)")
                    self?.isAdLoaded = false
                    return
                }

                self?.interstitial = ad
                self?.interstitial?.fullScreenContentDelegate = self
                self?.isAdLoaded = true
                print("Interstitial ad successfully loaded")
            }
        }
    }

    func showAd(from rootVC: UIViewController, completion: @escaping () -> Void) {
        guard let ad = interstitial else {
            print("Interstitial ad not available – proceeding without it")
            completion()
            return
        }

        isAdLoaded = false
        self.onAdDidDismiss = completion
        ad.present(from: rootVC)
    }

    // MARK: - GADFullScreenContentDelegate

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad was dismissed – loading a new one")
        loadAd()
        onAdDidDismiss?()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        onAdDidDismiss?()
    }
}



