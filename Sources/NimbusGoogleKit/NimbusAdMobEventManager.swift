//
//  NimbusAdMobEventManager.swift
//  Nimbus
//
//  Created on 7/31/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import GoogleMobileAds
import NimbusRequestKit

protocol NimbusAdMobEventManagerType: AnyObject {
    func notifyPrice(extras: NimbusGoogleAdNetworkExtras, adValue: AdValue)
    func notifyImpression(
        extras: NimbusGoogleAdNetworkExtras,
        adNetworkResponseInfo: AdNetworkResponseInfo?
    )
    func notifyError(extras: NimbusGoogleAdNetworkExtras, error: Error)
}

final class NimbusAdMobEventManager: NimbusAdMobEventManagerType {
    private let cacheManager: AdMobDynamicPriceCacheManagerType
    private let auctionNotifier: NimbusAuctionResultNotifierType
    private let logger: Logger

    init(
        cacheManager: AdMobDynamicPriceCacheManagerType,
        auctionNotifier: NimbusAuctionResultNotifierType,
        logger: Logger = Nimbus.shared.logger
    ) {
        self.cacheManager = cacheManager
        self.auctionNotifier = auctionNotifier
        self.logger = logger
    }
    
    func notifyPrice(extras: NimbusGoogleAdNetworkExtras, adValue: AdValue) {
        logger.log("Notifying price for AdMob", level: .debug)
        
        let cpmValue = adValue.value.multiplying(byPowerOf10: 3)
        cacheManager.updatePrice(extras: extras, price: cpmValue.stringValue)
    }
    
    func notifyImpression(
        extras: NimbusGoogleAdNetworkExtras,
        adNetworkResponseInfo: AdNetworkResponseInfo?
    ) {
        let hasRenderedNimbusAd =
        adNetworkResponseInfo?.adNetworkClassName.contains(nimbusAdMobAdapterName) ?? false
        
        var cachedItem: AdMobDynamicPriceCachedItem?
        var nimbusAd: NimbusAd?
        if let itemFromCache = cacheManager.removeItemFromCache(extras: extras),
           case let .fill(ad, _) = itemFromCache.itemType {
            cachedItem = itemFromCache
            nimbusAd = ad
        }
        guard let cachedItem, let nimbusAd else { return }
        
        if hasRenderedNimbusAd {
            logger.log("Notifying win for AdMob", level: .debug)
            
            auctionNotifier.notifyWin(ad: nimbusAd, auctionData: nil)
        } else {
            logger.log("Notifying loss for AdMob", level: .debug)
            
            auctionNotifier.notifyLoss(ad: nimbusAd, auctionData: .init(auctionPrice: cachedItem.price ?? "-1"))
        }
    }
    
    func notifyError(extras: NimbusGoogleAdNetworkExtras, error: Error) {
        let errorCode = RequestError(_nsError: (error as NSError)).code
        
        guard errorCode == .noFill else { return }
        
        if let cachedItem = cacheManager.removeItemFromCache(extras: extras),
           case let .fill(ad, _) = cachedItem.itemType {
            logger.log("Notifying loss for AdMob", level: .debug)

            auctionNotifier.notifyLoss(ad: ad, auctionData: .init(auctionPrice: cachedItem.price ?? "-1"))
        }
    }
}
