//
//  NimbusUnityRequestInterceptor.swift
//  NimbusUnityKit
//
//  Created by Inder Dhir on 6/2/21.
//  Copyright © 2021 Timehop. All rights reserved.
//

@_exported import NimbusRequestKit
import UnityAds

public class NimbusUnityRequestInterceptor: NSObject {
    
    var isSupported: Bool {
        UnityAds.isSupported()
    }
    
    var isInitialized: Bool {
        UnityAds.isInitialized()
    }
    
    var token: String? {
        UnityAds.getToken()
    }
    
    public init(gameId: String) {
        super.init()
        
        let metadata = UADSMetaData(category: "headerbidding")
        metadata?.setRaw("mode", value: "enabled")
        metadata?.commit()
        
        UnityAds.setDebugMode(Nimbus.shared.logLevel != .off)
        UnityAds.initialize(
            gameId,
            testMode: Nimbus.shared.testMode,
            initializationDelegate: self
        )
        
        Nimbus.shared.logger.log("Unity provider initialized", level: .info)
    }
}


// MARK: NimbusRequestInterceptor
/// :nodoc:
extension NimbusUnityRequestInterceptor: NimbusRequestInterceptor {
    
    /// :nodoc:
    public func modifyRequest(request: NimbusRequest) {
        Nimbus.shared.logger.log("Modifying NimbusRequest for Unity", level: .debug)
        
        guard request.impressions.first?.video?.isRewarded == true else {
            Nimbus.shared.logger.log(
                "NimbusRequest is not a rewarded ad request, skipping Unity ads modification",
                level: .debug
            )
            return
        }
        
        guard isSupported else {
            Nimbus.shared.logger.log("UnityAds not supported on current device", level: .error)
            return
        }
        guard isInitialized else {
            Nimbus.shared.logger.log("UnityAds not initialized", level: .error)
            return
        }
        
        guard let token else {
            Nimbus.shared.logger.log("UnityAds token absent", level: .error)
            return
        }
        
        if request.user == nil { request.user = NimbusUser() }
        if request.user?.extensions == nil { request.user?.extensions = [:] }
        request.user?.extensions?["unity_buyeruid"] = NimbusCodable(token)
        
        request.device.hardwareVersion = UIDevice.current.nimbusModelName
    }
    
    /// :nodoc:
    public func didCompleteNimbusRequest(with response: NimbusAd) {
        Nimbus.shared.logger.log("Completed NimbusRequest with Unity", level: .debug)
    }
    
    /// :nodoc:
    public func didFailNimbusRequest(with error: NimbusError) {
        Nimbus.shared.logger.log("Failed NimbusRequest with Unity", level: .error)
    }
}

// MARK: UnityAdsInitializationDelegate
/// :nodoc:
extension NimbusUnityRequestInterceptor: UnityAdsInitializationDelegate {
    
    /// :nodoc:
    public func initializationComplete() {
        Nimbus.shared.logger.log("Unity SDK initialization completed!", level: .debug)
    }
    
    /// :nodoc:
    public func initializationFailed(
        _ error: UnityAdsInitializationError,
        withMessage message: String
    ) {
        Nimbus.shared.logger.log("Unity SDK initialization failed: \(message)", level: .error)
    }
}
