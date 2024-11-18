//
//  NimbusMintegralAdController.swift
//  Nimbus
//  Created on 10/30/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import NimbusRequestKit
import NimbusRenderKit
import MTGSDK
import MTGSDKBidding
import MTGSDKBanner
import MTGSDKNewInterstitial
import MTGSDKReward

struct NimbusMintegralError: NimbusError {
    let message: String
    
    public var errorDescription: String? {
        "NimbusMintegralAdController error: \(message)"
    }
}

@available(iOS 13.0, *)
final class NimbusMintegralAdController: NSObject {
    
    enum AdState: String {
        case notLoaded, loaded, presented
    }
    
    // MARK: - Properties
    
    // MARK: AdController properties
    weak var internalDelegate: AdControllerDelegate?
    weak var delegate: AdControllerDelegate?
    
    var friendlyObstructions: [UIView]?
    var isClickProtectionEnabled = true
    
    // Mintegral mute state must be set before the ad is loaded.
    // That is why this property has no didSet hooks and only
    // considers the state of the property in load() method.
    var volume = 0
    
    // MARK: Internal properties
    private let ad: NimbusAd
    private let logger: Logger
    private let isBlocking: Bool
    private weak var container: UIView?
    private weak var adPresentingViewController: UIViewController?
    private weak var adRendererDelegate: NimbusMintegralAdRendererDelegate?
    private var started = false
    private var adState = AdState.notLoaded
    private lazy var adType: NimbusMintegralAdType? = {
        NimbusMintegralAdType(ad: ad, isBlocking: isBlocking)
    }()
    
    // MARK: - Mintegral ad types
    private var bannerAd: MTGBannerAdView?
    private var interstitialAdManager: MTGNewInterstitialBidAdManager?
    private var nativeAdManager: MTGBidNativeAdManager?
    
    init(ad: NimbusAd,
         container: UIView,
         logger: Logger,
         delegate: AdControllerDelegate,
         isBlocking: Bool,
         adPresentingViewController: UIViewController?,
         adRendererDelegate: NimbusMintegralAdRendererDelegate? = nil) {
        self.ad = ad
        self.container = container as? NimbusAdView
        self.logger = logger
        self.delegate = delegate
        self.isBlocking = isBlocking
        self.adPresentingViewController = adPresentingViewController
        self.adRendererDelegate = adRendererDelegate
    }
    
    @MainActor
    func load() {
        guard let renderInfo = ad.renderInfo as? NimbusMintegralRenderInfo else {
            forwardNimbusError(NimbusMintegralError(message: "Mintegral render info is missing or invalid"))
            return
        }
        guard let adType else {
            forwardNimbusError(NimbusRenderError.adUnsupportedAuctionType(auctionType: ad.auctionType, network: ad.network))
            return
        }
        
        switch adType {
        case .banner(let width, let height):
            bannerAd = MTGBannerAdView(
                bannerAdViewWithAdSize: CGSize(width: width, height: height),
                placementId: renderInfo.placementId,
                unitId: renderInfo.adUnitId,
                rootViewController: adPresentingViewController
            )
            bannerAd?.translatesAutoresizingMaskIntoConstraints = false
            bannerAd?.delegate = self
            bannerAd?.viewController = adPresentingViewController
            bannerAd?.loadBannerAd(withBidToken: ad.markup)
        case .native:
            nativeAdManager = MTGBidNativeAdManager(
                placementId: renderInfo.placementId,
                unitID: renderInfo.adUnitId,
                presenting: adPresentingViewController
            )
            nativeAdManager?.delegate = self
            nativeAdManager?.load(withBidToken: ad.markup)
            
        case .interstitial:
            interstitialAdManager = MTGNewInterstitialBidAdManager(
                placementId: renderInfo.placementId ?? "",
                unitId: renderInfo.adUnitId,
                delegate: self
            )
            interstitialAdManager?.playVideoMute = volume <= 0
            interstitialAdManager?.loadAd(withBidToken: ad.markup)
        case .rewarded:
            MTGBidRewardAdManager.sharedInstance().playVideoMute = volume <= 0
            MTGBidRewardAdManager.sharedInstance().loadVideo(
                withBidToken: ad.markup,
                placementId: renderInfo.placementId,
                unitId: renderInfo.adUnitId,
                delegate: self
            )
        }
    }
    
