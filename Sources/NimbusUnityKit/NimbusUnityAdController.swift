//
//  NimbusUnityAdController.swift
//  NimbusUnityKit
//
//  Created on 6/2/21.
//  Copyright © 2021 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRenderKit
import UnityAds

enum NimbusUnityError: NimbusError {
    case couldntInitLoadOptions
    case couldntInitShowOptions
    
    var errorDescription: String? {
        switch self {
        case .couldntInitLoadOptions: return "Unity Ads load options (UADSLoadOptions) could not initialize"
        case .couldntInitShowOptions: return "Unity Ads show options (UADSShowOptions) could not initialize"
        }
    }
}

final class NimbusUnityAdController: NimbusAdController, UnityAdsLoadDelegate, UnityAdsShowDelegate {
    
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
        guard adType == .rewarded, let placementId = ad.placementId else {
            sendNimbusError(NimbusRenderError.invalidAdType)
            return
        }
        
        guard let loadOptions = UADSLoadOptions() else {
            sendNimbusError(NimbusUnityError.couldntInitLoadOptions)
            return
        }
        
        loadOptions.adMarkup = ad.markup
        loadOptions.objectId = adObjectId
        
        UnityAds.load(placementId, options: loadOptions, loadDelegate: self)
    }
    
    private func present() {
        guard started, adState == .ready, let placementId = ad.placementId, let adPresentingViewController else { return }
        
        adState = .resumed
        
        guard let showOptions = UADSShowOptions() else {
            sendNimbusError(NimbusUnityError.couldntInitShowOptions)
            return
        }
        
        showOptions.objectId = adObjectId
        UnityAds.show(adPresentingViewController, placementId: placementId, options: showOptions, showDelegate: self)
    }
    
    // MARK: - AdController
    
    override func onStart() {        
        if adState == .ready {
            present()
        }
    }

    override func destroy() {
        guard adState != .destroyed else { return }
        
        adState = .destroyed
    }
    
    // MARK: - UnityAdsLoadDelegate
        
    func unityAdsAdLoaded(_ placementId: String) {
        sendNimbusEvent(.loaded)
        
        adState = .ready
        present()
    }
    
    func unityAdsAdFailed(
        toLoad placementId: String,
        withError error: UnityAdsLoadError,
        withMessage message: String
    ) {
        Nimbus.shared.logger.log("UnityAds failed to load: \(message)", level: .error)
        
        sendNimbusError(NimbusRenderError.adRenderingFailed(message: message))
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
