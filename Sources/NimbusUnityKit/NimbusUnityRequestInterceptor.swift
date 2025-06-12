//
//  NimbusUnityRequestInterceptor.swift
//  NimbusUnityKit
//
//  Created on 6/2/21.
//  Copyright © 2021 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRequestKit
import UnityAds

enum NimbusUnityInterceptorError: NimbusError {
    case notInitialized
    case unsupportedDevice
    case invalidAdType
    case tokenNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .notInitialized:
            "UnityAds not initialized"
        case .unsupportedDevice:
            "UnityAds not supported on current device"
        case .invalidAdType:
            "NimbusRequest is not a rewarded ad request, skipping Unity interceptor"
        case .tokenNotAvailable:
            "UnityAds token is not available"
        }
    }
}

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

extension NimbusUnityRequestInterceptor: NimbusRequestInterceptorAsync {
    public func modifyRequest(request: NimbusRequest) async throws -> NimbusRequestDelta {
        guard isInitialized else { throw NimbusUnityInterceptorError.notInitialized }
        guard isSupported else { throw NimbusUnityInterceptorError.unsupportedDevice }
        guard let token else { throw NimbusUnityInterceptorError.tokenNotAvailable }
        guard request.impressions.first?.video?.isRewarded == true else {
            throw NimbusUnityInterceptorError.invalidAdType
        }
        
        return NimbusRequestDelta(userExtension: ("unity_buyeruid", NimbusCodable(token)))
    }
}

// MARK: NimbusRequestInterceptor
/// :nodoc:
extension NimbusUnityRequestInterceptor: NimbusRequestInterceptor {
    
    /// :nodoc:
    public func modifyRequest(request: NimbusRequest) {}
    
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
