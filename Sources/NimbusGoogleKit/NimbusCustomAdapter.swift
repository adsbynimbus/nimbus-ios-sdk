//
//  NimbusCustomAdapter.swift
//  NimbusGoogleKit
//
//  Created on 6/27/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import GoogleMobileAds
import NimbusRequestKit

enum NimbusCustomAdapterError: LocalizedError {
    case extrasNotFound
    
    var errorDescription: String? {
        return "Nimbus extras not sent"
    }
}

let nimbusAdMobAdapterName = "NimbusCustomAdapter"

public final class NimbusCustomAdapter: NSObject, MediationAdapter {
    private lazy var adLoader: NimbusAdMobAdLoaderType = NimbusAdMobAdLoader(
        dynamicPriceDecider: NimbusAdMobDynamicPriceDecider(),
        requestManager: NimbusAdMobRequestManager(
            adRequestor: NimbusAdMobAdRequestor(requestManager: NimbusRequestManager()),
            cacheManager: AdMobDynamicPriceCacheManager.shared
        )
    )
    private static let eventManager: NimbusAdMobEventManagerType =
    NimbusAdMobEventManager(
        cacheManager: AdMobDynamicPriceCacheManager.shared,
        auctionNotifier: NimbusAuctionResultNotifier()
    )
    
    public static func adapterVersion() -> VersionNumber {
        adSDKVersion()
    }
    
    public static func adSDKVersion() -> VersionNumber {
        let versionComponents = Nimbus.shared.version.components(separatedBy: ".")
        if versionComponents.count >= 3 {
            let majorVersion = Int(versionComponents[0]) ?? 0
            let minorVersion = Int(versionComponents[1]) ?? 0
            let patchVersion = Int(versionComponents[2]) ?? 0
            return VersionNumber(
                majorVersion: majorVersion,
                minorVersion: minorVersion,
                patchVersion: patchVersion
            )
        }
        
        return VersionNumber()
    }
    
    public static func networkExtrasClass() -> AdNetworkExtras.Type? {
        NimbusGoogleAdNetworkExtras.self
    }
    
    public static func setUp(
        with configuration: MediationServerConfiguration,
        completionHandler: @escaping GADMediationAdapterSetUpCompletionBlock
    ) {
        let isNimbusSdkInitialized = Nimbus.shared.publisher != nil && Nimbus.shared.apiKey != nil
        if isNimbusSdkInitialized {
            completionHandler(nil)
        } else {
            completionHandler(NimbusCoreError.sdkNotInitialized)
        }
    }
    
    public func loadBanner(
        for adConfiguration: MediationBannerAdConfiguration,
        completionHandler: @escaping GADMediationBannerLoadCompletionHandler
    ) {
        adLoader.loadBannerAd(
            for: adConfiguration,
            completion: { result in
                switch result {
                case let .success((ad, _)):
                    NimbusAdMobCustomEventBanner().render(
                        ad: ad,
                        adConfiguration: adConfiguration,
                        completionHandler: completionHandler
                    )
                case let .failure(error):
                    _ = completionHandler(nil, error)
                }
            }
        )
    }
    
    public func loadInterstitial(
        for adConfiguration: MediationInterstitialAdConfiguration,
        completionHandler: @escaping GADMediationInterstitialLoadCompletionHandler
    ) {
        adLoader.loadInterstitialAd(
            for: adConfiguration,
            completion: { result in
                switch result {
                case let .success((ad, companionAd)):
                    NimbusAdMobCustomEventInterstitial().render(
                        ad: ad,
                        companionAd: companionAd,
                        completionHandler: completionHandler
                    )
                case let .failure(error):
                    _ = completionHandler(nil, error)
                }
            }
        )
    }
    
    public func loadRewardedAd(
        for adConfiguration: MediationRewardedAdConfiguration,
        completionHandler: @escaping GADMediationRewardedLoadCompletionHandler
    ) {
        adLoader.loadRewardedAd(
            for: adConfiguration,
            completion: { result in
                switch result {
                case let .success((ad, companionAd)):
                    NimbusAdMobCustomEventRewarded()
                        .render(
                            ad: ad,
                            companionAd: companionAd,
                            completionHandler: completionHandler
                        )
                case let .failure(error):
                    _ = completionHandler(nil, error)
                }
            }
        )
    }
    
    public func loadRewardedInterstitialAd(
        for adConfiguration: MediationRewardedAdConfiguration,
        completionHandler: @escaping GADMediationRewardedLoadCompletionHandler
    ) {
        Nimbus.shared.logger.log("Loading rewarded interstitial ad for AdMob", level: .debug)
        
        loadRewardedAd(for: adConfiguration, completionHandler: completionHandler)
    }
    
    // MARK: Publisher callbacks
    
    public static func notifyPrice(extras: NimbusGoogleAdNetworkExtras, adValue: AdValue) {
        eventManager.notifyPrice(extras: extras, adValue: adValue)
    }
    
    public static func notifyImpression(
        extras: NimbusGoogleAdNetworkExtras,
        adNetworkResponseInfo: AdNetworkResponseInfo?
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            eventManager.notifyImpression(extras: extras, adNetworkResponseInfo: adNetworkResponseInfo)
        }
    }
    
    public static func notifyError(extras: NimbusGoogleAdNetworkExtras, error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            eventManager.notifyError(extras: extras, error: error)
        }
    }
}
