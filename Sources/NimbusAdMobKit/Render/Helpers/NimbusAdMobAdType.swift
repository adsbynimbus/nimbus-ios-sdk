//
//  NimbusAdMobAdType.swift
//  NimbusAdMobKit
//  Created on 9/4/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusKit

enum NimbusAdMobAdType {
    case banner
    case native
    case interstitial
    case rewarded
    
    init?(ad: NimbusAd, isBlocking: Bool) {
        switch ad.auctionType {
        case .static: self = isBlocking ? .interstitial : .banner
        case .video: self = isBlocking ? .rewarded : .banner
        case .native:
            if !isBlocking { self = .native }
            else { return nil }
        @unknown default: return nil
        }
    }
}
