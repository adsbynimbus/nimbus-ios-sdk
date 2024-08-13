//
//  NimbusAd+MobileFuse.swift
//  NimbusMobileFuseKit
//
//  Created on 9/14/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusCoreKit
import MobileFuseSDK

extension NimbusAd {
    var mobileFuseBannerAdSize: MFBannerAdSize? {
        guard let dimensions = adDimensions else { return nil }
        
        switch (dimensions.width, dimensions.height) {
        case (300, 50):     return .MOBILEFUSE_BANNER_SIZE_300x50
        case (320, 50):     return .MOBILEFUSE_BANNER_SIZE_320x50
        case (300, 250):    return .MOBILEFUSE_BANNER_SIZE_300x250
        case (728, 90):     return .MOBILEFUSE_BANNER_SIZE_728x90
        default:            return .MOBILEFUSE_BANNER_SIZE_DEFAULT
        }
    }
}
