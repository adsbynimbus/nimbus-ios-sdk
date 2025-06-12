//
//  NimbusAdMobRequestManagerTypes.swift
//  Nimbus
//
//  Created on 7/27/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import GoogleMobileAds
@_exported import NimbusRequestKit

protocol NimbusAdMobBannerRequestManagerType: AnyObject {
    func loadDynamicPriceBanner(
        for adConfiguration: MediationBannerAdConfiguration,
        extras: NimbusGoogleAdNetworkExtras,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
    
    func loadBanner(
        for adConfiguration: MediationBannerAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
}

protocol NimbusAdMobInterstitialRequestManagerType: AnyObject {
    func loadDynamicPriceInterstitial(
        for adConfiguration: MediationInterstitialAdConfiguration,
        extras: NimbusGoogleAdNetworkExtras,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
    
    func loadInterstitial(
        for adConfiguration: MediationInterstitialAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
}

protocol NimbusAdMobRewardedRequestManagerType: AnyObject {
    func loadDynamicPriceRewarded(
        for adConfiguration: MediationRewardedAdConfiguration,
        extras: NimbusGoogleAdNetworkExtras,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
    
    func loadRewarded(
        for adConfiguration: MediationRewardedAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
}
