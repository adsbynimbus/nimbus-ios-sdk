//
//  NimbusVungleAdLoader.swift
//  NimbusVungleKit
//
//  Created by Victor Takai on 18/05/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

@_exported import NimbusRenderKit
import VungleAdsSDK

typealias VungleAdDelegate = VungleBannerDelegate & VungleInterstitialDelegate & VungleRewardedDelegate

protocol NimbusVungleAdLoaderType {
    var delegate: VungleAdDelegate? { get set }
    var bannerAd: VungleBanner? { get }
    var interstitialAd: VungleInterstitial? { get }
    var rewardedAd: VungleRewarded? { get }
    
    func load(ad: NimbusAd, placementId: String) throws
    func destroy()
}

final class NimbusVungleAdLoader: NimbusVungleAdLoaderType {

    weak var delegate: VungleAdDelegate?
    
    private(set) var bannerAd: VungleBanner?
    
    private(set) var interstitialAd: VungleInterstitial?
    
    private(set) var rewardedAd: VungleRewarded?
    
    func load(ad: NimbusAd, placementId: String) throws {
        switch ad.vungleAdType {
        case .rewarded:
            loadRewardedAd(placementId: placementId, markup: ad.markup)
        case .fullScreenBlocking:
            loadInterstitialAd(placementId: placementId, markup: ad.markup)
        case .banner:
            loadBannerAd(placementId: placementId, markup: ad.markup, size: ad.vungleAdSize!)
        case .none:
            throw NimbusVungleError.failedToLoadAd(
                message: "No matching Vungle Ad auction type found. Size(\(ad.vungleAdSize?.rawValue ?? -1)) - Type(\(ad.auctionType))"
            )
        }
    }
    
    func loadBannerAd(placementId: String, markup: String, size: BannerSize) {
        bannerAd = VungleBanner(placementId: placementId, size: size)
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
    
    func destroy() {
        bannerAd?.delegate = nil
        bannerAd = nil
        
        interstitialAd?.delegate = nil
        interstitialAd = nil
        
        rewardedAd?.delegate = nil
        rewardedAd = nil
    }
}
