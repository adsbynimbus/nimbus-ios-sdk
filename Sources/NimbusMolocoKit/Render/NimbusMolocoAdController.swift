//
//  NimbusMolocoAdController.swift
//  Nimbus
//  Created on 5/28/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import NimbusRequestKit
import NimbusRenderKit
import MolocoSDK

struct NimbusMolocoError: NimbusError {
    let message: String
    
    public var errorDescription: String? {
        "NimbusMolocoAdController error: \(message)"
    }
}

final class NimbusMolocoAdController: NimbusAdController,
                                      MolocoBannerDelegate,
                                      MolocoInterstitialDelegate,
                                      MolocoNativeAdDelegate,
                                      MolocoRewardedDelegate {
    
    // MARK: - Properties
    
    // MARK: AdController properties
    
    override var adView: UIView? {
        return bannerAd
    }
    
    // MARK: Internal properties
    private weak var adRendererDelegate: NimbusMolocoAdRendererDelegate?
    
    // MARK: - Moloco ad types
    var bannerAd: MolocoBannerAdView?
    var nativeAd: MolocoNativeAd?
    var interstitialAd: MolocoInterstitial?
    var rewardedAd: MolocoRewardedInterstitial?
    
    init(ad: NimbusAd,
         container: UIView,
         logger: Logger,
         delegate: (any AdControllerDelegate)?,
         isBlocking: Bool,
         isRewarded: Bool,
         adPresentingViewController: UIViewController?,
         adRendererDelegate: NimbusMolocoAdRendererDelegate? = nil) {
        
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
        guard let renderInfo = ad.renderInfo?.value as? NimbusMolocoRenderInfo else {
            sendNimbusError(NimbusMolocoError(message: "Moloco render info is missing or invalid"))
            return
        }
        
        guard let adType else {
            sendNimbusError(NimbusRenderError.adUnsupportedAuctionType(auctionType: ad.auctionType, network: ad.network))
            return
        }
        
        switch adType {
        case .banner:
            guard let adPresentingViewController else {
                sendNimbusError(NimbusMolocoError(message: "adPresentingViewController was released before the ad was loaded"))
                return
            }
            
            bannerAd = Moloco.shared.createBanner(
                for: renderInfo.adUnitId,
                viewController: adPresentingViewController,
                delegate: self
            )
            guard let bannerAd else {
                sendNimbusError(NimbusMolocoError(message: "Moloco.shared.createBanner returned nil"))
                return
            }
            
            bannerAd.translatesAutoresizingMaskIntoConstraints = false
            bannerAd.load(bidResponse: ad.markup)
        case .interstitial:
            interstitialAd = Moloco.shared.createInterstitial(for: renderInfo.adUnitId, delegate: self)
            guard let interstitialAd else {
                
                return
            }
            interstitialAd.load(bidResponse: ad.markup)
        case .native:
            nativeAd = Moloco.shared.createNativeAd(for: renderInfo.adUnitId, delegate: self)
            guard let nativeAd else {
                return
            }
            
            nativeAd.load(bidResponse: ad.markup)
            
        case .rewarded:
            rewardedAd = Moloco.shared.createRewarded(for: renderInfo.adUnitId, delegate: self)
            rewardedAd?.load(bidResponse: ad.markup)
        @unknown default:
            sendNimbusError(NimbusMolocoError(message: "unexpected ad type: \(adType)"))
        }
    }
    
    @MainActor
    func presentIfNeeded() {
        guard started, adState == .ready else { return }
        
        if let bannerAd, let container, let dimensions = ad.adDimensions {
            container.addSubview(bannerAd)
            
            NSLayoutConstraint.activate([
                bannerAd.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                bannerAd.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                bannerAd.widthAnchor.constraint(equalToConstant: CGFloat(dimensions.width)),
                bannerAd.heightAnchor.constraint(equalToConstant: CGFloat(dimensions.height)),
            ])
        } else if let nativeAd = nativeAd, let adRendererDelegate, let container {
            guard let assets = nativeAd.assets else {
                sendNimbusError(NimbusMolocoError(message: "NativeAd assets are missing"))
                return
            }
            
            let nativeView = adRendererDelegate.nativeAdViewForRendering(container: container, assets: assets)
            nativeView.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubview(nativeView)
            
            NSLayoutConstraint.activate([
                nativeView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                nativeView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                nativeView.topAnchor.constraint(equalTo: container.topAnchor),
                nativeView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
            nativeAd.handleImpression()
            sendNimbusEvent(.impression)
            
            nativeView.clickableViews.forEach {
                $0.isUserInteractionEnabled = true
                
                if let button = $0 as? UIButton {
                    button.addTarget(self, action:  #selector(onNativeAdClick), for: .touchUpInside)
                } else {
                    let tap = UITapGestureRecognizer(target: self, action: #selector(onNativeAdClick))
                    
                    /*
                     Delegate is implemented to allow simulatenously recognize the clicks
                     as Moloco's VideoView has other gesture recognizers to pause/unpause video.
                     (see UIGestureRecognizerDelegate extension)
                     */
                    tap.delegate = self
                    tap.cancelsTouchesInView = false
                    
                    $0.addGestureRecognizer(tap)
                }
            }
            
        } else if let interstitialAd, interstitialAd.isReady, let adPresentingViewController {
            interstitialAd.show(from: adPresentingViewController, muted: volume == 0)
        } else if let rewardedAd = rewardedAd, rewardedAd.isReady, let adPresentingViewController {
            rewardedAd.show(from: adPresentingViewController)
        } else {
            sendNimbusError(NimbusMolocoError(message: "Couldn't present ad due to invalid state"))
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
        
        bannerAd?.destroy()
        bannerAd = nil
        
        interstitialAd?.destroy()
        interstitialAd = nil
        
        nativeAd?.destroy()
        nativeAd = nil
        
        rewardedAd?.destroy()
        rewardedAd = nil
    }
    
    @objc private func onNativeAdClick() {
        nativeAd?.handleClick()
        sendNimbusEvent(.clicked)
    }
    
    // MARK: - BaseAdDelegate
    
    func didLoad(ad: any MolocoAd) {
        Task { @MainActor in
            adState = .ready
            sendNimbusEvent(.loaded)
            presentIfNeeded()
        }
    }
    
    func failToLoad(ad: any MolocoAd, with error: (any Error)?) {
        sendNimbusError(
            NimbusMolocoError(message: "ad failed to load: \(String(describing: error?.localizedDescription))")
        )
    }
    
    func didShow(ad: any MolocoAd) {
        sendNimbusEvent(.impression)
    }
    
    func failToShow(ad: any MolocoAd, with error: (any Error)?) {
        sendNimbusError(
            NimbusMolocoError(message: "ad failed to show: \(String(describing: error?.localizedDescription))")
        )
    }
    
    func didHide(ad: any MolocoAd) {
        destroy()
        sendNimbusEvent(.destroyed)
    }
    
    func didClick(on ad: any MolocoAd) {
        sendNimbusEvent(.clicked)
    }
    
    // MARK: - Native delegate
    
    func didHandleClick(ad: any MolocoAd) {
        logger.log("Handled Moloco Click", level: .debug)
    }
    
    func didHandleImpression(ad: any MolocoAd) {
        logger.log("Handled Moloco Impression", level: .debug)
    }
    
    // MARK: - Rewarded delegate
    
    func userRewarded(ad: any MolocoAd) {
        sendNimbusEvent(.completed)
    }
    
    func rewardedVideoStarted(ad: any MolocoAd) {
        logger.log("Moloco Video Started", level: .debug)
    }
    
    func rewardedVideoCompleted(ad: any MolocoAd) {
        logger.log("Moloco Video Completed", level: .debug)
    }
}

extension NimbusMolocoAdController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

// Internal: Do NOT implement delegate conformance as separate extensions as the methods won't not be found in runtime when built as a static library
