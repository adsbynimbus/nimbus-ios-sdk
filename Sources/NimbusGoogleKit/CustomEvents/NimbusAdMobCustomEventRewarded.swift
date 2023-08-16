//
//  NimbusAdMobCustomEventRewarded.swift
//  NimbusGoogleKit
//
//  Created by Inder Dhir on 6/27/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

@_exported import NimbusKit
import GoogleMobileAds

/// :nodoc:
public final class NimbusAdMobCustomEventRewarded: NSObject, GADMediationRewardedAd {
    private var ad: NimbusAd?
    private var companionAd: NimbusCompanionAd?
    private lazy var adPresenter = NimbusAdMobInterstitialAdPresenter(isRewarded: true)

    private weak var delegate: GADMediationRewardedAdEventDelegate?
    
    public override init() {
        super.init()
    }
    
    public func present(from viewController: UIViewController) {
        guard let ad else {
            delegate?.didFailToPresentWithError(
                NimbusRenderError.adRenderingFailed(message: "AdMob Rewarded ad not found")
            )
            return
        }
        
        adPresenter.adControllerDelegate = self
        adPresenter.adViewControllerDelegate = self
        adPresenter.present(ad: ad, companionAd: companionAd, from: viewController)
    }
    
    func render(
        ad: NimbusAd,
        companionAd: NimbusCompanionAd?,
        completionHandler: @escaping GADMediationRewardedLoadCompletionHandler
    ) {
        self.ad = ad
        self.companionAd = companionAd
        delegate = completionHandler(self, nil)
    }
}

// MARK: AdControllerDelegate

/// :nodoc:
extension NimbusAdMobCustomEventRewarded: AdControllerDelegate {

    public func didReceiveNimbusEvent(controller: AdController, event: NimbusEvent) {
        switch event {
        case .impression:
            delegate?.reportImpression()
        case .completed:
            delegate?.didEndVideo()
            delegate?.didRewardUser()
        case .clicked:
            delegate?.reportClick()
        default:
            break
        }
    }

    public func didReceiveNimbusError(controller: AdController, error: NimbusError) {
        delegate?.didFailToPresentWithError(error)
    }
}

// MARK: NimbusAdViewControllerDelegate

extension NimbusAdMobCustomEventRewarded: NimbusAdViewControllerDelegate {

    public func viewWillAppear(animated: Bool) {
        delegate?.willPresentFullScreenView()
    }
    
    public func viewDidAppear(animated: Bool) {
        delegate?.didStartVideo()
    }
    
    public func viewWillDisappear(animated: Bool) {
        delegate?.willDismissFullScreenView()
    }
    
    public func viewDidDisappear(animated: Bool) {
        delegate?.didDismissFullScreenView()
    }
    
    public func didCloseAd(adView: NimbusAdView) {
        adPresenter.destroy()
    }
}
