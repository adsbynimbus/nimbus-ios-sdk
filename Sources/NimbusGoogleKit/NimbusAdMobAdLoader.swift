//
//  NimbusAdMobAdLoader.swift
//  Nimbus
//
//  Created on 7/29/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import GoogleMobileAds
@_exported import NimbusKit

protocol NimbusAdMobAdLoaderType {
    func loadBannerAd(
        for adConfiguration: MediationBannerAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
    func loadInterstitialAd(
        for adConfiguration: MediationInterstitialAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
    func loadRewardedAd(
        for adConfiguration: MediationRewardedAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
}

final class NimbusAdMobAdLoader: NimbusAdMobAdLoaderType {
    private let dynamicPriceDecider: NimbusAdMobDynamicPriceDeciderType
    private let requestManager: AdMobRequestManagerType
    private let logger: Logger
    
    init(
        dynamicPriceDecider: NimbusAdMobDynamicPriceDeciderType,
        requestManager: AdMobRequestManagerType,
        logger: Logger = Nimbus.shared.logger
    ) {
        self.dynamicPriceDecider = dynamicPriceDecider
        self.requestManager = requestManager
        self.logger = logger
    }
    
    func loadBannerAd(
        for adConfiguration: MediationBannerAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        let isDynamicPrice = dynamicPriceDecider.isDynamicPrice(adConfiguration: adConfiguration)
        if isDynamicPrice {
            logger.log("Loading AdMob Banner for Dynamic Price", level: .debug)

            loadBannerAdForDynamicPrice(for: adConfiguration, completion: completion)
        } else {
            logger.log("Loading AdMob Banner", level: .debug)

            requestManager.loadBanner(for: adConfiguration, completion: completion)
        }
    }
    
    func loadInterstitialAd(
        for adConfiguration: MediationInterstitialAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        let isDynamicPrice = dynamicPriceDecider.isDynamicPrice(adConfiguration: adConfiguration)
        if isDynamicPrice {
            logger.log("Loading AdMob Interstitial for Dynamic Price", level: .debug)

            loadInterstitialAdForDynamicPrice(for: adConfiguration, completion: completion)
        } else {
            logger.log("Loading AdMob Interstitial", level: .debug)

            requestManager.loadInterstitial(for: adConfiguration, completion: completion)
        }
    }
    
    func loadRewardedAd(
        for adConfiguration: MediationRewardedAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        let isDynamicPrice = dynamicPriceDecider.isDynamicPrice(adConfiguration: adConfiguration)
        if isDynamicPrice {
            logger.log("Loading AdMob Rewarded for Dynamic Price", level: .debug)

            loadRewardedAdForDynamicPrice(for: adConfiguration, completion: completion)
        } else {
            logger.log("Loading AdMob Rewarded", level: .debug)

            requestManager.loadRewarded(for: adConfiguration, completion: completion)
        }
    }
 
    private func loadBannerAdForDynamicPrice(
        for adConfiguration: MediationBannerAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        guard let extras = adConfiguration.extras as? NimbusGoogleAdNetworkExtras else {
            completion(.failure(NimbusCustomAdapterError.extrasNotFound))
            return
        }
        
        requestManager.loadDynamicPriceBanner(
            for: adConfiguration,
            extras: extras,
            completion: completion
        )
    }
    
    private func loadInterstitialAdForDynamicPrice(
        for adConfiguration: MediationInterstitialAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        guard let extras = adConfiguration.extras as? NimbusGoogleAdNetworkExtras else {
            completion(.failure(NimbusCustomAdapterError.extrasNotFound))
            return
        }
        
        requestManager.loadDynamicPriceInterstitial(
            for: adConfiguration,
            extras: extras,
            completion: completion
        )
    }
 
    private func loadRewardedAdForDynamicPrice(
        for adConfiguration: MediationRewardedAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        guard let extras = adConfiguration.extras as? NimbusGoogleAdNetworkExtras else {
            completion(.failure(NimbusCustomAdapterError.extrasNotFound))
            return
        }
        
        requestManager.loadDynamicPriceRewarded(
            for: adConfiguration,
            extras: extras,
            completion: completion
        )
    }
}
