//
//  AdMobDynamicPriceCacheManager.swift
//  Nimbus
//
//  Created on 7/29/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import GoogleMobileAds
@_exported import NimbusKit

protocol AdMobDynamicPriceCacheManagerType {
    func fetchItemFromCache(
        for adConfiguration: GADMediationAdConfiguration,
        extras: NimbusGoogleAdNetworkExtras
    ) -> AdMobDynamicPriceCachedItem?
    func cacheItem(_ item: AdMobDynamicPriceCachedItem, extras: NimbusGoogleAdNetworkExtras)
    func updatePrice(extras: NimbusGoogleAdNetworkExtras, price: String)
    func removeItemFromCache(extras: NimbusGoogleAdNetworkExtras) -> AdMobDynamicPriceCachedItem?
}

// This is a singleton because the cache needs to outlive the lifecycle of NimbusCustomAdapter which is repeatedly deallocated for Dynamic Price
final class AdMobDynamicPriceCacheManager: AdMobDynamicPriceCacheManagerType {
    let extrasToAdFillCache: NSCache<NimbusGoogleAdNetworkExtras, AdMobDynamicPriceCachedItem>
    private let serialQueue = DispatchQueue(label: "nimbus_dp_admob_cache_queue")
    static let shared = AdMobDynamicPriceCacheManager()
    
    private init() {
        extrasToAdFillCache = .init()
    }
    
    init(_ cache: NSCache<NimbusGoogleAdNetworkExtras, AdMobDynamicPriceCachedItem>) {
        extrasToAdFillCache = cache
    }
    
    func fetchItemFromCache(
        for adConfiguration: GADMediationAdConfiguration,
        extras: NimbusGoogleAdNetworkExtras
    ) -> AdMobDynamicPriceCachedItem? {
        return serialQueue.sync {
            let cachedItem = extrasToAdFillCache.object(forKey: extras)
            let updatedCachedItem = refreshCachedItem(
                for: adConfiguration,
                extras: extras,
                cachedItem: cachedItem
            )
            return updatedCachedItem
        }
    }
    
    func cacheItem(_ item: AdMobDynamicPriceCachedItem, extras: NimbusGoogleAdNetworkExtras) {
        serialQueue.async { [weak self] in
            self?.extrasToAdFillCache.setObject(item, forKey: extras)
        }
    }
    
    func updatePrice(extras: NimbusGoogleAdNetworkExtras, price: String) {
        serialQueue.sync {
            if let cachedItem = extrasToAdFillCache.object(forKey: extras) {
                cachedItem.price = price
            }
        }
    }
    
    func removeItemFromCache(extras: NimbusGoogleAdNetworkExtras) -> AdMobDynamicPriceCachedItem? {
        serialQueue.sync {
            let item = extrasToAdFillCache.object(forKey: extras)
            extrasToAdFillCache.removeObject(forKey: extras)
            return item
        }
    }
    
    private func refreshCachedItem(
        for adConfiguration: GADMediationAdConfiguration,
        extras: NimbusGoogleAdNetworkExtras,
        cachedItem: AdMobDynamicPriceCachedItem?
    ) -> AdMobDynamicPriceCachedItem? {
        guard let cachedItem else { return nil }
        
        let removeItemFromCache = isTopOfWaterfall(for: adConfiguration) || hasAdExpired(cachedItem: cachedItem)
        if removeItemFromCache {
            extrasToAdFillCache.removeObject(forKey: extras)
            return nil
        }
        return cachedItem
    }
    
    private func isTopOfWaterfall(for adConfiguration: GADMediationAdConfiguration) -> Bool {
        if let label = adConfiguration.credentials.settings["label"] as? String,
           label.lowercased().contains("top") {
            return true
        }
        return false
    }
    
    private func hasAdExpired(cachedItem: AdMobDynamicPriceCachedItem) -> Bool {
        guard case let .fill(ad, _) = cachedItem.itemType, let adExpiration = ad.exp else {
            return false
        }
        
        let timestampDifference = Int(Date().timeIntervalSince1970) - cachedItem.timestamp
        return adExpiration - timestampDifference <= 0
    }
}
