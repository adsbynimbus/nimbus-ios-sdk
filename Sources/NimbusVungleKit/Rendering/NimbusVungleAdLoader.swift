//
//  NimbusVungleAdLoader.swift
//  NimbusVungleKit
//
//  Created on 18/05/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRenderKit
import VungleAdsSDK

typealias VungleAdDelegate = VungleBannerViewDelegate 
                            & VungleInterstitialDelegate
                            & VungleRewardedDelegate
                            & VungleNativeDelegate

protocol NimbusVungleAdLoaderType {
    var adType: NimbusAdType? { get set }
    var delegate: VungleAdDelegate? { get set }
    var bannerAd: VungleBannerView? { get }
    var interstitialAd: VungleInterstitial? { get }
    var rewardedAd: VungleRewarded? { get }
    var nativeAd: VungleNative? { get }
    
    func load(ad: NimbusAd, placementId: String) throws
    func destroy()
}

final class NimbusVungleAdLoader: NimbusVungleAdLoaderType {

    weak var delegate: VungleAdDelegate?
    
    private(set) var bannerAd: VungleBannerView?
    
    private(set) var interstitialAd: VungleInterstitial?
    
    private(set) var rewardedAd: VungleRewarded?
    
    private(set) var nativeAd: VungleNative?
    
    var adType: NimbusAdType?
    
    func load(ad: NimbusAd, placementId: String) throws {
        switch adType {
        case .rewarded:
            loadRewardedAd(placementId: placementId, markup: ad.markup)
        case .interstitial:
            loadInterstitialAd(placementId: placementId, markup: ad.markup)
        case .banner:
            guard let dimensions = ad.adDimensions else {
                throw NimbusVungleError.failedToLoadAd(message: "Nimbus Ad dimensions are missing")
            }
            
            let adSize = VungleAdSize.VungleAdSizeFromCGSize(CGSize(width: dimensions.width, height: dimensions.height))
            loadBannerAd(placementId: placementId, markup: ad.markup, size: adSize)
        case .native:
            loadNativeAd(placementId: placementId, markup: ad.markup)
        default:
            throw NimbusVungleError.failedToLoadAd(
                message: "Invalid ad type to render Vungle ad: \(String(describing: adType))"
            )
        }
    }
    
    func loadBannerAd(placementId: String, markup: String, size: VungleAdSize) {
        bannerAd = VungleBannerView(placementId: placementId, vungleAdSize: size)
        bannerAd?.delegate = delegate
        bannerAd?.load(markup)
    }
    
    func loadInterstitialAd(placementId: String, markup: String) {
        interstitialAd = VungleInterstitial(placementId: placementId)
        interstitialAd?.delegate = delegate
        interstitialAd?.load(markup)
    }
    
    func loadRewardedAd(placementId: String, markup: String) {
        rewardedAd = VungleRewarded(placementId: placementId)
        rewardedAd?.delegate = delegate
        rewardedAd?.load(markup)
    }
    
    func loadNativeAd(placementId: String, markup: String) {
        nativeAd = VungleNative(placementId: placementId)
        nativeAd?.delegate = delegate
        nativeAd?.load(markup)
    }
    
    func destroy() {
        bannerAd?.delegate = nil
        bannerAd = nil
        
        interstitialAd?.delegate = nil
        interstitialAd = nil
        
        rewardedAd?.delegate = nil
        rewardedAd = nil
        
        nativeAd?.delegate = nil
        nativeAd = nil
    }
}
