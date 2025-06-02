//
//  NimbusRequest+AdMob.swift
//  NimbusInternalSampleApp
//  Created on 9/12/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusKit

public extension NimbusRequest {
    /**
     Include AdMob bidding in the current Banner request.
     
     Example including AdMob in a banner request:
     ```swift
     NimbusRequest.forBannerAd("position").withAdMobBanner(adUnitId: "adUnit")
     ```
     
     - Parameters:
        - adUnitId: AdMob ad unit id
     
     - Returns: NimbusRequest
     */
    @discardableResult
    func withAdMobBanner(adUnitId: String) -> NimbusRequest {
        withAdMob(interceptor: NimbusAdMobRequestInterceptor(adUnitId: adUnitId, adType: .banner))
    }
        
    /**
     Include AdMob bidding in the current Native request.
     
     Example including AdMob in a native request:
     ```swift
     NimbusRequest.forNativeAd("position").withAdMobNative(adUnitId: "adUnit")
     ```
     
     - Parameters:
        - adUnitId: AdMob ad unit id
     
     - Returns: NimbusRequest
     */
    @discardableResult
    func withAdMobNative(
        adUnitId: String,
        nativeAdOptions: NimbusAdMobNativeAdOptions? = nil
    ) -> NimbusRequest {
        withAdMob(interceptor: NimbusAdMobRequestInterceptor(adUnitId: adUnitId, adType: .native, nativeAdOptions: nativeAdOptions))
    }

    /**
     Include AdMob bidding in the current Interstitial request.
     
     Example including AdMob in an interstitial request:
     ```swift
     NimbusRequest.forInterstitialAd("position").withAdMobInterstitial(adUnitId: "adUnit")
     ```
     
     - Parameters:
        - adUnitId: AdMob ad unit id
     
     - Returns: NimbusRequest
     */
    @discardableResult
    func withAdMobInterstitial(adUnitId: String) -> NimbusRequest {
        withAdMob(interceptor: NimbusAdMobRequestInterceptor(adUnitId: adUnitId, adType: .interstitial))
    }

    /**
     Include AdMob bidding in the current Rewarded request.
     
     Example including AdMob in a rewarded request:
     ```swift
     NimbusRequest.forRewardedVideo("position").withAdMobRewarded(adUnitId: "adUnit")
     ```
     
     - Parameters:
        - adUnitId: AdMob ad unit id
     
     - Returns: NimbusRequest
     */
    @discardableResult
    func withAdMobRewarded(adUnitId: String) -> NimbusRequest {
        withAdMob(interceptor: NimbusAdMobRequestInterceptor(adUnitId: adUnitId, adType: .rewarded))
    }
    
    private func withAdMob(interceptor: NimbusAdMobRequestInterceptor) -> NimbusRequest {
        if interceptors == nil { interceptors = [] }
        interceptors?.append(interceptor)
        return self
    }
}
