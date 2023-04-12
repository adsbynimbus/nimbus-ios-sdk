//
//  NimbusAd+Vungle.swift
//  NimbusVungleKit
//
//  Created by Inder Dhir on 2/16/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

@_exported import NimbusRenderKit
import VungleSDK

extension NimbusAd {
    
    var vungleAdSize: VungleAdSize {
        switch (adDimensions?.width, adDimensions?.height) {
        case (320, 50): return .banner
        case (300, 50): return .bannerShort
        case (728, 90): return .bannerLeaderboard
        default: return .unknown
        }
    }
    
    var isAdMRECType: Bool {
        adDimensions?.width == 300 && adDimensions?.height == 250
    }
    
    var isAdSizeBannerType: Bool {
        vungleAdSize != .unknown
    }
    
    var adType: String {
        if isInterstitial {
            return "interstitial"
        }
        return isAdMRECType ? "mrec" : "banner"
    }
}
