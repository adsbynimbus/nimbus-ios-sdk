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
                                     GADBannerViewDelegate,
                                     GADNativeAdLoaderDelegate,
                                     GADFullScreenContentDelegate,
                                     GADNativeAdDelegate {
    enum AdState: String {
        case notLoaded, loaded, presented
    }
    
    // MARK: - Properties
    
    // MARK: AdController properties
    
    override var adView: UIView? { bannerAd }
    
    // MARK: Internal properties
    private weak var adRendererDelegate: NimbusAdMobAdRendererDelegate?
    private var started = false
    private var adState = AdState.notLoaded
    
    // MARK: AdMob properties
    private var bannerAd: GADBannerView?
    private var interstitialAd: GADInterstitialAd?
    private var rewardedAd: GADRewardedAd?
    private var nativeAdLoader: GADAdLoader?
    private var nativeAd: GADNativeAd?
    
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
            let bannerAd = GADBannerView()
            bannerAd.translatesAutoresizingMaskIntoConstraints = false
            bannerAd.rootViewController = adPresentingViewController
            bannerAd.delegate = self
            self.bannerAd = bannerAd
            self.adState = .loaded
            bannerAd.load(withAdResponseString: ad.markup)
            presentIfNeeded()
        case .interstitial:
            GADInterstitialAd.load(withAdResponseString: ad.markup) { [weak self] gadInterstitial, error in
                if let gadInterstitial {
                    self?.interstitialAd = gadInterstitial
                    self?.interstitialAd?.fullScreenContentDelegate = self
                    self?.adState = .loaded
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
            GADRewardedAd.load(withAdResponseString: ad.markup) { [weak self] gadRewarded, error in
                if let gadRewarded {
                    self?.rewardedAd = gadRewarded
                    self?.rewardedAd?.fullScreenContentDelegate = self
                    self?.adState = .loaded
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

            nativeAdLoader = GADAdLoader(rootViewController: adPresentingViewController)
            nativeAdLoader?.delegate = self
            nativeAdLoader?.load(withAdResponseString: ad.markup)
        }
    }
    
    func presentIfNeeded() {
        guard started, adState == .loaded else { return }
        
        adState = .presented
        
        if let bannerAd, let container {
            container.addSubview(bannerAd)
            
            NSLayoutConstraint.activate([
                bannerAd.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor),
                bannerAd.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor),
                bannerAd.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor),
                bannerAd.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor)
            ])
        } else if let nativeAd, let container, let adRendererDelegate {
            let nativeAdView = adRendererDelegate.nativeAdViewForRendering(container: container, nativeAd: nativeAd)
            container.addSubview(nativeAdView)
            
            NSLayoutConstraint.activate([
                nativeAdView.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor),
                nativeAdView.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor),
                nativeAdView.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor),
                nativeAdView.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor)
            ])
        } else if let interstitialAd {
            interstitialAd.present(fromRootViewController: adPresentingViewController)
        } else if let rewardedAd {
            rewardedAd.present(fromRootViewController: adPresentingViewController) { [weak self] in
                self?.logger.log("AdMob Event: user earned reward", level: .debug)
                self?.sendNimbusEvent(.completed)
            }
        }
    }
    
    override func start() {
        started = true
        presentIfNeeded()
    }
    
    override func destroy() {
        bannerAd = nil
        nativeAd = nil
        nativeAdLoader = nil
        interstitialAd = nil
        rewardedAd = nil
    }
    
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        sendNimbusEvent(.loaded)
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        sendNimbusEvent(.impression)
    }
    
    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        sendNimbusEvent(.clicked)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: any Error) {
        sendNimbusError(NimbusAdMobError(message: error.localizedDescription))
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    func adDidRecordImpression(_ ad: any GADFullScreenPresentingAd) {
        sendNimbusEvent(.impression)
    }
    
    func adDidRecordClick(_ ad: any GADFullScreenPresentingAd) {
        sendNimbusEvent(.clicked)
    }
    
    func ad(_ ad: any GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        sendNimbusError(NimbusAdMobError(message: error.localizedDescription))
    }
    
    func adDidDismissFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
        destroy()
        sendNimbusEvent(.destroyed)
    }
    
    // MARK: - GADNativeAdLoaderDelegate
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        nativeAd.rootViewController = adPresentingViewController
        nativeAd.delegate = self
        self.nativeAd = nativeAd
        self.adState = .loaded
        presentIfNeeded()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        sendNimbusError(NimbusAdMobError(message: "Failed to receive native ad, error: \(error.localizedDescription)"))
    }
    
    // MARK: - GADNativeAdDelegate
    
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        sendNimbusEvent(.impression)
    }
    
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        sendNimbusEvent(.clicked)
    }
    
    func nativeAdIsMuted(_ nativeAd: GADNativeAd) {
        nimbusAdView?.viewabilityTracker?.volume = 0
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        sendNimbusEvent(.loaded)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToLoadWithError error: Error) {
        sendNimbusError(NimbusAdMobError(message: "Failed to load native ad, error: \(error.localizedDescription)"))
    }
}
