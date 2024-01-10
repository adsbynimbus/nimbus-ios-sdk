//
//  NimbusCustomEventBanner.swift
//  NimbusGAMKit
//
//  Created on 4/1/20.
//  Copyright © 2020 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusKit
import GoogleMobileAds

/// :nodoc:
public final class NimbusCustomEventBanner: NSObject, GADCustomEventBanner {
    
    public var delegate: GADCustomEventBannerDelegate?
    
    private var size: CGSize!
    private var adView: NimbusAdView?
    private lazy var requestManager = NimbusRequestManager()

    public func requestAd(
        _ adSize: GADAdSize,
        parameter serverParameter: String?,
        label serverLabel: String?,
        request: GADCustomEventRequest
    ) {
        self.size = adSize.size
        
        let position = serverParameter ?? NimbusCustomEventUtils.position(
            in: request.additionalParameters,
            network: "GAM",
            isBanner: true
        )

        let width = Int(adSize.size.width)
        let height = Int(adSize.size.height)
        let adSizeToNimbusFormat = NimbusSizeToFormatMapper().map(width: width, height: height)

        let nimbusRequest = NimbusRequest.forBannerAd(position: position, format: adSizeToNimbusFormat)

        requestManager.delegate = self
        requestManager.performRequest(request: nimbusRequest)
    }
    
    private func render(ad: NimbusAd) {
        adView = NimbusAdView(adPresentingViewController: nil)
        adView?.delegate = self

        adView?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        adView?.render(ad: ad)
        adView?.start()

        // This needs to be sent here for .loaded event to trigger correctly
        guard let adView else { return }
        delegate?.customEventBanner(self, didReceiveAd: adView)
    }

    deinit { adView?.destroy() }
}

// MARK: NimbusRequestManagerDelegate

/// :nodoc:
extension NimbusCustomEventBanner: NimbusRequestManagerDelegate {

    /// :nodoc:
    public func didCompleteNimbusRequest(request: NimbusRequest, ad: NimbusAd) {
       render(ad: ad)
    }

    /// :nodoc:
    public func didFailNimbusRequest(request: NimbusRequest, error: NimbusError) {
        delegate?.customEventBanner(self, didFailAd: error)
    }
}

// MARK: AdControllerDelegate

/// :nodoc:
extension NimbusCustomEventBanner: AdControllerDelegate {

    /// :nodoc:
    public func didReceiveNimbusEvent(controller: AdController, event: NimbusEvent) {
        if event == .clicked {
            delegate?.customEventBannerWasClicked(self)
        }
    }

    /// :nodoc:
    public func didReceiveNimbusError(controller: AdController, error: NimbusError) {
        delegate?.customEventBanner(self, didFailAd: error)
    }
}
