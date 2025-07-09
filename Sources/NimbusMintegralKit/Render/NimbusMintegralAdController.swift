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

/// Mintegral mute state must be set before the ad is loaded.
/// That is why the volume property has no didSet hooks and only
/// considers the state of the property in load() method.
final class NimbusMintegralAdController: NimbusAdController,
                                         MTGBannerAdViewDelegate,
                                         MTGBidNativeAdManagerDelegate,
                                         MTGMediaViewDelegate,
                                         MTGNewInterstitialBidAdDelegate,
                                         MTGRewardAdLoadDelegate,
                                         MTGRewardAdShowDelegate {
    
    // MARK: - Properties
    
    // MARK: AdController properties
    
    override var adView: UIView? {
        return bannerAd
    }
    
    // MARK: Internal properties
    private weak var adRendererDelegate: NimbusMintegralAdRendererDelegate?
    
    // MARK: - Mintegral ad types
    private var bannerAd: MTGBannerAdView?
    private var interstitialAdManager: MTGNewInterstitialBidAdManager?
    private var nativeAdManager: MTGBidNativeAdManager?
    
    init(ad: NimbusAd,
         container: UIView,
         logger: Logger,
         delegate: (any AdControllerDelegate)?,
         isBlocking: Bool,
         isRewarded: Bool,
         adPresentingViewController: UIViewController?,
         adRendererDelegate: NimbusMintegralAdRendererDelegate? = nil) {
        
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
    }
    
    @MainActor
    func load() {
        guard let renderInfo = ad.renderInfo?.value as? NimbusMintegralRenderInfo else {
            sendNimbusError(NimbusMintegralError(message: "Mintegral render info is missing or invalid"))
            return
        }
        guard let adType else {
            sendNimbusError(NimbusRenderError.adUnsupportedAuctionType(auctionType: ad.auctionType, network: ad.network))
            return
        }
        
        switch adType {
        case .banner:
            guard let dimensions = ad.adDimensions else {
                sendNimbusError(NimbusMintegralError(message: "Mintegral banner couldn't render, ad dimensions are missing"))
                return
            }
            
            bannerAd = MTGBannerAdView(
                bannerAdViewWithAdSize: CGSize(width: dimensions.width, height: dimensions.height),
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
        guard started, adState == .ready else { return }
        guard let renderInfo = ad.renderInfo?.value as? NimbusMintegralRenderInfo else {
            sendNimbusError(NimbusMintegralError(message: "Mintegral render info is missing or invalid"))
            return
        }
        
        adState = .resumed
        
        if let bannerAd, let container, let dimensions = ad.adDimensions {
            container.addSubview(bannerAd)
            
            NSLayoutConstraint.activate([
                bannerAd.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                bannerAd.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                bannerAd.widthAnchor.constraint(equalToConstant: CGFloat(dimensions.width)),
                bannerAd.heightAnchor.constraint(equalToConstant: CGFloat(dimensions.height)),
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
    
    override func onStart() {        
        Task { @MainActor in
            presentIfNeeded()
        }
    }
    
    override func destroy() {
        guard adState != .destroyed else { return }
        
        adState = .destroyed
        bannerAd = nil
        interstitialAdManager = nil
    }
    
    @MainActor
    private func sendNimbus(event: NimbusEvent) {
        sendNimbusEvent(event)
    }

    @MainActor
    private func sendNimbus(error: NimbusError) {
        sendNimbusError(error)
    }
    
    // MARK: - Banner Delegate
    
    func adViewLoadSuccess(_ adView: MTGBannerAdView!) {
        Task { @MainActor in
            adState = .ready
            sendNimbusEvent(.loaded)
            presentIfNeeded()
        }
    }
    
    func adViewWillLogImpression(_ adView: MTGBannerAdView!) {
        Task { @MainActor in sendNimbusEvent(.impression) }
    }
    
    func adViewDidClicked(_ adView: MTGBannerAdView!) {
        Task { @MainActor in sendNimbusEvent(.clicked) }
    }
    
    func adViewClosed(_ adView: MTGBannerAdView!) {
        Task { @MainActor in
            destroy()
            sendNimbusEvent(.destroyed)
        }
    }
    
    func adViewLoadFailedWithError(_ error: (any Error)!, adView: MTGBannerAdView!) {
        Task { @MainActor in sendNimbusError(NimbusMintegralError(message: error.localizedDescription)) }
    }
    
    func adViewWillLeaveApplication(_ adView: MTGBannerAdView!) {}
    func adViewWillOpenFullScreen(_ adView: MTGBannerAdView!) {}
    func adViewCloseFullScreen(_ adView: MTGBannerAdView!) {}
    
    // MARK: - Native Delegate
    
    func nativeAdsLoaded(_ nativeAds: [Any]?, bidNativeManager: MTGBidNativeAdManager) {
        Task { @MainActor in
            guard let campaign = nativeAds?.first as? MTGCampaign else {
                sendNimbusError(NimbusMintegralError(message: "No MTGCampaign found in native ad"))
                return
            }
            
            sendNimbusEvent(.loaded)
            
            adState = .ready
            presentIfNeeded(campaign: campaign)
        }
    }
    
    func nativeAdsFailedToLoadWithError(_ error: any Error, bidNativeManager: MTGBidNativeAdManager) {
        Task { @MainActor in
            sendNimbusError(NimbusMintegralError(message: "Native ad failed to load, error: \(error.localizedDescription)"))
        }
    }
    
    func nativeAdImpression(with type: MTGAdSourceType, bidNativeManager: MTGBidNativeAdManager) {
        Task { @MainActor in sendNimbusEvent(.impression) }
    }
    
    func nativeAdDidClick(_ nativeAd: MTGCampaign, bidNativeManager: MTGBidNativeAdManager) {
        Task { @MainActor in sendNimbusEvent(.clicked) }
    }
    
    func nativeAdImpression(with type: MTGAdSourceType, mediaView: MTGMediaView) {
        Task { @MainActor in sendNimbusEvent(.impression) }
    }
    
    func nativeAdDidClick(_ nativeAd: MTGCampaign) {
        Task { @MainActor in sendNimbusEvent(.clicked) }
    }
    
    // MARK: - Interstitial Delegate
    
    func newInterstitialBidAdResourceLoadSuccess(_ adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in
            adState = .ready
            sendNimbusEvent(.loaded)
            presentIfNeeded()
        }
    }
    
    func newInterstitialBidAdShowSuccess(withBidToken bidToken: String, adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in sendNimbusEvent(.impression) }
    }
    
    func newInterstitialBidAdClicked(_ adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in sendNimbusEvent(.clicked) }
    }
    
    func newInterstitialBidAdLoadFail(_ error: any Error, adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in sendNimbusError(NimbusMintegralError(message: error.localizedDescription)) }
    }
    
    func newInterstitialBidAdShowFail(_ error: any Error, adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in sendNimbusError(NimbusMintegralError(message: error.localizedDescription)) }
    }
    
    func newInterstitialBidAdDismissed(withConverted converted: Bool, adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in
            destroy()
            sendNimbusEvent(.destroyed)
        }
    }
    
    func newInterstitialBidAdEndCardShowSuccess(_ adManager: MTGNewInterstitialBidAdManager) {
        Task { @MainActor in sendNimbusEvent(.endCardImpression) }
    }
    
    // MARK: - Rewarded Delegate
    
    func onVideoAdLoadSuccess(_ placementId: String?, unitId: String?) {
        Task { @MainActor in
            adState = .ready
            sendNimbusEvent(.loaded)
            presentIfNeeded()
        }
    }
    
    func onVideoAdShowSuccess(_ placementId: String?, unitId: String?) {
        Task { @MainActor in sendNimbusEvent(.impression) }
    }
    
    func onVideoAdClicked(_ placementId: String?, unitId: String?) {
        Task { @MainActor in sendNimbusEvent(.clicked) }
    }
    
    func onVideoAdLoadFailed(_ placementId: String?, unitId: String?, error: any Error) {
        Task { @MainActor in sendNimbusError(NimbusMintegralError(message: error.localizedDescription)) }
    }
    
    func onVideoAdShowFailed(_ placementId: String?, unitId: String?, withError error: any Error) {
        Task { @MainActor in sendNimbusError(NimbusMintegralError(message: error.localizedDescription)) }
    }
    
    func onVideoPlayCompleted(_ placementId: String?, unitId: String?) {
        Task { @MainActor in sendNimbusEvent(.completed) }
    }
    
    func onVideoEndCardShowSuccess(_ placementId: String?, unitId: String?) {
        Task { @MainActor in sendNimbusEvent(.endCardImpression) }
    }
    
    func onVideoAdDismissed(
        _ placementId: String?,
        unitId: String?,
        withConverted converted: Bool,
        withRewardInfo rewardInfo: MTGRewardAdInfo?
    ) {
        Task { @MainActor in
            destroy()
            sendNimbusEvent(.destroyed)
        }
    }
}

// Internal: Do NOT implement delegate conformance as separate extensions as the methods won't not be found in runtime when built as a static library
