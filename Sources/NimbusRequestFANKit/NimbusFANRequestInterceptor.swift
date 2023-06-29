//
//  NimbusFANRequestInterceptor.swift
//  NimbusRequestFANKit
//
//  Created by Inder Dhir on 10/4/19.
//  Copyright © 2019 Timehop. All rights reserved.
//

@_exported import NimbusRequestKit
import FBAudienceNetwork

/// Enables FAN demand for NimbusRequest
/// Add an instance of this to `NimbusAdManager.requestInterceptors`
public final class NimbusFANRequestInterceptor: NimbusRequestInterceptor {
    
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
        
        Nimbus.shared.logger.log("FAN provider initialized", level: .info)
    }
    
    /// :nodoc:
    public func modifyRequest(request: NimbusRequest) {
        Nimbus.shared.logger.log("Modifying NimbusRequest for FAN", level: .debug)
        
        guard request.impressions.count == 1,
              request.impressions[0].extensions != nil,
              request.impressions[0].position != nil
        else {
            Nimbus.shared.logger.log("NimbusRequest malformed. Skipping FAN modification", level: .error)
            return
        }
        
        request.impressions[0].extensions?["facebook_app_id"] = NimbusCodable(appId)
        if isAppendingTestPayload {
            request.impressions[0].extensions?["facebook_test_ad_type"]
            = NimbusCodable(fbTestAdType)
        }
        
        if request.user == nil {
            request.user = NimbusUser()
        }
        if request.user?.extensions == nil {
            request.user?.extensions = [:]
        }
        request.user?.extensions?["facebook_buyeruid"] = NimbusCodable(bidderToken)
    }
    
    /// :nodoc:
    public func didCompleteNimbusRequest(with response: NimbusAd) {
        Nimbus.shared.logger.log("Completed NimbusRequest for FAN", level: .debug)
    }
    
    /// :nodoc:
    public func didFailNimbusRequest(with error: NimbusError) {
        Nimbus.shared.logger.log("Failed NimbusRequest for FAN", level: .error)
    }
    
    private var isAppendingTestPayload: Bool {
        forceTestAd && Nimbus.shared.testMode
    }
}
