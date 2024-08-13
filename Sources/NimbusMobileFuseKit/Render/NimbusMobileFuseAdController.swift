//
//  NimbusMobileFuseAdController.swift
//  NimbusMobileFuseKit
//
//  Created on 9/8/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import NimbusCoreKit
import MobileFuseSDK
import NimbusRenderKit

enum NimbusMobileFuseError: NimbusError, Equatable {
    case failedToLoadAd(type: String? = nil, message: String)
    
    public var errorDescription: String? {
        switch self {
        case let .failedToLoadAd(type, message):
            return "MobileFuse ad failed to load \(getAdTypeMessage(type)) \(message)"
        }
    }
    
    private func getAdTypeMessage(_ type: String?) -> String {
        if let type {
            return "\(type) ad:"
        } else {
            return "ad:"
        }
    }
}

final class NimbusMobileFuseAdController: NSObject {
    
    enum AdState: String {
        case notLoaded, loaded, presented
    }
    
    // MARK: - Properties
    
    // MARK: AdController properties
    weak var internalDelegate: AdControllerDelegate?
    weak var delegate: AdControllerDelegate?
    
    var friendlyObstructions: [UIView]?
    var isClickProtectionEnabled = true
    var volume = 0 {
        didSet {
            bannerAd?.setMuted(isMuted)
        }
    }
    
    // MARK: Private
    private let ad: NimbusAd
    private let logger: Logger
    private let isBlocking: Bool
    private weak var container: UIView?
    private weak var adPresentingViewController: UIViewController?
    private var started = false
    private var adState = AdState.notLoaded
    
    /// Determines whether ad has registered an impression
    private var hasRegisteredAdImpression = false
    
    private var isAdVisible = false
    
    private var isMuted: Bool { volume == 0 }
    
    // MARK: MobileFuse
    private var bannerAd: MFBannerAd?
    private var interstitialAd: MFInterstitialAd?
    private var rewardedAd: MFRewardedAd?
    
    init(ad: NimbusAd,
         container: UIView,
         logger: Logger,
         delegate: AdControllerDelegate,
         isBlocking: Bool,
         adPresentingViewController: UIViewController?) {
        
        self.ad = ad
        self.container = container
        self.logger = logger
        self.delegate = delegate
        self.isBlocking = isBlocking
        self.adPresentingViewController = adPresentingViewController
        
        super.init()
    }
    
    func load() {
        do {
            guard let placementId = ad.placementId else {
                throw NimbusMobileFuseError.failedToLoadAd(message: "Placement Id not found.")
            }
            
            switch adType {
            case .banner:
                guard let size = ad.mobileFuseBannerAdSize else {
                    forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "Failed translating dimensions \(String(describing: ad.adDimensions)) to mobile fuse banner size"))
                    return
                }
                
                bannerAd = MFBannerAd(placementId: placementId, with: size)
                bannerAd!.register(self)
                container?.addSubview(bannerAd!)
                
                bannerAd!.load(withBiddingResponseToken: ad.markup)
                bannerAd!.setMuted(isMuted)
            case .interstitial:
                interstitialAd = MFInterstitialAd(placementId: placementId)
                interstitialAd!.register(self)
                container?.addSubview(interstitialAd!)
                interstitialAd!.load(withBiddingResponseToken: ad.markup)
            case .rewardedVideo:
                rewardedAd = MFRewardedAd(placementId: placementId)
                rewardedAd!.register(self)
                container?.addSubview(rewardedAd!)
                rewardedAd!.load(withBiddingResponseToken: ad.markup)
            default:
                throw NimbusMobileFuseError.failedToLoadAd(message: "MobileFuse doesn't support this ad (type=\(ad.auctionType))")
            }
        } catch {
            if let nimbusError = error as? NimbusError {
                forwardNimbusError(nimbusError)
            }
        }
    }
    
    var adType: MobileFuseAdType? {
        if isBlocking {
            switch ad.auctionType {
            case .static: return .interstitial
            case .video: return .rewardedVideo
            default: return nil
            }
        } else {
            switch ad.auctionType {
            case .static, .video: return .banner
            default: return nil
            }
        }
    }
    
    private func presentAd() {
        guard started, adState == .loaded else { return }
        
        adState = .presented
        
        switch adType {
        case .banner:
            self.bannerAd?.show()
        case .interstitial:
            self.interstitialAd?.show()
        case .rewardedVideo:
            self.rewardedAd?.show()
        default:
            break
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

extension NimbusMobileFuseAdController: IMFAdCallbackReceiver {
    func onAdLoaded() {
        adState = .loaded
        
        logger.log("MobileFuse Event: \(#function)", level: .debug)
        forwardNimbusEvent(.loaded)
        
        presentAd()
    }
    
    func onAdError(_ message: String!) {
        forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "MobileFuse rendering failed with: \(String(describing: message))"))
    }
    
    func onAdRendered() {
        logger.log("MobileFuse Event: \(#function)", level: .debug)
        
        if adType == .banner {
            hasRegisteredAdImpression = true
        }
        
        forwardNimbusEvent(.impression)
    }
    
    func onUserEarnedReward() {
        logger.log("MobileFuse Event: \(#function)", level: .debug)
        forwardNimbusEvent(.completed)
    }
    
    func onAdClosed() {
        logger.log("MobileFuse Event: \(#function)", level: .debug)
        destroy()
        forwardNimbusEvent(.destroyed)
    }
    
    func onAdClicked() {
        logger.log("MobileFuse Event: \(#function)", level: .debug)
        forwardNimbusEvent(.clicked)
    }
}

extension NimbusMobileFuseAdController: AdController {
    var adView: UIView? { nil }

    var adDuration: CGFloat { 0 }
    
    func start() {
        started = true
        
        if adState == .loaded {
            presentAd()
        }
    }
    
    func stop() {}
    
    func destroy() {
        bannerAd?.destroy()
        interstitialAd?.destroy()
        rewardedAd?.destroy()
    }
    
    func didExposureChange(exposure: NimbusViewExposure) {
        if isAdVisible != exposure.isVisible {
            isAdVisible = exposure.isVisible
        }
    }
}
