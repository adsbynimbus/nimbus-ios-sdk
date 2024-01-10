//
//  NimbusAPSRequestInterceptor.swift
//  NimbusRequestAPSKit
//
//  Created on 10/4/19.
//  Copyright © 2019 Nimbus Advertising Solutions Inc. All rights reserved.
//

import DTBiOSSDK
import Foundation

/// Enables APS demand for NimbusRequest.
/// Add an instance of this to `NimbusAdManager.requestInterceptors`
@available(*, deprecated, message: "")
public final class NimbusAPSRequestInterceptor {
    
    private let adSizes: [DTBAdSize]
    private let viewabilityManager = NimbusAPSViewabilityManager()
    var requestManager: APSLegacyRequestManagerType
    
    /**
     Initializes a NimbusAPSRequestInterceptor instance
     
     - Parameters:
     - appKey: App key for APS
     - adSizes: Ad sizes for APS ads
     */
    public init(appKey: String, adSizes: [DTBAdSize]) {
        self.adSizes = adSizes

        requestManager = NimbusAPSLegacyRequestManager(
            appKey: appKey,
            logger: Nimbus.shared.logger,
            logLevel: Nimbus.shared.logLevel
        )
        
        Nimbus.shared.logger.log("APS provider initialized", level: .info)
    }
    
    private func modify(
        payload: inout [[String: NimbusCodable]],
        with data: [AnyHashable: Any]
    ) {
        guard let modifiedDict = data as? [String: Any] else { return }
        
        let payloadWithCodableValues =
        modifiedDict.compactMapValues { value -> NimbusCodable? in
            if let arr = value as? [String] {
                return NimbusCodable(arr)
            } else if let strValue = value as? String {
                return NimbusCodable(strValue)
            }
            return nil
        }
        payload.append(payloadWithCodableValues)
    }
}

// MARK: NimbusRequestInterceptor

/// :nodoc:
extension NimbusAPSRequestInterceptor: NimbusRequestInterceptor {
    
    /// :nodoc:
    public func modifyRequest(request: NimbusRequest) {
        let hasNewAPSInterceptorPresent = request.interceptors?.first(where: { $0 is NimbusAPSOnRequestInterceptor }) != nil
        guard !hasNewAPSInterceptorPresent else {
            // Don't use old code if the new APS implementation is setup
            return
        }
        
        Nimbus.shared.logger.log("Modifying NimbusRequest for APS", level: .debug)
        
        viewabilityManager.setup(for: request)

        guard let impression = request.impressions[safe: 0] else {
            Nimbus.shared.logger.log("Request malformed. Ignoring APS demand", level: .error)
            
            return
        }
        
        let validAdSizes = adSizes.filter { adSize in
            switch adSize.adType {
            case INTERSTITIAL:
                return impression.banner != nil && impression.isInterstitial == true
            case VIDEO:
                return impression.video != nil
            default:
                if let banner = impression.banner {
                    return (banner.width == adSize.width && banner.height == adSize.height) ||
                    (banner.formats?.contains(where: {
                        $0.width == adSize.width &&
                        $0.height == adSize.height
                    }) ?? false)
                }
                return false
            }
        }
        
        requestManager.usPrivacyString = Nimbus.shared.usPrivacyString
        let apsPayloads = requestManager.loadAdsSync(for: validAdSizes)
        guard apsPayloads.count > 0 else {
            Nimbus.shared.logger.log("No APS ad payload to inject into the NimbusRequest", level: .debug)
            
            return
        }
        
        var resultingPayload: [[String: NimbusCodable]] = []
        apsPayloads.forEach { apsPayload in
            Nimbus.shared.logger.log("Modifying NimbusRequest with APS payload", level: .debug)
            
            modify(payload: &resultingPayload, with: apsPayload)
        }
        
        if request.impressions[0].extensions == nil {
            request.impressions[0].extensions = [:]
        }
        request.impressions[0].extensions?["aps"] = NimbusCodable(resultingPayload)
    }
    
    /// :nodoc:
    public func didCompleteNimbusRequest(with response: NimbusAd) {
        Nimbus.shared.logger.log("Completed NimbusRequest for APS", level: .debug)
    }
    
    /// :nodoc:
    public func didFailNimbusRequest(with error: NimbusError) {
        Nimbus.shared.logger.log("Failed NimbusRequest for APS", level: .error)
    }
}
