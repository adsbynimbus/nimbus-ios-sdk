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
    
    private let bridge: MintegralRequestBridge
    
    public convenience init(adUnitId: String, placementId: String? = nil) {
        self.init(adUnitId: adUnitId, placementId: placementId, bridge: MintegralRequestBridge())
    }
    
    init(adUnitId: String, placementId: String? = nil, bridge: MintegralRequestBridge) {
        self.adUnitId = adUnitId
        self.placementId = placementId
        self.bridge = bridge
    }
}

extension NimbusMintegralRequestInterceptor: NimbusRequestInterceptorAsync {
    public func modifyRequest(request: NimbusRequest) async throws -> NimbusRequestDelta {        
        if let coppa = request.regs?.coppa {
            await bridge.set(coppa: coppa)
        }
        
        let data = await NimbusCodable(bridge.tokenData)
        
        try Task.checkCancellation()
        
        return NimbusRequestDelta(userExtension: ("mintegral_sdk", data))
    }
}

extension NimbusMintegralRequestInterceptor: NimbusRequestInterceptor {
    
    public func modifyRequest(request: NimbusRequest) {}
    
    public func didCompleteNimbusRequest(with ad: NimbusAd) {
        logger.log("Completed NimbusRequest for Mintegral.", level: .debug)
    }
    
    public func didFailNimbusRequest(with error: NimbusError) {
        logger.log("Failed NimbusRequest for Mintegral", level: .error)
    }

    public func renderInfo(for ad: NimbusAd) -> (any NimbusRenderInfo)? {
        guard ad.network == ThirdPartyDemandNetwork.mintegral.rawValue else {
            return nil
        }

        return NimbusMintegralRenderInfo(adUnitId: adUnitId, placementId: placementId)
    }
}
