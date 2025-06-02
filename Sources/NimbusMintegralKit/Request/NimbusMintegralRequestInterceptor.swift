//
//  NimbusMintegralRequestInterceptor.swift
//  Nimbus
//  Created on 10/30/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusRequestKit
import NimbusRenderKit
import MTGSDK
import MTGSDKBidding

public final class NimbusMintegralRequestInterceptor {
    /// Nimbus internal logger
    private let logger: Logger = Nimbus.shared.logger
    
    let adUnitId: String
    let placementId: String?
    
    public init(adUnitId: String, placementId: String? = nil) {
        self.adUnitId = adUnitId
        self.placementId = placementId
    }
}

extension NimbusMintegralRequestInterceptor: NimbusRequestInterceptor {
    
    public func modifyRequest(request: NimbusRequest) {
        switch request.regs?.coppa {
        case nil: MTGSDK.sharedInstance().coppa = .unknown
        case .some(let enabled): MTGSDK.sharedInstance().coppa = enabled ? .yes : .no
        }
        
        if request.user == nil { request.user = .init() }
        if request.user?.extensions == nil { request.user?.extensions = [:] }
        
        request.user?.extensions?["mintegral_sdk"] = NimbusCodable([
            "buyeruid": MTGBiddingSDK.buyerUID(),
            "sdkv": MTGSDK.sdkVersion()
        ])
    }
    
    public func didCompleteNimbusRequest(with ad: NimbusAd) {
        logger.log("Completed NimbusRequest for Mintegral.", level: .debug)
    }
    
    public func didFailNimbusRequest(with error: NimbusError) {
        logger.log("Failed NimbusRequest for Mintegral", level: .error)
    }

    public func renderInfo(for ad: NimbusAd) -> Any? {
        guard ad.network == ThirdPartyDemandNetwork.mintegral.rawValue else {
            return nil
        }

        return NimbusMintegralRenderInfo(adUnitId: adUnitId, placementId: placementId)
    }
}
