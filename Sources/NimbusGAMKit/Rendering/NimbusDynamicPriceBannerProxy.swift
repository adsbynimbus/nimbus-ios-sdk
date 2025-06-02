//
//  NimbusDynamicPriceBannerProxy.swift
//  Nimbus
//  Created on 2/27/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit
import GoogleMobileAds

final class NimbusDynamicPriceBannerProxy: NSObject {
    let requestManager: NimbusRequestManager
    weak var clientDelegate: GADBannerViewDelegate?
    weak var nimbusDelegate: GADBannerViewDelegate?
    
    init(
        requestManager: NimbusRequestManager,
        clientDelegate: GADBannerViewDelegate? = nil,
        nimbusDelegate: GADBannerViewDelegate? = nil
    ) {
        self.requestManager = requestManager
        self.clientDelegate = clientDelegate
        self.nimbusDelegate = nimbusDelegate
    }
}

extension NimbusDynamicPriceBannerProxy: GADBannerViewDelegate {
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        clientDelegate?.bannerView?(bannerView, didFailToReceiveAdWithError: error)
        nimbusDelegate?.bannerView?(bannerView, didFailToReceiveAdWithError: error)
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        clientDelegate?.bannerViewDidReceiveAd?(bannerView)
        nimbusDelegate?.bannerViewDidReceiveAd?(bannerView)
    }
    
    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        clientDelegate?.bannerViewDidRecordClick?(bannerView)
        nimbusDelegate?.bannerViewDidRecordClick?(bannerView)
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        clientDelegate?.bannerViewDidRecordImpression?(bannerView)
        nimbusDelegate?.bannerViewDidRecordImpression?(bannerView)
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        clientDelegate?.bannerViewWillPresentScreen?(bannerView)
        nimbusDelegate?.bannerViewWillPresentScreen?(bannerView)
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        clientDelegate?.bannerViewWillDismissScreen?(bannerView)
        nimbusDelegate?.bannerViewWillDismissScreen?(bannerView)
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        clientDelegate?.bannerViewDidDismissScreen?(bannerView)
        nimbusDelegate?.bannerViewDidDismissScreen?(bannerView)
    }
}
