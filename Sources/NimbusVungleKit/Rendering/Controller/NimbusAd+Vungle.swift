//
//  NimbusAd+Vungle.swift
//  NimbusVungleKit
//
//  Created on 2/16/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRenderKit
import VungleAdsSDK

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
    
    func vungleAdType(isBlocking: Bool) -> NimbusVungleAdType? {
        switch auctionType {
        case .static:
            return isBlocking ? .fullScreenBlocking : .banner
        case .video: return .rewarded
        case .native: return .native
        default:
            return nil
        }
    }
}
