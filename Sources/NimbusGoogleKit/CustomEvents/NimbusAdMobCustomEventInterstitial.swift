//
//  NimbusAdMobCustomEventInterstitial.swift
//  NimbusGoogleKit
//
//  Created on 6/27/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import GoogleMobileAds
@_exported import NimbusKit

/// :nodoc:
public final class NimbusAdMobCustomEventInterstitial: NSObject, GADMediationInterstitialAd {
    private var ad: NimbusAd?
    private var companionAd: NimbusCompanionAd?
    private lazy var adPresenter = NimbusAdMobInterstitialAdPresenter(isRewarded: false)
    
    private weak var delegate: GADMediationInterstitialAdEventDelegate?
    
    public override init() {
        super.init()
    }
    
    public func present(from viewController: UIViewController) {
        guard let ad else {
            delegate?.didFailToPresentWithError(NimbusRenderError.adRenderingFailed(message: "AdMob Interstitial Ad not found"))
            return
        }
        
        adPresenter.adControllerDelegate = self
        adPresenter.adViewControllerDelegate = self
        adPresenter.present(ad: ad, companionAd: companionAd, from: viewController)
    }
    
    func render(
        ad: NimbusAd,
        companionAd: NimbusCompanionAd?,
        completionHandler: @escaping GADMediationInterstitialLoadCompletionHandler
    ) {
        self.ad = ad
        self.companionAd = companionAd
        delegate = completionHandler(self, nil)
    }
}

// MARK: AdControllerDelegate

/// :nodoc:
extension NimbusAdMobCustomEventInterstitial: AdControllerDelegate {

    public func didReceiveNimbusEvent(controller: AdController, event: NimbusEvent) {
        switch event {
        case .impression:
            delegate?.reportImpression()
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

/// :nodoc:
extension NimbusAdMobCustomEventInterstitial: NimbusAdViewControllerDelegate {

    public func viewWillAppear(animated: Bool) {
        delegate?.willPresentFullScreenView()
    }
    
    public func viewDidAppear(animated: Bool) {}
    
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
