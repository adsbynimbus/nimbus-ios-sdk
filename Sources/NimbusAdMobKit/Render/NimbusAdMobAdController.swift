//
//  NimbusAdMobAdController.swift
//  NimbusAdMobKit
//  Created on 9/3/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import NimbusKit
import GoogleMobileAds

struct NimbusAdMobError: NimbusError {
    let message: String
    
    public var errorDescription: String? {
        "AdMob controller error: \(message)"
    }
}

final class NimbusAdMobAdController: NimbusAdController,
                                     BannerViewDelegate,
                                     NativeAdLoaderDelegate,
                                     FullScreenContentDelegate,
                                     NativeAdDelegate {
    
    // MARK: - Properties
    
    // MARK: AdController properties
    
    override var adView: UIView? { bannerAd }
    
    // MARK: Internal properties
    private weak var adRendererDelegate: NimbusAdMobAdRendererDelegate?
    
    // MARK: AdMob properties
    private var bannerAd: BannerView?
    private var interstitialAd: InterstitialAd?
    private var rewardedAd: RewardedAd?
    private var nativeAdLoader: AdLoader?
    private var nativeAd: NativeAd?
    
    init(ad: NimbusAd,
         container: UIView,
         logger: Logger,
         delegate: (any AdControllerDelegate)?,
         isBlocking: Bool,
         isRewarded: Bool,
         adPresentingViewController: UIViewController?,
         adRendererDelegate: NimbusAdMobAdRendererDelegate? = nil) {
        
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
    
    func load() {
        guard let adType else {
            sendNimbusError(NimbusRenderError.invalidAdType)
            return
        }
        
        switch adType {
        case .banner:
            let bannerAd = BannerView()
            bannerAd.translatesAutoresizingMaskIntoConstraints = false
            bannerAd.rootViewController = adPresentingViewController
            bannerAd.delegate = self
            self.bannerAd = bannerAd
            self.adState = .ready
            bannerAd.load(with: ad.markup)
            presentIfNeeded()
        case .interstitial:
            InterstitialAd.load(with: ad.markup) { [weak self] gadInterstitial, error in
                if let gadInterstitial {
                    self?.interstitialAd = gadInterstitial
                    self?.interstitialAd?.fullScreenContentDelegate = self
                    self?.adState = .ready
                    self?.sendNimbusEvent(.loaded)
                    self?.presentIfNeeded()
                } else {
                    let message: String
                    if let error { message = error.localizedDescription }
                    else { message = "Received neither an AdMob interstitial ad nor an error." }
                    
                    self?.sendNimbusError(NimbusAdMobError(message: message))
                }
            }
        case .rewarded:
            RewardedAd.load(with: ad.markup) { [weak self] gadRewarded, error in
                if let gadRewarded {
                    self?.rewardedAd = gadRewarded
                    self?.rewardedAd?.fullScreenContentDelegate = self
                    self?.adState = .ready
                    self?.sendNimbusEvent(.loaded)
                    self?.presentIfNeeded()
                } else {
                    let message: String
                    if let error { message = error.localizedDescription }
                    else { message = "Received neither an AdMob rewarded ad nor an error." }
                    
                    self?.sendNimbusError(NimbusAdMobError(message: message))
                }
            }
        case .native:
            guard let _ = adRendererDelegate else {
                sendNimbusError(NimbusAdMobError(message: "NimbusAdMobAdRendererDelegate must be set to render native ads"))
                return
            }

            nativeAdLoader = AdLoader(rootViewController: adPresentingViewController)
            nativeAdLoader?.delegate = self
            nativeAdLoader?.load(with: ad.markup)
        @unknown default:
            sendNimbusError(NimbusRenderError.invalidAdType)
        }
    }
    
    func presentIfNeeded() {
        guard started, adState == .ready else { return }
        
        adState = .resumed
        
        if let bannerAd, let container {
            container.addSubview(bannerAd)
            
            NSLayoutConstraint.activate([
                bannerAd.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                bannerAd.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                bannerAd.topAnchor.constraint(equalTo: container.topAnchor),
                bannerAd.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        } else if let nativeAd, let container, let adRendererDelegate {
            let nativeAdView = adRendererDelegate.nativeAdViewForRendering(container: container, nativeAd: nativeAd)
            container.addSubview(nativeAdView)
            
            NSLayoutConstraint.activate([
                nativeAdView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                nativeAdView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                nativeAdView.topAnchor.constraint(equalTo: container.topAnchor),
                nativeAdView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        } else if let interstitialAd {
            interstitialAd.present(from: adPresentingViewController)
        } else if let rewardedAd {
            rewardedAd.present(from: adPresentingViewController) { [weak self] in
                self?.logger.log("AdMob Event: user earned reward", level: .debug)
                self?.sendNimbusEvent(.completed)
            }
        }
    }
    
    override func onStart() {
        presentIfNeeded()
    }
    
    override func destroy() {
        guard adState != .destroyed else { return }
        
        adState = .destroyed
        
        bannerAd = nil
        nativeAd = nil
        nativeAdLoader = nil
        interstitialAd = nil
        rewardedAd = nil
    }
    
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        sendNimbusEvent(.loaded)
    }
    
    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        sendNimbusEvent(.impression)
    }
    
    func bannerViewDidRecordClick(_ bannerView: BannerView) {
        sendNimbusEvent(.clicked)
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: any Error) {
        sendNimbusError(NimbusAdMobError(message: error.localizedDescription))
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    func adDidRecordImpression(_ ad: any FullScreenPresentingAd) {
        sendNimbusEvent(.impression)
    }
    
    func adDidRecordClick(_ ad: any FullScreenPresentingAd) {
        sendNimbusEvent(.clicked)
    }
    
    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        sendNimbusError(NimbusAdMobError(message: error.localizedDescription))
    }
    
    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        destroy()
        sendNimbusEvent(.destroyed)
    }
    
    // MARK: - GADNativeAdLoaderDelegate
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        nativeAd.rootViewController = adPresentingViewController
        nativeAd.delegate = self
        self.nativeAd = nativeAd
        self.adState = .ready
        presentIfNeeded()
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: any Error) {
        sendNimbusError(NimbusAdMobError(message: "Failed to receive native ad, error: \(error.localizedDescription)"))
    }
    
    // MARK: - GADNativeAdDelegate
    
    func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
        sendNimbusEvent(.impression)
    }
    
    func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        sendNimbusEvent(.clicked)
    }
    
    func nativeAdIsMuted(_ nativeAd: NativeAd) {
        nimbusAdView?.viewabilityTracker?.volume = 0
    }
    
    func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        sendNimbusEvent(.loaded)
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToLoadWithError error: Error) {
        sendNimbusError(NimbusAdMobError(message: "Failed to load native ad, error: \(error.localizedDescription)"))
    }
}

// Internal: Do NOT implement delegate conformance as separate extensions as the methods won't not be found in runtime when built as a static library
