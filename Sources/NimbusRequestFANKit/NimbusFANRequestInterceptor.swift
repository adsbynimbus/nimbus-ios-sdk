//
//  NimbusFANRequestInterceptor.swift
//  NimbusRequestFANKit
//
//  Created on 10/4/19.
//  Copyright © 2019 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRequestKit
import FBAudienceNetwork
import AppTrackingTransparency

/// Enables FAN demand for NimbusRequest
/// Add an instance of this to `NimbusAdManager.requestInterceptors`
public final class NimbusFANRequestInterceptor {
    
    /// Force a test ad for FAN
    public var forceTestAd = false
    
    /// Facebook app id
    private let appId: String
    
    /// Facebook bidder token
    private let bidderToken: String
    
    /// Supported FB Test ad type
    private lazy var fbTestAdType = "IMG_16_9_LINK"
    
    /**
     Initializes a NimbusFANRequestInterceptor instance
     
     - Parameters:
     - appId: Facebook app id
     */
    public convenience init(appId: String) {
        FBAdSettings.setMediationService("Ads By Nimbus")
        self.init(appId: appId, bidderToken: FBAdSettings.bidderToken)
    }
    
    /**
     Initializes a NimbusFANRequestInterceptor instance
     
     - Parameters:
     - appId: Facebook app id
     - bidderToken: Facebook bidder token (Send `FBAdSettings.bidderToken` here)
     */
    init(appId: String, bidderToken: String) {
        self.appId = appId
        self.bidderToken = bidderToken
        
        FBAdSettings.setLogLevel(Nimbus.shared.logLevel.fanLogLevel)
        
        if #available(iOS 14.5, *), ATTrackingManager.trackingAuthorizationStatus == .authorized {
            FBAdSettings.setAdvertiserTrackingEnabled(true)
        }
        
        Nimbus.shared.logger.log("FAN provider initialized", level: .info)
    }
    
    private var isAppendingTestPayload: Bool {
        forceTestAd && Nimbus.shared.testMode
    }
}

extension NimbusFANRequestInterceptor: NimbusRequestInterceptorAsync {
    public func modifyRequest(request: NimbusRequest) async throws -> NimbusRequestDelta {
        var extensions: [String: NimbusCodable] = [
            "facebook_app_id": NimbusCodable(appId),
            "facebook_buyeruid": NimbusCodable(bidderToken)
        ]
        
        if isAppendingTestPayload {
            extensions["facebook_test_ad_type"] = NimbusCodable(fbTestAdType)
        }
        
        return NimbusRequestDelta(impressionExtensions: extensions)
    }
}

extension NimbusFANRequestInterceptor: NimbusRequestInterceptor {
    /// :nodoc:
    public func modifyRequest(request: NimbusRequest) {}
    
    /// :nodoc:
    public func didCompleteNimbusRequest(with response: NimbusAd) {
        Nimbus.shared.logger.log("Completed NimbusRequest for FAN", level: .debug)
    }
    
    /// :nodoc:
    public func didFailNimbusRequest(with error: NimbusError) {
        Nimbus.shared.logger.log("Failed NimbusRequest for FAN", level: .error)
    }
}
