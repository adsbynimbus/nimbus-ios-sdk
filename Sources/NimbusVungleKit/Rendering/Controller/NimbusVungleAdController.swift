//
//  NimbusVungleAdController.swift
//  NimbusVungleKit
//
//  Created by Victor Takai on 13/09/22.
//  Copyright © 2023 Timehop. All rights reserved.
//

@_exported import NimbusRenderKit
import UIKit
import VungleAdsSDK

final class NimbusVungleAdController: NSObject {
    
    enum AdState: String {
        case notLoaded, loaded, presented = "played", destroyed
    }
    
    // Visibility tracking is only necessary for non-interstitials
    let visibilityManager: VisibilityManager?
    
    var volume = 0
    var isClickProtectionEnabled = true
    
    let ad: NimbusAd
    var adLoader: NimbusVungleAdLoaderType
    let adPresenter: NimbusVungleAdPresenterType
    let logger: Logger
    let creativeScalingEnabled: Bool
    
    weak var container: NimbusAdView?
    weak var delegate: AdControllerDelegate?
    weak var adPresentingViewController: UIViewController?
    
    var adState = AdState.notLoaded
    
    /// Determines whether ad has registered an impression
    private var hasRegisteredAdImpression = false {
        didSet { triggerImpressionDelegateIfNecessary() }
    }

