//
//  NimbusVungleAdLoader.swift
//  NimbusVungleKit
//
//  Created by Inder Dhir on 2/16/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

@_exported import NimbusRenderKit
import VungleSDK

final class NimbusVungleAdLoader {
    
    enum AdType {
        case mrecOrBanner, interstitial
    }
    
    private let vungleProxyType: NimbusVungleProxyType
    private let logger: Logger
    private(set) var isLoaded = false
    var isAllowedToStart = false
        
    init(
        vungleProxyType: NimbusVungleProxyType,
        logger: Logger
    ) {
        self.vungleProxyType = vungleProxyType
        self.logger = logger
    }
    
    func loadAd(_ ad: NimbusAd, placementId: String) throws {
        if ad.isAdSizeBannerType {
            try loadBannerAd(placementId: placementId, markup: ad.markup, adSize: ad.vungleAdSize)
        } else if ad.isAdMRECType {
            try loadMrecAd(placementId: placementId, markup: ad.markup)
        } else if (ad.auctionType == .video || ad.isInterstitial) {
            try loadInterstitialAd(placementId: placementId, markup: ad.markup)
        } else {
            throw NimbusVungleError.failedToLoadAd(message: "No matching Vungle ad auction type found.")
        }
    }
    
    func start(ad: NimbusAd) throws -> AdType {
        isAllowedToStart = false
        
        if ad.isAdMRECType || ad.isAdSizeBannerType {
            return .mrecOrBanner
        } else if ad.isInterstitial {
            return .interstitial
        }
        
        let message = "Not supported Ad type received. Only Banners and Interstitials are supported."
        throw NimbusRenderError.adRenderingFailed(message: message)
    }
    
    func completeAdLoad() {
        isLoaded = true
    }
    
    func completeAdLoadWithError() {
        isLoaded = false
        isAllowedToStart = false
    }
    
    func allowAdStart() {
        isAllowedToStart = true
    }
    
    private func loadBannerAd(placementId: String, markup: String, adSize: VungleAdSize) throws {
        do {
            // Vungle triggers adPlayabilityUpdate before loadPlacement returns so this bool needs to be set first
            isAllowedToStart = true
            try vungleProxyType.loadPlacement(id: placementId, markup: markup, with: adSize)
        } catch {
            logger.log("Vungle failed to play banner ad. Error: \(error)", level: .debug)
            
            throw NimbusVungleError.failedToLoadStaticAd(type: "banner", message: error.localizedDescription)
        }
    }
    
    private func loadMrecAd(placementId: String, markup: String) throws {
        do {
            // Vungle triggers adPlayabilityUpdate before loadPlacement returns so this bool needs to be set first
            isAllowedToStart = true
            try vungleProxyType.loadPlacement(id: placementId, markup: markup)
        } catch {
            logger.log("Vungle failed to play MREC ad. Error: \(error)", level: .debug)
                        
            throw NimbusVungleError.failedToLoadStaticAd(type: "mrec", message: error.localizedDescription)
        }
    }
    
    private func loadInterstitialAd(placementId: String, markup: String) throws {
        do {
            // Vungle triggers adPlayabilityUpdate before loadPlacement returns so this bool needs to be set first
            isAllowedToStart = true
            try vungleProxyType.loadPlacement(id: placementId, markup: markup)
        } catch {
            logger.log("Vungle failed to play interstitial ad. Error: \(error)", level: .debug)
                        
            throw NimbusVungleError.failedToLoadStaticAd(type: "interstitial", message: error.localizedDescription)
        }
    }
}
