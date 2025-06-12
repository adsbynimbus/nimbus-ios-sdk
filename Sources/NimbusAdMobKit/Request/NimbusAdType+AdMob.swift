//
//  NimbusAdType+AdMob.swift
//  Nimbus
//  Created on 2/24/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusRequestKit
import NimbusRenderKit
import GoogleMobileAds

enum NimbusAdMobRequestError: NimbusError {
    case unknownAdType(NimbusAdType)
    case missingBannerSize
    case missingNativeAdOptions
    
    var errorDescription: String? {
        switch self {
        case .unknownAdType(let adType):
            return "Unknown ad type case: \(adType)"
        case .missingBannerSize:
            return "Banner size must be present to generate a banner request"
        case .missingNativeAdOptions:
            return "NimbusAdMobNativeAdOptions must be provided for AdMob native ad interceptor"
        }
    }
}

public extension NimbusAdType {
    func adMobSignalRequest(
        adUnitId: String,
        bannerSize: CGSize? = nil,
        nativeAdOptions: NimbusAdMobNativeAdOptions? = nil
    ) throws -> SignalRequest {
        let signalRequest = try signalFromAdType(bannerSize: bannerSize, nativeAdOptions: nativeAdOptions)
        signalRequest.adUnitID = adUnitId
        signalRequest.requestAgent = "nimbus"
        
        let extras = Extras()
        extras.additionalParameters = ["query_info_type": "requester_type_2"]
        signalRequest.register(extras)
        return signalRequest
    }
    
    internal func adMobSignalRequest(
        from request: NimbusRequest,
        adUnitId: String,
        nativeAdOptions: NimbusAdMobNativeAdOptions? = nil
    ) throws -> SignalRequest {
        let bannerSize: CGSize?
        
        if case .banner = self, let banner = request.impressions.first?.banner {
            bannerSize = CGSize(width: banner.width, height: banner.height)
        } else {
            bannerSize = nil
        }
        
        return try adMobSignalRequest(adUnitId: adUnitId, bannerSize: bannerSize, nativeAdOptions: nativeAdOptions)
    }
    
    private func signalFromAdType(
        bannerSize: CGSize? = nil,
        nativeAdOptions: NimbusAdMobNativeAdOptions? = nil
    ) throws -> SignalRequest {
        switch self {
        case .banner:
            guard let bannerSize else {
                throw NimbusAdMobRequestError.missingBannerSize
            }
            
            let signalRequest = BannerSignalRequest(signalType: "requester_type_2")
            signalRequest.adSize = adSizeFor(cgSize: bannerSize)
            return signalRequest
        case .native:
            guard let nativeAdOptions else {
                throw NimbusAdMobRequestError.missingNativeAdOptions
            }
            
            let signal = NativeSignalRequest(signalType: "requester_type_2")
            signal.isImageLoadingDisabled = nativeAdOptions.disableImageLoading
            signal.shouldRequestMultipleImages = nativeAdOptions.shouldRequestMultipleImages
            signal.mediaAspectRatio = nativeAdOptions.mediaAspectRatio
            signal.preferredAdChoicesPosition = nativeAdOptions.preferredAdChoicesPosition
            signal.isCustomMuteThisAdRequested = nativeAdOptions.customMuteThisAdRequested
            return signal
        case .interstitial:
            return InterstitialSignalRequest(signalType: "requester_type_2")
        case .rewarded:
            return RewardedSignalRequest(signalType: "requester_type_2")
        @unknown default:
            throw NimbusAdMobRequestError.unknownAdType(self)
        }
    }
}