    @MainActor
    func presentIfNeeded(campaign: MTGCampaign? = nil) {
        guard started, adState == .loaded else { return }
        guard let renderInfo = ad.renderInfo as? NimbusMintegralRenderInfo else {
            forwardNimbusError(NimbusMintegralError(message: "Mintegral render info is missing or invalid"))
            return
        }
        
        adState = .presented
        
        if let bannerAd, let container, case .banner(let width, let height) = adType {
            container.addSubview(bannerAd)
            
            NSLayoutConstraint.activate([
                bannerAd.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                bannerAd.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                bannerAd.widthAnchor.constraint(equalToConstant: CGFloat(width)),
                bannerAd.heightAnchor.constraint(equalToConstant: CGFloat(height)),
            ])
        } else if let nativeAdManager, let campaign, let adRendererDelegate, let container {
            let nativeView = adRendererDelegate.nativeAdViewForRendering(container: container, campaign: campaign)
            nativeView.translatesAutoresizingMaskIntoConstraints = false
            nativeView.mediaView.delegate = self
            nativeView.mediaView.setMediaSourceWith(campaign, unitId: renderInfo.adUnitId)
            
            container.addSubview(nativeView)
            
            NSLayoutConstraint.activate([
                nativeView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                nativeView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                nativeView.topAnchor.constraint(equalTo: container.topAnchor),
                nativeView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
            nativeAdManager.registerView(
                forInteraction: nativeView,
                withClickableViews: nativeView.clickableViews,
                with: campaign
            )
        } else if let interstitialAdManager, let adPresentingViewController {
            interstitialAdManager.show(from: adPresentingViewController)
        } else if case .rewarded = adType, let adPresentingViewController {
            MTGBidRewardAdManager.sharedInstance().showVideo(
                withPlacementId: renderInfo.placementId,
                unitId: renderInfo.adUnitId,
                userId: nil,
                delegate: self,
                viewController: adPresentingViewController
            )
        }
    }
    
    @MainActor
    private func forwardNimbusEvent(_ event: NimbusEvent) {
        internalDelegate?.didReceiveNimbusEvent(controller: self, event: event)
        delegate?.didReceiveNimbusEvent(controller: self, event: event)
    }

    @MainActor
    private func forwardNimbusError(_ error: NimbusError) {
        internalDelegate?.didReceiveNimbusError(controller: self, error: error)
        delegate?.didReceiveNimbusError(controller: self, error: error)
    }
}

@available(iOS 13.0, *)
extension NimbusMintegralAdController: AdController {
    var adView: UIView? {
        return bannerAd
    }

    var adDuration: CGFloat { 0 }
    
    func start() {
        Task { @MainActor in
            started = true
            presentIfNeeded()
        }
    }
    
    func stop() {}
    
    func destroy() {
        bannerAd = nil
        interstitialAdManager = nil
    }
}

// MARK: - Banner Delegate

@available(iOS 13.0, *)
extension NimbusMintegralAdController: MTGBannerAdViewDelegate {
    func adViewLoadSuccess(_ adView: MTGBannerAdView!) {
        Task { @MainActor in
            adState = .loaded
            forwardNimbusEvent(.loaded)
            presentIfNeeded()
        }
    }
    
    func adViewWillLogImpression(_ adView: MTGBannerAdView!) {
        Task { @MainActor in forwardNimbusEvent(.impression) }
    }
    
    func adViewDidClicked(_ adView: MTGBannerAdView!) {
        Task { @MainActor in forwardNimbusEvent(.clicked) }
    }
    
    func adViewClosed(_ adView: MTGBannerAdView!) {
        Task { @MainActor in
            destroy()
            forwardNimbusEvent(.destroyed)
        }
    }
    
    func adViewLoadFailedWithError(_ error: (any Error)!, adView: MTGBannerAdView!) {
        Task { @MainActor in forwardNimbusError(NimbusMintegralError(message: error.localizedDescription)) }
    }
    
    func adViewWillLeaveApplication(_ adView: MTGBannerAdView!) {}
    func adViewWillOpenFullScreen(_ adView: MTGBannerAdView!) {}
    func adViewCloseFullScreen(_ adView: MTGBannerAdView!) {}
}

// MARK: - Native Delegate

@available(iOS 13.0, *)
extension NimbusMintegralAdController: MTGBidNativeAdManagerDelegate {
    func nativeAdsLoaded(_ nativeAds: [Any]?, bidNativeManager: MTGBidNativeAdManager) {
        Task { @MainActor in
            guard let campaign = nativeAds?.first as? MTGCampaign else {
                forwardNimbusError(NimbusMintegralError(message: "No MTGCampaign found in native ad"))
                return
            }
            
            forwardNimbusEvent(.loaded)
            
            adState = .loaded
            presentIfNeeded(campaign: campaign)
        }
    }
    
    func nativeAdsFailedToLoadWithError(_ error: any Error, bidNativeManager: MTGBidNativeAdManager) {
        Task { @MainActor in
            forwardNimbusError(NimbusMintegralError(message: "Native ad failed to load, error: \(error.localizedDescription)"))
        }
    }
    
    func nativeAdImpression(with type: MTGAdSourceType, bidNativeManager: MTGBidNativeAdManager) {
        Task { @MainActor in forwardNimbusEvent(.impression) }
    }
    
    func nativeAdDidClick(_ nativeAd: MTGCampaign, bidNativeManager: MTGBidNativeAdManager) {
        Task { @MainActor in forwardNimbusEvent(.clicked) }
    }
}

@available(iOS 13.0, *)
extension NimbusMintegralAdController: MTGMediaViewDelegate {
    func nativeAdImpression(with type: MTGAdSourceType, mediaView: MTGMediaView) {
        Task { @MainActor in forwardNimbusEvent(.impression) }
    }
    
    func nativeAdDidClick(_ nativeAd: MTGCampaign) {
        Task { @MainActor in forwardNimbusEvent(.clicked) }
    }
}

// MARK: - Interstitial Delegate

@available(iOS 13.0, *)
extension NimbusMintegralAdController: MTGNewInterstitialBidAdDelegate {
    func newInterstitialBidAdLoadSuccess(_ adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in forwardNimbusEvent(.loaded) }
    }
    
    func newInterstitialBidAdResourceLoadSuccess(_ adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in
            adState = .loaded
            presentIfNeeded()
        }
    }
    
