//
//  NimbusVungleAdController.swift
//  NimbusVungleKit
//
//  Created on 13/09/22.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRenderKit
import UIKit
import VungleAdsSDK

enum NimbusVungleAdType: String {
    case fullScreenBlocking, rewarded, banner, native
}

final class NimbusVungleAdController: NSObject {
    
    enum AdState: String {
        case notLoaded, loaded, presented = "played", destroyed
    }
    
    var volume = 0
    var isClickProtectionEnabled = true
    
    let ad: NimbusAd
    var adLoader: NimbusVungleAdLoaderType
    let adPresenter: NimbusVungleAdPresenterType
    let logger: Logger
    let creativeScalingEnabled: Bool
    let isBlocking: Bool
    
    weak var container: NimbusAdView?
    weak var internalDelegate: AdControllerDelegate?
    weak var delegate: AdControllerDelegate?
    weak var adPresentingViewController: UIViewController?
    weak var adRendererDelegate: NimbusVungleAdRendererDelegate?
    
    var adState = AdState.notLoaded
    
    /// Determines whether ad has registered an impression
    private var hasRegisteredAdImpression = false
    
    private var isAdVisible = false
    
    init(
        ad: NimbusAd,
        adLoader: NimbusVungleAdLoaderType? = nil,
        adPresenter: NimbusVungleAdPresenterType = NimbusVungleAdPresenter(),
        container: UIView,
        logger: Logger,
        creativeScalingEnabled: Bool,
        delegate: AdControllerDelegate,
        adPresentingViewController: UIViewController?,
        isBlocking: Bool,
        adRendererDelegate: NimbusVungleAdRendererDelegate? = nil
    ) {
        self.ad = ad
        self.adLoader = adLoader ?? NimbusVungleAdLoader(isBlocking: isBlocking)
        self.adPresenter = adPresenter
        self.container = container as? NimbusAdView
        self.logger = logger
        self.creativeScalingEnabled = creativeScalingEnabled
        self.delegate = delegate
        self.adPresentingViewController = adPresentingViewController
        self.adRendererDelegate = adRendererDelegate
        self.isBlocking = isBlocking
        
        super.init()
        
        self.adLoader.delegate = self
    }
    
    func load() {
        do {
            guard let placementId = ad.placementId else {
                throw NimbusVungleError.failedToLoadAd(message: "Placement Id not found.")
            }
            
            try adLoader.load(ad: ad, placementId: placementId)
        } catch {
            if let nimbusError = error as? NimbusError {
                forwardNimbusError(nimbusError)
            }
        }
    }
    
    func presentAd() {
        do {
            guard adState == .loaded else {
                throw NimbusVungleError.failedToPresentAd(message: "Vungle Ad has not been loaded.")
            }
            
            switch ad.vungleAdType(isBlocking: isBlocking) {
            case .rewarded:
                try adPresenter.present(
                    rewardedAd: adLoader.rewardedAd,
                    adPresentingViewController: adPresentingViewController
                )
            case .fullScreenBlocking:
                try adPresenter.present(
                    interstitialAd: adLoader.interstitialAd,
                    adPresentingViewController: adPresentingViewController
                )
            case .banner:
                try adPresenter.present(
                    bannerAd: adLoader.bannerAd,
                    ad: ad,
                    container: container,
                    creativeScalingEnabled: creativeScalingEnabled
                )
            case .native:
                try adPresenter.present(
                    nativeAd: adLoader.nativeAd, 
                    ad: ad,
                    container: container,
                    viewController: adPresentingViewController,
                    adRendererDelegate: adRendererDelegate
                )
            case .none:
                throw NimbusVungleError.failedToPresentAd(message: "No matching Vungle Ad auction type found. Size(\(ad.vungleAdSize?.size ?? .zero)) - Type(\(ad.auctionType))")
            }
        } catch {
            if let nimbusError = error as? NimbusError {
                forwardNimbusError(nimbusError)
            }
        }
    }
    
    private func forwardNimbusEvent(_ event: NimbusEvent) {
        internalDelegate?.didReceiveNimbusEvent(controller: self, event: event)
        delegate?.didReceiveNimbusEvent(controller: self, event: event)
    }
    
    private func forwardNimbusError(_ error: NimbusError) {
        internalDelegate?.didReceiveNimbusError(controller: self, error: error)
        delegate?.didReceiveNimbusError(controller: self, error: error)
    }
}

// MARK: AdController

extension NimbusVungleAdController: AdController {
    
    var adView: UIView? { nil }
    
    var adDuration: CGFloat { 0 }
    
    func start() {
        switch adState {
        case .presented, .destroyed:
            let type: String
            if ad.isInterstitial {
                type = ad.auctionType == .static ? "interstitial" : "rewarded"
            } else {
                type = ad.vungleAdSize == VungleAdSize.VungleAdSizeMREC ? "mrec" : "banner"
            }
            
            forwardNimbusError(
                NimbusVungleError.failedToStartAd(
                    type: type,
                    message: "Vungle Ad has already been \(adState.rawValue)."
                )
            )
        case .loaded:
            presentAd()
        default:
            break
        }
    }
    
