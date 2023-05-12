//
//  NimbusVungleAdController.swift
//  NimbusVungleKit
//
//  Created by Victor Takai on 13/09/22.
//  Copyright © 2023 Timehop. All rights reserved.
//

@_exported import NimbusRenderKit
import UIKit
import VungleSDK

final class NimbusVungleAdController: NSObject {
    
    weak var delegate: AdControllerDelegate?
    
    var volume = 0
    
    private let ad: NimbusAd
    private let logger: Logger
    private let vungleAdLoader: NimbusVungleAdLoader
    private let vungleAdRenderer: VungleAdRenderer
    private var vungleEventObserverType: NimbusVungleEventObserverType?
    
    private var hasBeenDestroyed = false
    
    private weak var container: NimbusAdView?
    private weak var adPresentingViewController: UIViewController?

    init(
        ad: NimbusAd,
        container: UIView,
        vungleProxyType: NimbusVungleProxyType = NimbusVungleProxy(),
        vungleEventObserverType: NimbusVungleEventObserverType = NimbusVungleEventObserver.shared,
        logger: Logger,
        delegate: AdControllerDelegate,
        adPresentingViewController: UIViewController?
    ) {
        self.ad = ad
        self.container = container as? NimbusAdView
        self.vungleEventObserverType = vungleEventObserverType
        self.logger = logger
        self.delegate = delegate
        self.adPresentingViewController = adPresentingViewController
        
        vungleAdLoader = .init(
            vungleProxyType: vungleProxyType,
            logger: logger
        )
        vungleAdRenderer = .init(vungleProxyType: vungleProxyType)
        
        super.init()
    }
    
    func load() {
        guard let placementId = ad.placementId else {
            self.delegate?.didReceiveNimbusError(
                controller: self,
                error: NimbusVungleError.failedToLoadAd(message: "Placement Id not found.")
            )
            return
        }
        self.vungleEventObserverType?.addDelegate(placementId: placementId, delegate: self)
        
        do {
            try vungleAdLoader.loadAd(ad, placementId: placementId)
        } catch {
            if let nimbusError = error as? NimbusError {
                self.delegate?.didReceiveNimbusError(controller: self, error: nimbusError)
            }
        }
    }
    
    private func startAd() {
        do {
            let adTypeToStart = try vungleAdLoader.start(ad: ad)
            try vungleAdRenderer.startAd(
                ad: ad,
                adType: adTypeToStart,
                container: container,
                volume: volume,
                adPresentingViewController: adPresentingViewController
            )
        } catch {
            if let nimbusError = error as? NimbusError {
                delegate?.didReceiveNimbusError(
                    controller: self,
                    error: nimbusError
                )
            }
        }
    }
}

// MARK: AdController

extension NimbusVungleAdController: AdController {
    
    var adView: UIView? { nil }
    
    var adDuration: CGFloat { 0 }
    
    func start() {
        guard !hasBeenDestroyed else {
            delegate?.didReceiveNimbusError(
                controller: self,
                error: NimbusRenderError.adRenderingFailed(message: "Vungle Ad has been destroyed.")
            )
            return
        }
        
        if vungleAdLoader.isLoaded {
            startAd()
        } else {
            vungleAdLoader.allowAdStart()
        }
    }
    
    func stop() {}
    
    func destroy() {
        guard !hasBeenDestroyed else { return }
        hasBeenDestroyed = true
        
        let isMrecOrBanner = ad.isAdMRECType || ad.isAdSizeBannerType
        guard isMrecOrBanner else { return }
        
        vungleAdRenderer.destroy(ad: ad)
    }
    
    var friendlyObstructions: [UIView]? { nil }
}

// MARK: NimbusVungleEventObserverDelegate
/// :nodoc:
extension NimbusVungleAdController: NimbusVungleEventObserverDelegate {
    
    /// :nodoc:
    func adPlayabilityUpdate(_ isAdPlayable: Bool, placementID: String?, markup: String?, error: Error?) {
        // TODO:
        let hasUpdateForCurrentAd = ad.placementId == placementID
        guard hasUpdateForCurrentAd else { return }
        
        if let error {
            vungleAdLoader.completeAdLoadWithError()

            delegate?.didReceiveNimbusError(
                controller: self,
                error: NimbusVungleError.failedToLoadStaticAd(type: ad.adType, message: error.localizedDescription)
            )
            return
        }

        guard isAdPlayable else {
            logger.log("Vungle ad is not playable", level: .error)
            
            return
        }
        
        vungleAdLoader.completeAdLoad()
        delegate?.didReceiveNimbusEvent(controller: self, event: .loaded)

        if vungleAdLoader.isAllowedToStart {
            startAd()
        }
    }
    
    /// :nodoc:
    func adViewed(for placementID: String?, markup: String?) {
        delegate?.didReceiveNimbusEvent(controller: self, event: .impression)
    }
    
    /// :nodoc:
    func trackClick(for placementID: String?, markup: String?) {
        delegate?.didReceiveNimbusEvent(controller: self, event: .clicked)
    }
    
    /// :nodoc:
    func didCloseAd(for placementID: String?, markup: String?) {
        if !hasBeenDestroyed {
            hasBeenDestroyed = true
            
            delegate?.didReceiveNimbusEvent(controller: self, event: .destroyed)
        }
    }
    
    /// :nodoc:
    func rewardUser(for placementID: String?, markup: String?) {
        delegate?.didReceiveNimbusEvent(controller: self, event: .completed)
    }
}