    func newInterstitialBidAdShowSuccess(withBidToken bidToken: String, adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in forwardNimbusEvent(.impression) }
    }
    
    func newInterstitialBidAdClicked(_ adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in forwardNimbusEvent(.clicked) }
    }
    
    func newInterstitialBidAdLoadFail(_ error: any Error, adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in forwardNimbusError(NimbusMintegralError(message: error.localizedDescription)) }
    }
    
    func newInterstitialBidAdShowFail(_ error: any Error, adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in forwardNimbusError(NimbusMintegralError(message: error.localizedDescription)) }
    }
    
    func newInterstitialBidAdDismissed(withConverted converted: Bool, adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in
            destroy()
            forwardNimbusEvent(.destroyed)
        }
    }
    
    func newInterstitialBidAdEndCardShowSuccess(_ adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in forwardNimbusEvent(.endCardImpression) }
    }
}

// MARK: - Rewarded Delegate

@available(iOS 13.0, *)
extension NimbusMintegralAdController: MTGRewardAdLoadDelegate, MTGRewardAdShowDelegate {
    func onVideoAdLoadSuccess(_ placementId: String?, unitId: String?) {
        Task { @MainActor in
            adState = .loaded
            forwardNimbusEvent(.loaded)
            presentIfNeeded()
        }
    }
    
    func onVideoAdShowSuccess(_ placementId: String?, unitId: String?) {
        Task { @MainActor in forwardNimbusEvent(.impression) }
    }
    
    func onVideoAdClicked(_ placementId: String?, unitId: String?) {
        Task { @MainActor in forwardNimbusEvent(.clicked) }
    }
    
    func onVideoAdLoadFailed(_ placementId: String?, unitId: String?, error: any Error) {
        Task { @MainActor in forwardNimbusError(NimbusMintegralError(message: error.localizedDescription)) }
    }
    
    func onVideoAdShowFailed(_ placementId: String?, unitId: String?, withError error: any Error) {
        Task { @MainActor in forwardNimbusError(NimbusMintegralError(message: error.localizedDescription)) }
    }
    
    func onVideoPlayCompleted(_ placementId: String?, unitId: String?) {
        Task { @MainActor in forwardNimbusEvent(.completed) }
    }
    
    func onVideoEndCardShowSuccess(_ placementId: String?, unitId: String?) {
        Task { @MainActor in forwardNimbusEvent(.endCardImpression) }
    }
    
    func onVideoAdDismissed(
        _ placementId: String?,
        unitId: String?,
        withConverted converted: Bool,
        withRewardInfo rewardInfo: MTGRewardAdInfo?
    ) {
        Task { @MainActor in
            destroy()
            forwardNimbusEvent(.destroyed)
        }
    }
}
