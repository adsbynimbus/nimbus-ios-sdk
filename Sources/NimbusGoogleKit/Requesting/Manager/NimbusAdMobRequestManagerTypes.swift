//
//  NimbusAdMobRequestManagerTypes.swift
//  Nimbus
//
//  Created by Inder Dhir on 7/27/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

import Foundation
import GoogleMobileAds
@_exported import NimbusRequestKit

protocol NimbusAdMobBannerRequestManagerType: AnyObject {
    func loadDynamicPriceBanner(
        for adConfiguration: GADMediationBannerAdConfiguration,
        extras: NimbusGoogleAdNetworkExtras,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
    
    func loadBanner(
        for adConfiguration: GADMediationBannerAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
}

protocol NimbusAdMobInterstitialRequestManagerType: AnyObject {
    func loadDynamicPriceInterstitial(
        for adConfiguration: GADMediationInterstitialAdConfiguration,
        extras: NimbusGoogleAdNetworkExtras,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
    
    func loadInterstitial(
        for adConfiguration: GADMediationInterstitialAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
}

protocol NimbusAdMobRewardedRequestManagerType: AnyObject {
    func loadDynamicPriceRewarded(
        for adConfiguration: GADMediationRewardedAdConfiguration,
        extras: NimbusGoogleAdNetworkExtras,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
    
    func loadRewarded(
        for adConfiguration: GADMediationRewardedAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
}
