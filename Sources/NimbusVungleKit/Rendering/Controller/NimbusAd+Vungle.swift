//
//  NimbusAd+Vungle.swift
//  NimbusVungleKit
//
//  Created by Inder Dhir on 2/16/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

@_exported import NimbusRenderKit
import VungleAdsSDK

extension NimbusAd {
    
    var vungleAdSize: BannerSize? {
        switch (adDimensions?.width, adDimensions?.height) {
        case (320, 50): return .regular
        case (300, 50): return .short
        case (728, 90): return .leaderboard
        case (300, 250): return .mrec
        default: return nil
        }
    }
}
