//
//  NimbusCustomEventInterstitial.swift
//  NimbusGAMKit
//
//  Created on 11/9/20.
//  Copyright © 2020 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusKit
import GoogleMobileAds

/// :nodoc:
public final class NimbusCustomEventInterstitial: NSObject, GADCustomEventInterstitial {
    
    public var delegate: GADCustomEventInterstitialDelegate?
    
    private var ad: NimbusAd?
    private var adView: NimbusAdView?
    private lazy var requestManager = NimbusRequestManager()
        
    public func requestAd(
        withParameter serverParameter: String?,
        label serverLabel: String?,
        request: GADCustomEventRequest
    ) {
        let position = serverParameter ?? NimbusCustomEventUtils.position(
            in: request.additionalParameters,
            network: "GAM",
            isBanner: true
        )
        let nimbusRequest = NimbusRequest.forInterstitialAd(position: position)
        requestManager.delegate = self
        requestManager.performRequest(request: nimbusRequest)
    }
    
    public func present(fromRootViewController rootViewController: UIViewController) {
        guard let ad else { return }
        render(ad: ad, rootViewController: rootViewController)
    }
    
    func render(ad: NimbusAd, rootViewController: UIViewController) {
        adView = NimbusAdView(adPresentingViewController: nil)
        adView?.delegate = self
        
        guard let adView else { return }
        let nimbusVC = NimbusAdViewController(adView: adView, ad: ad, companionAd: nil, closeButtonDelay: 5)
        nimbusVC.delegate = self
        adView.adPresentingViewController = nimbusVC
        rootViewController.present(nimbusVC, animated: true, completion: nil)
        nimbusVC.renderAndStart()
    }
}

// MARK: NimbusRequestManagerDelegate

/// :nodoc:
extension NimbusCustomEventInterstitial: NimbusRequestManagerDelegate {

    /// :nodoc:
    public func didCompleteNimbusRequest(request: NimbusRequest, ad: NimbusAd) {
        self.ad = ad
        delegate?.customEventInterstitialDidReceiveAd(self)
    }

    /// :nodoc:
    public func didFailNimbusRequest(request: NimbusRequest, error: NimbusError) {
        delegate?.customEventInterstitial(self, didFailAd: error)
    }
}

// MARK: AdControllerDelegate

/// :nodoc:
extension NimbusCustomEventInterstitial: AdControllerDelegate {

    /// :nodoc:
    public func didReceiveNimbusEvent(controller: AdController, event: NimbusEvent) {
        if event == .clicked {
            delegate?.customEventInterstitialWasClicked(self)
        }
    }

    /// :nodoc:
    public func didReceiveNimbusError(controller: AdController, error: NimbusError) {
        delegate?.customEventInterstitial(self, didFailAd: error)
    }
}

// MARK: NimbusAdViewControllerDelegate

extension NimbusCustomEventInterstitial: NimbusAdViewControllerDelegate {

    /// :nodoc:
    public func viewWillAppear(animated: Bool) {
        delegate?.customEventInterstitialWillPresent(self)
    }
    
    /// :nodoc:
    public func viewDidAppear(animated: Bool) {}
    
    /// :nodoc:
    public func viewWillDisappear(animated: Bool) {
        delegate?.customEventInterstitialWillDismiss(self)
    }
    
    /// :nodoc:
    public func viewDidDisappear(animated: Bool) {
        delegate?.customEventInterstitialDidDismiss(self)
    }
    
    /// :nodoc:
    public func didCloseAd(adView: NimbusAdView) {
        adView.destroy()
    }
}
