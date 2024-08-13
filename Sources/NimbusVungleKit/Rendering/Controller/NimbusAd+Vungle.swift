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
    var vungleAdSize: VungleAdSize? {
        guard let width = adDimensions?.width,
              let height = adDimensions?.height else {
            return nil
        }
    
        // Account for device's orientation.
        let calculatedSize = width * height

        switch (calculatedSize) {
        case 16000: return .VungleAdSizeBannerRegular   // 320*50
        case 15000: return .VungleAdSizeBannerShort     // 300*50
        case 65520: return .VungleAdSizeLeaderboard     // 728*90
        case 75000: return .VungleAdSizeMREC            // 300*250
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
