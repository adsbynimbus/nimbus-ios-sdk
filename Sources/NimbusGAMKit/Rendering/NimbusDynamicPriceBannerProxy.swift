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
    weak var clientDelegate: BannerViewDelegate?
    weak var nimbusDelegate: BannerViewDelegate?
    
    init(
        requestManager: NimbusRequestManager,
        clientDelegate: BannerViewDelegate? = nil,
        nimbusDelegate: BannerViewDelegate? = nil
    ) {
        self.requestManager = requestManager
        self.clientDelegate = clientDelegate
        self.nimbusDelegate = nimbusDelegate
    }
}

extension NimbusDynamicPriceBannerProxy: BannerViewDelegate {
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        clientDelegate?.bannerView?(bannerView, didFailToReceiveAdWithError: error)
        nimbusDelegate?.bannerView?(bannerView, didFailToReceiveAdWithError: error)
    }
    
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        clientDelegate?.bannerViewDidReceiveAd?(bannerView)
        nimbusDelegate?.bannerViewDidReceiveAd?(bannerView)
    }
    
    func bannerViewDidRecordClick(_ bannerView: BannerView) {
        clientDelegate?.bannerViewDidRecordClick?(bannerView)
        nimbusDelegate?.bannerViewDidRecordClick?(bannerView)
    }
    
    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        clientDelegate?.bannerViewDidRecordImpression?(bannerView)
        nimbusDelegate?.bannerViewDidRecordImpression?(bannerView)
    }
    
    func bannerViewWillPresentScreen(_ bannerView: BannerView) {
        clientDelegate?.bannerViewWillPresentScreen?(bannerView)
        nimbusDelegate?.bannerViewWillPresentScreen?(bannerView)
    }
    
    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
        clientDelegate?.bannerViewWillDismissScreen?(bannerView)
        nimbusDelegate?.bannerViewWillDismissScreen?(bannerView)
    }
    
    func bannerViewDidDismissScreen(_ bannerView: BannerView) {
        clientDelegate?.bannerViewDidDismissScreen?(bannerView)
        nimbusDelegate?.bannerViewDidDismissScreen?(bannerView)
    }
}
