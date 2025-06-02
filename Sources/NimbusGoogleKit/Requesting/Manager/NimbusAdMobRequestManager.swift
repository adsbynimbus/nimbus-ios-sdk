//
//  NimbusAdMobRequestManager.swift
//  Nimbus
//
//  Created on 7/19/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import GoogleMobileAds
@_exported import NimbusKit

typealias AdMobRequestManagerType = NimbusAdMobBannerRequestManagerType &
NimbusAdMobInterstitialRequestManagerType & NimbusAdMobRewardedRequestManagerType

final class NimbusAdMobRequestManager: NimbusAdMobBannerRequestManagerType,
                                        NimbusAdMobInterstitialRequestManagerType,
                                        NimbusAdMobRewardedRequestManagerType
{
    private let requestCreator: NimbusGoogleRequestCreatorType
    private let adRequestor: NimbusAdMobRequestorType
    private let adValidator: AdMobDynamicPriceAdValidatorType
    private let cacheManager: AdMobDynamicPriceCacheManagerType
    private let logger: Logger
    
    init(
        requestCreator: NimbusGoogleRequestCreatorType = NimbusGoogleRequestCreator(),
        adRequestor: NimbusAdMobRequestorType,
        adValidator: AdMobDynamicPriceAdValidatorType = AdMobDynamicPriceAdValidator(),
        cacheManager: AdMobDynamicPriceCacheManagerType,
        logger: Logger = Nimbus.shared.logger
    ) {
        self.requestCreator = requestCreator
        self.adRequestor = adRequestor
        self.adValidator = adValidator
        self.cacheManager = cacheManager
        self.logger = logger
    }
    
    func loadDynamicPriceBanner(
        for adConfiguration: GADMediationBannerAdConfiguration,
        extras: NimbusGoogleAdNetworkExtras,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        logger.log("Loading AdMob Dynamic Price Banner", level: .debug)
        
        retrieveCachedAdOrLoad(
            for: adConfiguration,
            extras: extras,
            loadAd: { [weak self] completion in
                self?.loadBanner(for: adConfiguration, completion: completion)
            },
            completion: completion
        )
    }
    
    func loadBanner(
        for adConfiguration: GADMediationBannerAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        logger.log("Loading AdMob Banner", level: .debug)

        adRequestor.requestAd(
            request: requestCreator.createBannerRequest(for: adConfiguration),
            completion: completion
        )
    }
    
    func loadDynamicPriceInterstitial(
        for adConfiguration: GADMediationInterstitialAdConfiguration,
        extras: NimbusGoogleAdNetworkExtras,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        logger.log("Loading AdMob Dynamic Price Interstitial", level: .debug)

        retrieveCachedAdOrLoad(
            for: adConfiguration,
            extras: extras,
            loadAd: { [weak self] completion in
                self?.loadInterstitial(for: adConfiguration, completion: completion)
            },
            completion: completion
        )
    }
    
    func loadInterstitial(
        for adConfiguration: GADMediationInterstitialAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        logger.log("Loading AdMob Interstitial", level: .debug)

        adRequestor.requestAd(
            request: requestCreator.createInterstitialRequest(for: adConfiguration),
            completion: completion
        )
    }
    
    func loadDynamicPriceRewarded(
        for adConfiguration: GADMediationRewardedAdConfiguration,
        extras: NimbusGoogleAdNetworkExtras,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        logger.log("Loading AdMob Dynamic Price Rewarded", level: .debug)

        retrieveCachedAdOrLoad(
            for: adConfiguration,
            extras: extras,
            loadAd: { [weak self] completion in
                self?.loadRewarded(for: adConfiguration, completion: completion)
            },
            completion: completion
        )
    }
    
    func loadRewarded(
        for adConfiguration: GADMediationRewardedAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        logger.log("Loading AdMob Rewarded", level: .debug)

        adRequestor.requestAd(
            request: requestCreator.createRewardedRequest(for: adConfiguration),
            completion: completion
        )
    }
    
    private func retrieveCachedAdOrLoad(
        for adConfiguration: GADMediationAdConfiguration,
        extras: NimbusGoogleAdNetworkExtras,
        loadAd: (_: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void) -> Void,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        if let cachedItem = cacheManager.fetchItemFromCache(for: adConfiguration, extras: extras) {
            logger.log("Retrieving cached ad for AdMob", level: .debug)

            completeDynamicPriceAdLoad(
                cachedItem: cachedItem,
                adConfiguration: adConfiguration,
                completion: completion
            )
        } else {
            logger.log("Load new ad for AdMob", level: .debug)

            loadAd { [weak self] result in
                guard let self else { return }
                
                let cachedItem = self.createCachedItem(from: result)
                self.cacheManager.cacheItem(cachedItem, extras: extras)
                self.completeDynamicPriceAdLoad(
                    cachedItem: cachedItem,
                    adConfiguration: adConfiguration,
                    completion: completion
                )
            }
        }
    }
    
    private func createCachedItem(
        from result: Result<(NimbusAd, NimbusCompanionAd?), Error>
    ) -> AdMobDynamicPriceCachedItem {
        switch result {
        case let .success((ad, companionAd)):
            return AdMobDynamicPriceCachedItem(ad: ad, companionAd: companionAd)
        case let .failure(error):
            return AdMobDynamicPriceCachedItem(error: error)
        }
    }
    
    private func completeDynamicPriceAdLoad(
        cachedItem: AdMobDynamicPriceCachedItem,
        adConfiguration: GADMediationAdConfiguration,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        switch cachedItem.itemType {
        case let .failed(error):
            completion(.failure(error))
        case let .fill(ad, companionAd):
            do {
                try adValidator.validate(ad: ad, for: adConfiguration)
                completion(.success((ad, companionAd)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
