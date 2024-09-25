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

final class NimbusAdMobAdController: NSObject {
    
    enum AdState: String {
        case notLoaded, loaded, presented
    }
    
    // MARK: - Properties
    
    // MARK: AdController properties
    weak var internalDelegate: AdControllerDelegate?
    weak var delegate: AdControllerDelegate?
    
    var friendlyObstructions: [UIView]?
    var isClickProtectionEnabled = true
    var volume = 0
    
    // MARK: Internal properties
    private let ad: NimbusAd
    private let logger: Logger
    private let isBlocking: Bool
    private weak var container: UIView?
    private weak var adPresentingViewController: UIViewController?
    private weak var adRendererDelegate: NimbusAdMobAdRendererDelegate?
    private var started = false
    private var adState = AdState.notLoaded
    private lazy var adType: NimbusAdMobAdType? = {
        NimbusAdMobAdType(ad: ad, isBlocking: isBlocking)
    }()
    
    // MARK: AdMob properties
    private var bannerAd: GADBannerView?
    private var interstitialAd: GADInterstitialAd?
    private var rewardedAd: GADRewardedAd?
    private var nativeAdLoader: GADAdLoader?
    private var nativeAd: GADNativeAd?
    
    init(ad: NimbusAd,
         container: UIView,
         logger: Logger,
         delegate: AdControllerDelegate,
         isBlocking: Bool,
         adPresentingViewController: UIViewController?,
         adRendererDelegate: NimbusAdMobAdRendererDelegate? = nil) {
        
        self.ad = ad
        self.container = container
        self.logger = logger
        self.delegate = delegate
        self.isBlocking = isBlocking
        self.adPresentingViewController = adPresentingViewController
        self.adRendererDelegate = adRendererDelegate
    }
    
    func load() {
        guard let adType else {
            forwardNimbusError(NimbusRenderError.adUnsupportedAuctionType(auctionType: ad.auctionType, network: ad.network))
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
                    self?.presentIfNeeded()
                } else {
                    let message: String
                    if let error { message = error.localizedDescription }
                    else { message = "Received neither an AdMob interstitial ad nor an error." }
                    
                    self?.forwardNimbusError(NimbusAdMobError(message: message))
                }
            }
        case .rewarded:
            GADRewardedAd.load(withAdResponseString: ad.markup) { [weak self] gadRewarded, error in
                if let gadRewarded {
                    self?.rewardedAd = gadRewarded
                    self?.rewardedAd?.fullScreenContentDelegate = self
                    self?.adState = .loaded
                    self?.presentIfNeeded()
                } else {
                    let message: String
                    if let error { message = error.localizedDescription }
                    else { message = "Received neither an AdMob rewarded ad nor an error." }
                    
                    self?.forwardNimbusError(NimbusAdMobError(message: message))
                }
            }
        case .native:
            guard let _ = adRendererDelegate else {
                forwardNimbusError(NimbusAdMobError(message: "NimbusAdMobAdRendererDelegate must be set to render native ads"))
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
                self?.forwardNimbusEvent(.completed)
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

extension NimbusAdMobAdController: AdController {
    var adView: UIView? { bannerAd }

    var adDuration: CGFloat { 0 }
    
    func start() {
        started = true
        presentIfNeeded()
    }
    
    func stop() {}
    
    func destroy() {
        bannerAd?.removeFromSuperview()
        bannerAd = nil
        nativeAd = nil
        nativeAdLoader = nil
        interstitialAd = nil
        rewardedAd = nil
    }
}

extension NimbusAdMobAdController: GADBannerViewDelegate {
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        forwardNimbusEvent(.impression)
    }
    
    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        forwardNimbusEvent(.clicked)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: any Error) {
        forwardNimbusError(NimbusAdMobError(message: error.localizedDescription))
    }
}

extension NimbusAdMobAdController: GADFullScreenContentDelegate {
    func adDidRecordImpression(_ ad: any GADFullScreenPresentingAd) {
        forwardNimbusEvent(.impression)
    }
    
    func adDidRecordClick(_ ad: any GADFullScreenPresentingAd) {
        forwardNimbusEvent(.clicked)
    }
    
    func ad(_ ad: any GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        forwardNimbusError(NimbusAdMobError(message: error.localizedDescription))
    }
    
    func adDidDismissFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
        destroy()
        forwardNimbusEvent(.destroyed)
    }
}

extension NimbusAdMobAdController: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        nativeAd.rootViewController = adPresentingViewController
        nativeAd.delegate = self
        self.nativeAd = nativeAd
        self.adState = .loaded
        presentIfNeeded()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        forwardNimbusError(NimbusAdMobError(message: "Failed to receive native ad, error: \(error.localizedDescription)"))
    }
}

extension NimbusAdMobAdController: GADNativeAdDelegate {
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        forwardNimbusEvent(.impression)
    }
    
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        forwardNimbusEvent(.clicked)
    }
    
    func nativeAdIsMuted(_ nativeAd: GADNativeAd) {
        (container as? NimbusAdView)?.viewabilityTracker?.volume = 0
    }
}
