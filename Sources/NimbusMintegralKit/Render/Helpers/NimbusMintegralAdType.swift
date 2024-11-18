//
//  NimbusMintegralAdType.swift
//  Nimbus
//  Created on 10/31/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusCoreKit

enum NimbusMintegralAdType {
    case banner(width: Int, height: Int)
    case native
    case interstitial
    case rewarded
    
    init?(ad: NimbusAd, isBlocking: Bool) {
        if isBlocking {
            switch ad.auctionType {
            case .static: self = .interstitial
            case .video: self = .rewarded
            default: return nil
            }
        } else {
            switch ad.auctionType {
            case .native: self = .native
            case .static, .video:
                if let size = ad.adDimensions { self = .banner(width: size.width, height: size.height) }
                else { return nil }
            @unknown default: return nil
            }
        }
    }
}
