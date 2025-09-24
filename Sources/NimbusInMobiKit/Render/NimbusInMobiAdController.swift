//
//  NimbusInMobiAdController.swift
//  Nimbus
//  Created on 7/31/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import NimbusRequestKit
import NimbusRenderKit
import InMobiSDK

struct NimbusInMobiError: NimbusError {
    let message: String
    
    public var errorDescription: String? {
        "NimbusInMobiAdController error: \(message)"
    }
}

final class NimbusInMobiAdController: NimbusAdController, IMBannerDelegate, IMInterstitialDelegate, IMNativeDelegate {
    // MARK: - Properties
    
    // MARK: AdController properties
    
    override var adView: UIView? {
        return bannerAd
    }
    
    // MARK: Internal properties
    private weak var adRendererDelegate: NimbusInMobiAdRendererDelegate?
    
    var bannerAd: IMBanner?
    var interstitialAd: IMInterstitial?
    var nativeAd: IMNative?
    
    init(ad: NimbusAd,
         container: UIView,
         logger: Logger,
         delegate: (any AdControllerDelegate)?,
         isBlocking: Bool,
         isRewarded: Bool,
         adPresentingViewController: UIViewController?,
         adRendererDelegate: NimbusInMobiAdRendererDelegate? = nil) {
        
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
        guard let renderInfo = ad.renderInfo?.value as? NimbusInMobiRenderInfo else {
            sendNimbusError(NimbusInMobiError(message: "InMobi render info is missing or invalid"))
            return
        }
        
        guard let adType else {
            sendNimbusError(NimbusRenderError.adUnsupportedAuctionType(auctionType: ad.auctionType, network: ad.network))
            return
        }
        
        guard let markupData = ad.markup.data(using: .utf8) else {
            sendNimbusError(NimbusInMobiError(message: "Could not convert InMobi markup String to Data"))
            return
        }
        
        switch adType {
        case .banner:
            guard let dimensions = ad.adDimensions else {
                sendNimbusError(NimbusInMobiError(message: "Cannot create InMobi Banner Ad: Ad dimensions are missing"))
                return
            }
            
            let bannerAd = IMBanner(
                frame: CGRect(x: 0, y: 0, width: dimensions.width, height: dimensions.height),
                placementId: renderInfo.placementId,
                delegate: self
            )
            bannerAd.extras = InMobiRequestBridge.extras
            bannerAd.load(markupData)
            bannerAd.shouldAutoRefresh(false)
            self.bannerAd = bannerAd
        case .native:
            nativeAd = IMNative(placementId: renderInfo.placementId, delegate: self)
            nativeAd?.extras = InMobiRequestBridge.extras
            nativeAd?.load(markupData)
        case .interstitial, .rewarded:
            interstitialAd = IMInterstitial(placementId: renderInfo.placementId, delegate: self)
            interstitialAd?.extras = InMobiRequestBridge.extras
            interstitialAd?.load(markupData)
        @unknown default:
            sendNimbusError(NimbusInMobiError(message: "unexpected ad type: \(adType)"))
        }
    }
    
    @MainActor
    func presentIfNeeded() {
        guard started, adState == .ready else { return }
        
        if let bannerAd, let container {
            container.addSubview(bannerAd)
        } else if let nativeAd, let adRendererDelegate, let container {
            let nativeView = adRendererDelegate.nativeAdViewForRendering(container: container, nativeAd: nativeAd)
            nativeView.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubview(nativeView)
            
            NSLayoutConstraint.activate([
                nativeView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                nativeView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                nativeView.topAnchor.constraint(equalTo: container.topAnchor),
                nativeView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        } else if let interstitialAd, let adPresentingViewController {
            interstitialAd.show(from: adPresentingViewController)
        } else {
            sendNimbusError(NimbusInMobiError(message: "Couldn't present ad due to invalid state"))
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
        interstitialAd = nil
        nativeAd = nil
    }
    
    private func setReady() {
        Task { @MainActor in
            adState = .ready
            sendNimbusEvent(.loaded)
            presentIfNeeded()
        }
    }
    
    // MARK: - Banner Delegate
    
    func bannerDidFinishLoading(_ banner: InMobiSDK.IMBanner) {
        setReady()
    }
    
    func bannerAdImpressed(_ banner: InMobiSDK.IMBanner) {
        sendNimbusEvent(.impression)
    }
    
    func banner(_ banner: IMBanner, didInteractWithParams params: [String : Any]?) {
        sendNimbusEvent(.clicked)
    }
    
    func banner(_ banner: InMobiSDK.IMBanner, didFailToReceiveWithError error: InMobiSDK.IMRequestStatus) {
        sendNimbusError(NimbusInMobiError(message: "banner ad failed to receive: \(error)"))
    }

    func banner(_ banner: InMobiSDK.IMBanner, didFailToLoadWithError error: InMobiSDK.IMRequestStatus) {
        sendNimbusError(NimbusInMobiError(message: "banner ad failed to load: \(error)"))
    }
    
    // MARK: - Native Delegate
    
    func nativeDidFinishLoading(_ native: IMNative) {
        setReady()
    }
    
    func nativeAdImpressed(_ native: IMNative) {
        sendNimbusEvent(.impression)
    }
    
    func native(_ native: IMNative, didInteractWithParams params: [String : Any]?) {
        sendNimbusEvent(.clicked)
    }
    
    func native(_ native: IMNative, didFailToLoadWithError error: IMRequestStatus) {
        sendNimbusError(NimbusInMobiError(message: "native ad failed to load: \(error)"))
    }

    // MARK: - Interstitial/Rewarded Delegate
    
    func interstitialDidFinishLoading(_ interstitial: IMInterstitial) {
        setReady()
    }
    
    func interstitialAdImpressed(_ interstitial: IMInterstitial) {
        sendNimbusEvent(.impression)
    }
    
    func interstitial(_ interstitial: IMInterstitial, didInteractWithParams params: [String : Any]?) {
        sendNimbusEvent(.clicked)
    }
    
    func interstitial(_ interstitial: IMInterstitial, rewardActionCompletedWithRewards rewards: [String : Any]) {
        sendNimbusEvent(.completed)
    }
    
    func interstitialDidDismiss(_ interstitial: IMInterstitial) {
        destroy()
        sendNimbusEvent(.destroyed)
    }
    
    func interstitial(_ interstitial: IMInterstitial, didFailToReceiveWithError error: any Error) {
        sendNimbusError(NimbusInMobiError(message: "interstitial ad failed to load: \(error)"))
    }
    
    func interstitial(_ interstitial: IMInterstitial, didFailToPresentWithError error: IMRequestStatus) {
        sendNimbusError(NimbusInMobiError(message: "interstitial ad failed to present: \(error)"))
    }
}

// Internal: Do NOT implement delegate conformance as separate extensions as the methods won't not be found in runtime when built as a static library
