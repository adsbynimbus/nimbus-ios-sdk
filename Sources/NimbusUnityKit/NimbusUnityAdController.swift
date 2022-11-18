//
//  NimbusUnityAdController.swift
//  NimbusUnityKit
//
//  Created by Inder Dhir on 6/2/21.
//  Copyright © 2021 Timehop. All rights reserved.
//

@_exported import NimbusRenderKit
import UnityAds

final class NimbusUnityAdController: NSObject {
    
    public weak var delegate: AdControllerDelegate?
    var volume: Int
    private let ad: NimbusAd
    private let logger: Logger
    private var isLoaded = false
    private var shouldStart = false
    private weak var container: NimbusAdView?
    private weak var adPresentingViewController: UIViewController?
    
    private let adObjectId: String
    
    init(
        ad: NimbusAd,
        container: UIView & VisibilityTrackable,
        visibilityManager: VisibilityManager? = nil,
        volume: Int,
        logger: Logger,
        delegate: AdControllerDelegate,
        adPresentingViewController: UIViewController?
    ) {
        self.ad = ad
        self.container = container as? NimbusAdView
        self.volume = volume
        self.logger = logger
        self.delegate = delegate
        self.adPresentingViewController = adPresentingViewController
        
        self.adObjectId = NSUUID().uuidString
        
        super.init()
        
        guard ad.auctionType == .video else {
            Nimbus.shared.logger.log(
                "UnityAds not supported for \(ad.auctionType)",
                level: .error
            )
            return
        }
        
        let loadOptions = UADSLoadOptions()
        loadOptions?.adMarkup = ad.markup
        loadOptions?.objectId = adObjectId
        guard let options = loadOptions, let placementId = ad.placementId else {
            return
        }
        
        isLoaded = false
        shouldStart = false
        
        UnityAds.load(placementId, options: options, loadDelegate: self)
    }
}

// MARK: AdController

extension NimbusUnityAdController: AdController {
    
    var adView: UIView? { nil }

    var adDuration: CGFloat { 0 }

    func start() {
        guard let adPresentingViewController = adPresentingViewController,
              let placementId = ad.placementId else {
            Nimbus.shared.logger.log("UnityAds not initialized", level: .error)
            return
        }
        
        if isLoaded {
            if let showOptions = UADSShowOptions() {
                showOptions.objectId = adObjectId
                UnityAds.show(adPresentingViewController, placementId: placementId, options: showOptions, showDelegate: self)
                isLoaded = false
            } else {
                Nimbus.shared.logger.log("UnityAds - error initializing UADSShowOptions", level: .error)
            }
        } else {
            shouldStart = true
        }
    }

    func stop() {}

    func destroy() {}
    
    var friendlyObstructions: [UIView]? { nil }
}

extension NimbusUnityAdController: UnityAdsLoadDelegate {
    
    func unityAdsAdLoaded(_ placementId: String) {
        guard let adPresentingViewController = adPresentingViewController else {
            Nimbus.shared.logger.log("UnityAds not initialized", level: .error)
            return
        }
        
        if let showOptions = UADSShowOptions() {
            showOptions.objectId = adObjectId
            UnityAds.show(adPresentingViewController, placementId: placementId, options: showOptions, showDelegate: self)
            isLoaded = false
        } else {
            Nimbus.shared.logger.log("UnityAds - error initializing UADSShowOptions", level: .error)
        }
        
        if shouldStart {
            if let showOptions = UADSShowOptions() {
                showOptions.objectId = adObjectId
                UnityAds.show(adPresentingViewController, placementId: placementId, options: showOptions, showDelegate: self)
                shouldStart = false
            }
        } else {
            isLoaded = true
        }
        
        delegate?.didReceiveNimbusEvent(controller: self, event: .loaded)
    }
    
    func unityAdsAdFailed(
        toLoad placementId: String,
        withError error: UnityAdsLoadError,
        withMessage message: String
    ) {
        Nimbus.shared.logger.log("UnityAds failed to load: \(message)", level: .error)
        
        delegate?.didReceiveNimbusError(controller: self, error: NimbusRenderError.adRenderingFailed(message: message))
        
        isLoaded = false
        shouldStart = false
    }
}

extension NimbusUnityAdController: UnityAdsShowDelegate {
    
    func unityAdsShowComplete(
        _ placementId: String,
        withFinish state: UnityAdsShowCompletionState
    ) {
        delegate?.didReceiveNimbusEvent(
            controller: self,
            event: state == .showCompletionStateCompleted ? .completed : .skipped
        )
        delegate?.didReceiveNimbusEvent(controller: self, event: .destroyed)
    }
    
    func unityAdsShowFailed(
        _ placementId: String,
        withError error: UnityAdsShowError,
        withMessage message: String
    ) {
        Nimbus.shared.logger.log("UnityAds failed to show: \(message) - error: \(error.rawValue)", level: .error)
        
        // Unity seems to throw this error after showing an ad. This is NOT a hard failure
        // so skip sending a Nimbus error for this case
        if error != UnityAdsShowError.showErrorAlreadyShowing {
            delegate?.didReceiveNimbusError(
                controller: self,
                error: NimbusRenderError.adRenderingFailed(message: message)
            )
        }
    }
    
    func unityAdsShowStart(_ placementId: String) {
        delegate?.didReceiveNimbusEvent(controller: self, event: .impression)
    }
    
    func unityAdsShowClick(_ placementId: String) {
        delegate?.didReceiveNimbusEvent(controller: self, event: .clicked)
    }
}