    private var isAdVisible = false {
        didSet { triggerImpressionDelegateIfNecessary() }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(
        ad: NimbusAd,
        adLoader: NimbusVungleAdLoaderType = NimbusVungleAdLoader(),
        adPresenter: NimbusVungleAdPresenterType = NimbusVungleAdPresenter(),
        container: UIView,
        logger: Logger,
        creativeScalingEnabled: Bool,
        delegate: AdControllerDelegate,
        adPresentingViewController: UIViewController?
    ) {
        self.ad = ad
        self.adLoader = adLoader
        self.adPresenter = adPresenter
        self.container = container as? NimbusAdView
        self.logger = logger
        self.creativeScalingEnabled = creativeScalingEnabled
        self.delegate = delegate
        self.adPresentingViewController = adPresentingViewController
        
        if let visibilityTrackableView = container as? (UIView & VisibilityTrackable) {
            self.visibilityManager = NimbusVisibilityManager(for: visibilityTrackableView)
        } else {
            self.visibilityManager = nil
        }
        
        super.init()
        
        self.adLoader.delegate = self
        
        self.visibilityManager?.delegate = self
        self.visibilityManager?.startListeningForVisibilityChanges()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    func load() {
        do {
            guard let placementId = ad.placementId else {
                throw NimbusVungleError.failedToLoadAd(message: "Placement Id not found.")
            }
            
            try adLoader.load(ad: ad, placementId: placementId)
        } catch {
            if let nimbusError = error as? NimbusVungleError {
                delegate?.didReceiveNimbusError(
                    controller: self,
                    error: nimbusError
                )
            }
        }
    }
    
    func presentAd() {
        do {
            guard adState == .loaded else {
                throw NimbusVungleError.failedToPresentAd(message: "Vungle Ad has not been loaded.")
            }
            
            switch ad.vungleAdType {
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
            case .none:
                throw NimbusVungleError.failedToPresentAd(message: "No matching Vungle Ad auction type found. Size(\(ad.vungleAdSize?.rawValue ?? -1)) - Type(\(ad.auctionType))")
            }
        } catch {
            if let nimbusError = error as? NimbusVungleError {
                delegate?.didReceiveNimbusError(
                    controller: self,
                    error: nimbusError
                )
            }
        }
    }
    
    private func triggerImpressionDelegateIfNecessary() {
        guard let container else { return }

        container.visibilityDelegate?.didChangeVisibility(
            controller: container,
            isVisible: isAdVisible,
            hasTriggeredImpression: hasRegisteredAdImpression
        )
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
                type = ad.vungleAdSize == .mrec ? "mrec" : "banner"
            }
            delegate?.didReceiveNimbusError(
                controller: self,
                error: NimbusVungleError.failedToStartAd(
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
        
        delegate?.didReceiveNimbusEvent(controller: self, event: .destroyed)
        adLoader.destroy()
        visibilityManager?.destroy()
    }
    
    var friendlyObstructions: [UIView]? { nil }
}

// MARK: VungleBannerDelegate

extension NimbusVungleAdController: VungleBannerDelegate {
    
    func bannerAdDidLoad(_ banner: VungleBanner) {
        adState = .loaded
        
        delegate?.didReceiveNimbusEvent(controller: self, event: .loaded)
        presentAd()
    }
    
    func bannerAdDidFailToLoad(_ banner: VungleBanner, withError: NSError) {
        delegate?.didReceiveNimbusError(
            controller: self,
            error: NimbusVungleError.failedToLoadAd(
                type: "banner",
                message: withError.localizedDescription
            )
        )
    }
    
    func bannerAdDidPresent(_ banner: VungleBanner) {
        adState = .presented
    }
    
    func bannerAdDidFailToPresent(_ banner: VungleBanner, withError: NSError) {
        delegate?.didReceiveNimbusError(
            controller: self,
            error: NimbusVungleError.failedToPresentAd(
                type: "banner",
                message: withError.localizedDescription
            )
        )
    }
    
    func bannerAdDidClose(_ banner: VungleBanner) {
        destroy()
    }
    
    func bannerAdDidTrackImpression(_ banner: VungleBanner) {
        logger.log("Vungle banner logged impression", level: .debug)
        
        hasRegisteredAdImpression = true
        delegate?.didReceiveNimbusEvent(controller: self, event: .impression)
    }
    
    func bannerAdDidClick(_ banner: VungleBanner) {
        delegate?.didReceiveNimbusEvent(controller: self, event: .clicked)
    }
}

// MARK: VungleInterstitialDelegate

extension NimbusVungleAdController: VungleInterstitialDelegate {
    
    func interstitialAdDidLoad(_ interstitial: VungleInterstitial) {
        adState = .loaded

        delegate?.didReceiveNimbusEvent(controller: self, event: .loaded)
        presentAd()
    }
    
    func interstitialAdDidFailToLoad(_ interstitial: VungleInterstitial, withError: NSError) {
        delegate?.didReceiveNimbusError(
            controller: self,
            error: NimbusVungleError.failedToLoadAd(
                type: "interstitial",
                message: withError.localizedDescription
            )
        )
    }
    
    func interstitialAdDidPresent(_ interstitial: VungleInterstitial) {
        adState = .presented
    }
    
    func interstitialAdDidFailToPresent(_ interstitial: VungleInterstitial, withError: NSError) {
        delegate?.didReceiveNimbusError(
            controller: self,
            error: NimbusVungleError.failedToPresentAd(
                type: "interstitial",
                message: withError.localizedDescription
            )
        )
    }
    
    func interstitialAdDidClose(_ interstitial: VungleInterstitial) {
        destroy()
    }
    
    func interstitialAdDidTrackImpression(_ interstitial: VungleInterstitial) {
        delegate?.didReceiveNimbusEvent(controller: self, event: .impression)
    }
    
    func interstitialAdDidClick(_ interstitial: VungleInterstitial) {
        delegate?.didReceiveNimbusEvent(controller: self, event: .clicked)
    }
}

// MARK: VungleRewardedDelegate

extension NimbusVungleAdController: VungleRewardedDelegate {
    
    func rewardedAdDidLoad(_ rewarded: VungleRewarded) {
        adState = .loaded
        
        delegate?.didReceiveNimbusEvent(controller: self, event: .loaded)
        presentAd()
    }
    
    func rewardedAdDidFailToLoad(_ rewarded: VungleRewarded, withError: NSError) {
        delegate?.didReceiveNimbusError(
            controller: self,
            error: NimbusVungleError.failedToLoadAd(
                type: "rewarded",
                message: withError.localizedDescription
            )
        )
    }
    
    func rewardedAdDidPresent(_ rewarded: VungleRewarded) {
        adState = .presented
    }
    
    func rewardedAdDidFailToPresent(_ rewarded: VungleRewarded, withError: NSError) {
        delegate?.didReceiveNimbusError(
            controller: self,
            error: NimbusVungleError.failedToPresentAd(
                type: "rewarded",
                message: withError.localizedDescription
            )
        )
    }
    
    func rewardedAdDidClose(_ rewarded: VungleRewarded) {
        destroy()
    }
    
    func rewardedAdDidTrackImpression(_ rewarded: VungleRewarded) {
        delegate?.didReceiveNimbusEvent(controller: self, event: .impression)
    }
    
    func rewardedAdDidClick(_ rewarded: VungleRewarded) {
        delegate?.didReceiveNimbusEvent(controller: self, event: .clicked)
    }
    
    func rewardedAdDidRewardUser(_ rewarded: VungleRewarded) {
        delegate?.didReceiveNimbusEvent(controller: self, event: .completed)
    }
}

// MARK: Notifications

extension NimbusVungleAdController {

    /// Ad is in foreground
    @objc private func appDidBecomeActive() {
        visibilityManager?.appDidBecomeActive()
    }

    /// Ad is in background
    @objc private func appWillResignActive() {
        visibilityManager?.appWillResignActive()
    }
}

// MARK: VisibilityManagerDelegate

extension NimbusVungleAdController: VisibilityManagerDelegate {

    func didRegisterImpressionForView() {}

    func didChangeExposure(exposure: NimbusViewExposure) {
        let newVisibility = exposure.isVisible
        if isAdVisible != newVisibility {
            isAdVisible = newVisibility
        }
    }
}
