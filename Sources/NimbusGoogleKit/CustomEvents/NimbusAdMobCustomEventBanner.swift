//
//  NimbusAdMobCustomEventBanner.swift
//  NimbusGoogleKit
//
//  Created on 6/27/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import GoogleMobileAds
@_exported import NimbusKit

/// :nodoc:
public final class NimbusAdMobCustomEventBanner: NSObject, MediationBannerAd {
    private var adView: NimbusAdView?
    
    public var view: UIView { adView ?? UIView() }
    private weak var delegate: MediationBannerAdEventDelegate?
    
    public override init() {
        super.init()
    }
    
    func render(
        ad: NimbusAd,
        adConfiguration: MediationBannerAdConfiguration,
        completionHandler: @escaping GADMediationBannerLoadCompletionHandler
    ) {
        adView = NimbusAdView(adPresentingViewController: adConfiguration.topViewController)
        adView?.delegate = self
        
        let size = adConfiguration.adSize.size
        adView?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        adView?.render(ad: ad)
        adView?.start()
        
        delegate = completionHandler(self, nil)
    }
}

// MARK: AdControllerDelegate

/// :nodoc:
extension NimbusAdMobCustomEventBanner: AdControllerDelegate {
    
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
