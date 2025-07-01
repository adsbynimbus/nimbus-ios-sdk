//
//  NimbusMolocoInterceptor.swift
//  Nimbus
//  Created on 5/28/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusRequestKit
import NimbusRenderKit

final class NimbusMolocoRequestInterceptor {
    
    private static let extensionKey = "moloco_buyeruid"
    
    /// Nimbus internal logger
    private let logger: Logger
    
    /// Bridge that communicates with Moloco SDK
    private let bridge: MolocoRequestBridge
    
    let adUnitId: String
    
    public convenience init(adUnitId: String) {
        self.init(adUnitId: adUnitId, logger: Nimbus.shared.logger, bridge: MolocoRequestBridge())
    }
    
    init(adUnitId: String, logger: Logger, bridge: MolocoRequestBridge) {
        self.adUnitId = adUnitId
        self.logger = logger
        self.bridge = bridge
    }
}

extension NimbusMolocoRequestInterceptor: NimbusRequestInterceptorAsync {
    public func modifyRequest(request: NimbusRequest) async throws -> NimbusRequestDelta {
        let bidToken = try await bridge.bidToken
        try Task.checkCancellation()
        
        return NimbusRequestDelta(userExtension: (Self.extensionKey, NimbusCodable(bidToken)))
    }
}

extension NimbusMolocoRequestInterceptor: NimbusRequestInterceptor {
    public func modifyRequest(request: NimbusRequest) {
        // This method is present to maintain backward compatibility, but the async counterpart is used instead.
    }
    
    public func didCompleteNimbusRequest(with ad: NimbusAd) {
        logger.log("Completed NimbusRequest for Moloco.", level: .debug)
    }
    
    public func didFailNimbusRequest(with error: NimbusError) {
        logger.log("Failed NimbusRequest for Moloco", level: .error)
    }
    
    func renderInfo(for ad: NimbusAd) -> (any NimbusRenderInfo)? {
        guard ad.network == ThirdPartyDemandNetwork.moloco.rawValue else {
            return nil
        }

        return NimbusMolocoRenderInfo(adUnitId: adUnitId)
    }
}
