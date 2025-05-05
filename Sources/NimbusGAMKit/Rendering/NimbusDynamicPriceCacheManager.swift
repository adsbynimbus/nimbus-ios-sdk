//
//  NimbusDynamicPriceCacheManager.swift
//  NimbusGAMKit
//
//  Created on 25/04/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusKit
import GoogleMobileAds
import UIKit

/// :nodoc:
final class NimbusDynamicPriceCacheManager {
    
    /// :nodoc:
    struct GoogleAuctionData: Hashable {
        let nimbusAd: NimbusAd
        var isNimbusWin = false
        var price = "-1"
        
        init(nimbusAd: NimbusAd) {
            self.nimbusAd = nimbusAd
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(nimbusAd.auctionId)
        }
    }
    
    private var dataCache: [Int: GoogleAuctionData] = [:]
    private var clickEventCache: [Int: URL] = [:]
    
    /// Add methods
    
    /// :nodoc:
    func addData(nimbusAd: NimbusAd, bannerView: BannerView) {
        dataCache[bannerView.hash] = GoogleAuctionData(nimbusAd: nimbusAd)
    }
    
    /// :nodoc:
    func addData(nimbusAd: NimbusAd, fullScreenPresentingAd: FullScreenPresentingAd) {
        dataCache[fullScreenPresentingAd.hash] = GoogleAuctionData(nimbusAd: nimbusAd)
    }
    
    /// :nodoc
    func addClickEvent(nimbusAdView: UIView, clickEventUrl: URL?) {
        clickEventCache[nimbusAdView.hash] = clickEventUrl
    }
    
    /// Get methods
    
    /// :nodoc:
    func getData(for bannerView: BannerView) -> GoogleAuctionData? {
        dataCache[bannerView.hash]
    }
    
    /// :nodoc:
    func getData(for fullScreenPresentingAd: FullScreenPresentingAd) -> GoogleAuctionData? {
        dataCache[fullScreenPresentingAd.hash]
    }
    
    /// :nodoc:
    func getData(for auctionId: String) -> GoogleAuctionData? {
        dataCache.values.first(where: { $0.nimbusAd.auctionId == auctionId })
    }
    
    /// :nodoc:
    func getClickEvent(nimbusAdView: UIView) -> URL? {
        clickEventCache[nimbusAdView.hash]
    }
    
    /// Update methods
    
    /// :nodoc:
    func updateBannerPrice(_ bannerView: BannerView, price: String) {
        if var data = dataCache[bannerView.hash] {
            data.price = price
            dataCache[bannerView.hash] = data
        }
    }
    
    /// :nodoc:
    func updateInterstitialPrice(_ fullScreenPresentingAd: FullScreenPresentingAd, price: String) {
        if var data = dataCache[fullScreenPresentingAd.hash] {
            data.price = price
            dataCache[fullScreenPresentingAd.hash] = data
        }
    }
    
    /// :nodoc:
    func updateNimbusDidWin(auctionId: String) {
        if var element = dataCache.first(where: { $0.value.nimbusAd.auctionId == auctionId }) {
            element.value.isNimbusWin = true
            dataCache[element.key] = element.value
        }
    }
    
    /// Remove methods
    
    /// :nodoc:
    func removeData(auctionId: String) {
        if let index = dataCache.values.firstIndex(where: { $0.nimbusAd.auctionId == auctionId }) {
            dataCache.remove(at: index)
        }
    }
    
    /// :nodoc
    func removeClickEvent(nimbusAdView: UIView) {
        clickEventCache.removeValue(forKey: nimbusAdView.hash)
    }
}