    func stop() {}
    
    func destroy() {
        guard adState != .destroyed else {
            return
        }
        
        adState = .destroyed
        
        forwardNimbusEvent(.destroyed)
        
        adLoader.nativeAd?.unregisterView()
        adLoader.destroy()
    }
    
    var friendlyObstructions: [UIView]? { nil }
    
    func didExposureChange(exposure: NimbusViewExposure) {
        if isAdVisible != exposure.isVisible {
            isAdVisible = exposure.isVisible
        }
    }
}

// MARK: VungleBannerViewDelegate

extension NimbusVungleAdController: VungleBannerViewDelegate {
    func bannerAdDidLoad(_ bannerView: VungleBannerView) {
        adState = .loaded
        
        forwardNimbusEvent(.loaded)
        
        presentAd()
    }
    
    func bannerAdDidFail(_ bannerView: VungleBannerView, withError: NSError) {
        forwardNimbusError(
            NimbusVungleError.failedToLoadAd(
                type: "banner",
                message: withError.localizedDescription
            )
        )
    }

    func bannerAdDidPresent(_ bannerView: VungleBannerView) {
        adState = .presented
    }

    func bannerAdDidClose(_ bannerView: VungleBannerView) {
        destroy()
    }

    func bannerAdDidTrackImpression(_ bannerView: VungleBannerView) {
        hasRegisteredAdImpression = true
        forwardNimbusEvent(.impression)
    }

    func bannerAdDidClick(_ bannerView: VungleBannerView) {
        forwardNimbusEvent(.clicked)
    }
}

// MARK: VungleNativeDelegate

extension NimbusVungleAdController: VungleNativeDelegate {
    func nativeAdDidLoad(_ native: VungleNative) {
        adState = .loaded
        
        forwardNimbusEvent(.loaded)
        
        presentAd()
    }
    
    func nativeAdDidFailToLoad(_ native: VungleNative, withError: NSError) {
        forwardNimbusError(
            NimbusVungleError.failedToLoadAd(
                type: "native",
                message: withError.localizedDescription
            )
        )
    }
    
    func nativeAdDidFailToPresent(_ native: VungleNative, withError: NSError) {
        forwardNimbusError(
            NimbusVungleError.failedToPresentAd(
                type: "native",
                message: withError.localizedDescription
            )
        )
    }

    func nativeAdDidTrackImpression(_ native: VungleNative) {
        hasRegisteredAdImpression = true
        forwardNimbusEvent(.impression)
    }
    
    func nativeAdDidClick(_ native: VungleNative) {
        forwardNimbusEvent(.clicked)
    }
}

// MARK: VungleInterstitialDelegate

extension NimbusVungleAdController: VungleInterstitialDelegate {
    
    func interstitialAdDidLoad(_ interstitial: VungleInterstitial) {
        adState = .loaded
        
        forwardNimbusEvent(.loaded)
        
        presentAd()
    }
    
    func interstitialAdDidFailToLoad(_ interstitial: VungleInterstitial, withError: NSError) {
        forwardNimbusError(
            NimbusVungleError.failedToLoadAd(
                type: "interstitial",
                message: withError.localizedDescription
            )
        )
    }
    
    func interstitialAdDidPresent(_ interstitial: VungleInterstitial) {
        adState = .presented
    }
    
    func interstitialAdDidFailToPresent(_ interstitial: VungleInterstitial, withError: NSError) {
        forwardNimbusError(
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
        forwardNimbusEvent(.impression)
    }
    
    func interstitialAdDidClick(_ interstitial: VungleInterstitial) {
        forwardNimbusEvent(.clicked)
    }
}

// MARK: VungleRewardedDelegate

extension NimbusVungleAdController: VungleRewardedDelegate {
    
    func rewardedAdDidLoad(_ rewarded: VungleRewarded) {
        adState = .loaded
        
        forwardNimbusEvent(.loaded)
        
        presentAd()
    }
    
    func rewardedAdDidFailToLoad(_ rewarded: VungleRewarded, withError: NSError) {
        forwardNimbusError(
            NimbusVungleError.failedToLoadAd(
                type: "rewarded",
                message: withError.localizedDescription
            )
        )
    }
    
    func rewardedAdDidPresent(_ rewarded: VungleRewarded) {
        adState = .presented
    }
    
    func rewardedAdDidFailToPresent(_ rewarded: VungleRewarded, withError: NSError) {
        forwardNimbusError(
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
        forwardNimbusEvent(.impression)
    }
    
    func rewardedAdDidClick(_ rewarded: VungleRewarded) {
        forwardNimbusEvent(.clicked)
    }
    
    func rewardedAdDidRewardUser(_ rewarded: VungleRewarded) {
        forwardNimbusEvent(.completed)
    }
}
