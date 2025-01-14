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

final class NimbusMobileFuseAdController: NimbusAdController, IMFAdCallbackReceiver {
    
    enum AdState: String {
        case notLoaded, loaded, presented
    }
    
    // MARK: - Properties
    
    // MARK: AdController properties
    
    override var volume: Int {
        didSet {
            bannerAd?.setMuted(isMuted)
        }
    }
    
    // MARK: Private
    
    private var started = false
    private var adState = AdState.notLoaded
    
    /// Determines whether ad has registered an impression
    private var hasRegisteredAdImpression = false
    
    private var isMuted: Bool { volume == 0 }
    
    // MARK: MobileFuse
    private var bannerAd: MFBannerAd?
    private var interstitialAd: MFInterstitialAd?
    private var rewardedAd: MFRewardedAd?
    
    func load() {
        do {
            guard let placementId = ad.placementId else {
                throw NimbusMobileFuseError.failedToLoadAd(message: "Placement Id not found.")
            }
            guard let adType else {
                sendNimbusError(NimbusRenderError.invalidAdType)
                return
            }
            
            switch adType {
            case .banner:
                guard let size = ad.mobileFuseBannerAdSize else {
                    sendNimbusError(NimbusRenderError.adRenderingFailed(message: "Failed translating dimensions \(String(describing: ad.adDimensions)) to mobile fuse banner size"))
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
            case .rewarded:
                rewardedAd = MFRewardedAd(placementId: placementId)
                rewardedAd!.register(self)
                container?.addSubview(rewardedAd!)
                rewardedAd!.load(withBiddingResponseToken: ad.markup)
            default:
                throw NimbusMobileFuseError.failedToLoadAd(message: "MobileFuse doesn't support this ad type: \(adType)")
            }
        } catch {
            if let nimbusError = error as? NimbusError {
                sendNimbusError(nimbusError)
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
        case .rewarded:
            self.rewardedAd?.show()
        default:
            break
        }
    }
    
    // MARK: - AdController overrides
    
    override func start() {
        started = true
        
        if adState == .loaded {
            presentAd()
        }
    }
    
    override func destroy() {
        bannerAd?.destroy()
        interstitialAd?.destroy()
        rewardedAd?.destroy()
    }
    
    // MARK: - IMFAdCallbackReceiver
    
    func onAdLoaded() {
        adState = .loaded
        
        logger.log("MobileFuse Event: \(#function)", level: .debug)
        sendNimbusEvent(.loaded)
        
        presentAd()
    }
    
    func onAdError(_ message: String!) {
        sendNimbusError(NimbusRenderError.adRenderingFailed(message: "MobileFuse rendering failed with: \(String(describing: message))"))
    }
    
    func onAdRendered() {
        logger.log("MobileFuse Event: \(#function)", level: .debug)
        
        if adType == .banner {
            hasRegisteredAdImpression = true
        }
        
        sendNimbusEvent(.impression)
    }
    
    func onUserEarnedReward() {
        logger.log("MobileFuse Event: \(#function)", level: .debug)
        sendNimbusEvent(.completed)
    }
    
    func onAdClosed() {
        logger.log("MobileFuse Event: \(#function)", level: .debug)
        destroy()
        sendNimbusEvent(.destroyed)
    }
    
    func onAdClicked() {
        logger.log("MobileFuse Event: \(#function)", level: .debug)
        sendNimbusEvent(.clicked)
    }
}
