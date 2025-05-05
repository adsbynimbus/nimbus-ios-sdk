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
    private var adController: AdController?

    public func requestAd(
        withParameter serverParameter: String?,
        label serverLabel: String?,
        request: CustomEventRequest
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
        guard let ad else {
            delegate?.customEventInterstitial(self, didFailAd: NimbusRenderError.adRenderingFailed(message: "present(fromRootViewController:) called before ad was received"))
            return
        }
        
        do {
            adController = try Nimbus.loadBlocking(
                ad: ad,
                presentingViewController: rootViewController,
                delegate: self,
                companionAd: NimbusCompanionAd(width: 320, height: 480, renderMode: .endCard)
            )
            adController?.start()
        } catch {
            delegate?.customEventInterstitial(self, didFailAd: NimbusRenderError.adRenderingFailed(message: "GAM Interstitial Ad could not be rendered, error: \(error)"))
        }
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
