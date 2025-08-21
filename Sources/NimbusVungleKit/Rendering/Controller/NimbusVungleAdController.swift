//
//  NimbusVungleAdController.swift
//  NimbusVungleKit
//
//  Created on 13/09/22.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusRenderKit
import UIKit
import VungleAdsSDK

final class NimbusVungleAdController: NimbusAdController,
                                      VungleBannerViewDelegate,
                                      VungleNativeDelegate,
                                      VungleInterstitialDelegate,
                                      VungleRewardedDelegate {
    
    var adLoader: NimbusVungleAdLoaderType
    let adPresenter: NimbusVungleAdPresenterType
    
    weak var adRendererDelegate: NimbusVungleAdRendererDelegate?
    
    /// Determines whether ad has registered an impression
    private var hasRegisteredAdImpression = false
    
    init(
        ad: NimbusAd,
        adLoader: NimbusVungleAdLoaderType? = nil,
        adPresenter: NimbusVungleAdPresenterType = NimbusVungleAdPresenter(),
        container: UIView,
        logger: Logger,
        delegate: (any AdControllerDelegate)?,
        adPresentingViewController: UIViewController?,
        isBlocking: Bool,
        isRewarded: Bool,
        adRendererDelegate: NimbusVungleAdRendererDelegate? = nil
    ) {
        self.adLoader = adLoader ?? NimbusVungleAdLoader()
        self.adPresenter = adPresenter
        self.adRendererDelegate = adRendererDelegate
        
        super.init(
            ad: ad,
            isBlocking: isBlocking,
            isRewarded: isRewarded,
            logger: logger,
            container: container,
            delegate: delegate,
            adPresentingViewController: adPresentingViewController
        )
        
        self.adLoader.delegate = self
        self.adLoader.adType = adType
    }
    
    func load() {
        do {
            guard let placementId = ad.placementId else {
                throw NimbusVungleError.failedToLoadAd(message: "Placement Id not found.")
            }
            
            try adLoader.load(ad: ad, placementId: placementId)
        } catch {
            if let nimbusError = error as? NimbusError {
                sendNimbusError(nimbusError)
            }
        }
    }
    
    func presentAdIfReady() {
        do {
            guard started, adState == .ready else { return }
            
            guard let adType else {
                throw NimbusRenderError.invalidAdType
            }
            
            adState = .resumed
            
            switch adType {
            case .rewarded:
                try adPresenter.present(
                    rewardedAd: adLoader.rewardedAd,
                    adPresentingViewController: adPresentingViewController
                )
            case .interstitial:
                try adPresenter.present(
                    interstitialAd: adLoader.interstitialAd,
                    adPresentingViewController: adPresentingViewController
                )
            case .banner:
                try adPresenter.present(
                    bannerAd: adLoader.bannerAd,
                    ad: ad,
                    container: nimbusAdView
                )
            case .native:
                try adPresenter.present(
                    nativeAd: adLoader.nativeAd, 
                    ad: ad,
                    container: nimbusAdView,
                    viewController: adPresentingViewController,
                    adRendererDelegate: adRendererDelegate
                )
            @unknown default:
                throw NimbusRenderError.invalidAdType
            }
        } catch {
            if let nimbusError = error as? NimbusError {
                sendNimbusError(nimbusError)
            }
        }
    }
    
    // MARK - AdController overrides
    
    override func onStart() {
        presentAdIfReady()
    }
    
    override func destroy() {
        guard adState != .destroyed else { return }
        
        adState = .destroyed
        
        sendNimbusEvent(.destroyed)
        
        adLoader.nativeAd?.unregisterView()
        adLoader.destroy()
    }
    
    // MARK: - VungleBannerViewDelegate
    
    func bannerAdDidLoad(_ bannerView: VungleBannerView) {
        adState = .ready
        
        sendNimbusEvent(.loaded)
        
        presentAdIfReady()
    }
    
    func bannerAdDidFail(_ bannerView: VungleBannerView, withError: NSError) {
        sendNimbusError(
            NimbusVungleError.failedToLoadAd(
                type: "banner",
                message: withError.localizedDescription
            )
        )
    }

    func bannerAdDidClose(_ bannerView: VungleBannerView) {
        destroy()
    }

    func bannerAdDidTrackImpression(_ bannerView: VungleBannerView) {
        hasRegisteredAdImpression = true
        sendNimbusEvent(.impression)
    }

    func bannerAdDidClick(_ bannerView: VungleBannerView) {
        sendNimbusEvent(.clicked)
    }
    
    // MARK: - VungleNativeDelegate
    
    func nativeAdDidLoad(_ native: VungleNative) {
        adState = .ready
        sendNimbusEvent(.loaded)
        presentAdIfReady()
    }
    
    func nativeAdDidFailToLoad(_ native: VungleNative, withError: NSError) {
        sendNimbusError(
            NimbusVungleError.failedToLoadAd(
                type: "native",
                message: withError.localizedDescription
            )
        )
    }
    
    func nativeAdDidFailToPresent(_ native: VungleNative, withError: NSError) {
        sendNimbusError(
            NimbusVungleError.failedToPresentAd(
                type: "native",
                message: withError.localizedDescription
            )
        )
    }

    func nativeAdDidTrackImpression(_ native: VungleNative) {
        hasRegisteredAdImpression = true
        sendNimbusEvent(.impression)
    }
    
    func nativeAdDidClick(_ native: VungleNative) {
        sendNimbusEvent(.clicked)
    }
    
    // MARK: - VungleInterstitialDelegate
    
    func interstitialAdDidLoad(_ interstitial: VungleInterstitial) {
        adState = .ready
        
        sendNimbusEvent(.loaded)
        
        presentAdIfReady()
    }
    
    func interstitialAdDidFailToLoad(_ interstitial: VungleInterstitial, withError: NSError) {
        sendNimbusError(
            NimbusVungleError.failedToLoadAd(
                type: "interstitial",
                message: withError.localizedDescription
            )
        )
    }
    
    func interstitialAdDidFailToPresent(_ interstitial: VungleInterstitial, withError: NSError) {
        sendNimbusError(
            NimbusVungleError.failedToPresentAd(
                type: "interstitial",
                message: withError.localizedDescription
            )
        )
    }
    
    func interstitialAdDidClose(_ interstitial: VungleInterstitial) {
        destroy()
    }
    
    func interstitialAdDidTrackImpression(_ interstitial: VungleInterstitial) {
        sendNimbusEvent(.impression)
    }
    
    func interstitialAdDidClick(_ interstitial: VungleInterstitial) {
        sendNimbusEvent(.clicked)
    }
    
    // MARK: - VungleRewardedDelegate
    
    func rewardedAdDidLoad(_ rewarded: VungleRewarded) {
        adState = .ready
        
        sendNimbusEvent(.loaded)
        
        presentAdIfReady()
    }
    
    func rewardedAdDidFailToLoad(_ rewarded: VungleRewarded, withError: NSError) {
        sendNimbusError(
            NimbusVungleError.failedToLoadAd(
                type: "rewarded",
                message: withError.localizedDescription
            )
        )
    }
    
    func rewardedAdDidFailToPresent(_ rewarded: VungleRewarded, withError: NSError) {
        sendNimbusError(
            NimbusVungleError.failedToPresentAd(
                type: "rewarded",
                message: withError.localizedDescription
            )
        )
    }
    
    func rewardedAdDidClose(_ rewarded: VungleRewarded) {
        destroy()
    }
    
    func rewardedAdDidTrackImpression(_ rewarded: VungleRewarded) {
        sendNimbusEvent(.impression)
    }
    
    func rewardedAdDidClick(_ rewarded: VungleRewarded) {
        sendNimbusEvent(.clicked)
    }
    
    func rewardedAdDidRewardUser(_ rewarded: VungleRewarded) {
        sendNimbusEvent(.completed)
    }
}

// Internal: Do NOT implement delegate conformance as separate extensions as the methods won't not be found in runtime when built as a static library
