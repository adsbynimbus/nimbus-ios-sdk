//
//  NimbusAd+Vungle.swift
//  NimbusVungleKit
//
//  Created on 2/16/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRenderKit
import VungleAdsSDK

enum NimbusVungleAdType: String {
    case fullScreenBlocking, rewarded, banner, native
}

extension NimbusAd {
    
    var vungleAdSize: BannerSize? {
        guard let width = adDimensions?.width,
              let height = adDimensions?.height else {
            return nil
        }
    
        // Account for device's orientation.
        let calculatedSize = width * height

        switch (calculatedSize) {
        case 16000: return .regular // 320*50
        case 15000: return .short // 300*50
        case 65520: return .leaderboard // 728*90
        case 75000: return .mrec // 300*250
        default: return nil
        }
    }
    
    var vungleAdType: NimbusVungleAdType? {
        switch (auctionType, vungleAdSize) {
        case (.static, .leaderboard),
            (.static, .mrec),
            (.static, .regular),
            (.static, .short):
            return .banner
        case (.static, _): return .fullScreenBlocking
        case (.video, nil): return .rewarded
        case (.native, _): return .native
        default:
            return nil
        }
    }
}
