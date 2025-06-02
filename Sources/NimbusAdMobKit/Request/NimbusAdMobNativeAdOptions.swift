//
//  NimbusAdMobNativeAdOptions.swift
//  NimbusInternalSampleApp
//  Created on 9/12/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import GoogleMobileAds

/// AdMob native ad options. Default values match GoogleMobileAds' SDK ones.
public struct NimbusAdMobNativeAdOptions {
    let disableImageLoading: Bool
    let shouldRequestMultipleImages: Bool
    let mediaAspectRatio: GADMediaAspectRatio
    let preferredAdChoicesPosition: GADAdChoicesPosition
    let customMuteThisAdRequested: Bool
    
    public init(
        disableImageLoading: Bool = false,
        shouldRequestMultipleImages: Bool = false,
        mediaAspectRatio: GADMediaAspectRatio = .unknown,
        preferredAdChoicesPosition: GADAdChoicesPosition = .topRightCorner,
        customMuteThisAdRequested: Bool = false
    ) {
        self.disableImageLoading = disableImageLoading
        self.shouldRequestMultipleImages = shouldRequestMultipleImages
        self.mediaAspectRatio = mediaAspectRatio
        self.preferredAdChoicesPosition = preferredAdChoicesPosition
        self.customMuteThisAdRequested = customMuteThisAdRequested
    }
}
