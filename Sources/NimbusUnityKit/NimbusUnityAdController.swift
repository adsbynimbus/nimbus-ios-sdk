//
//  NimbusUnityAdController.swift
//  NimbusUnityKit
//
//  Created on 6/2/21.
//  Copyright © 2021 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRenderKit
import UnityAds

final class NimbusUnityAdController: NimbusAdController, UnityAdsLoadDelegate, UnityAdsShowDelegate {
    
    private var isLoaded = false
    private var shouldStart = false
    private let adObjectId: String
    
    init(
        ad: NimbusAd,
        container: UIView,
        logger: Logger,
        delegate: (any AdControllerDelegate)?,
        isBlocking: Bool,
        isRewarded: Bool,
        adPresentingViewController: UIViewController?
    ) {
        self.adObjectId = NSUUID().uuidString
        
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
        guard adType == .rewarded else {
            sendNimbusError(NimbusRenderError.invalidAdType)
            return
        }
        
        let loadOptions = UADSLoadOptions()
        loadOptions?.adMarkup = ad.markup
        loadOptions?.objectId = adObjectId
        guard let loadOptions, let placementId = ad.placementId else {
            return
        }
        
        UnityAds.load(placementId, options: loadOptions, loadDelegate: self)
    }
    
    // MARK: - AdController
    
    override func start() {
        guard let adPresentingViewController,
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

    override func destroy() {}
    
    // MARK: - UnityAdsLoadDelegate
        
    func unityAdsAdLoaded(_ placementId: String) {
        guard let adPresentingViewController else {
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
        
        sendNimbusEvent(.loaded)
    }
    
    func unityAdsAdFailed(
        toLoad placementId: String,
        withError error: UnityAdsLoadError,
        withMessage message: String
    ) {
        Nimbus.shared.logger.log("UnityAds failed to load: \(message)", level: .error)
        
        sendNimbusError(NimbusRenderError.adRenderingFailed(message: message))
        
        isLoaded = false
        shouldStart = false
    }
    
    // MARK: - UnityAdsShowDelegate
        
    func unityAdsShowComplete(
        _ placementId: String,
        withFinish state: UnityAdsShowCompletionState
    ) {
        sendNimbusEvent(state == .showCompletionStateCompleted ? .completed : .skipped)
        sendNimbusEvent(.destroyed)
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
            sendNimbusError(NimbusRenderError.adRenderingFailed(message: message))
        }
    }
    
    func unityAdsShowStart(_ placementId: String) {
        sendNimbusEvent(.impression)
    }
    
    func unityAdsShowClick(_ placementId: String) {
        sendNimbusEvent(.clicked)
    }
}
